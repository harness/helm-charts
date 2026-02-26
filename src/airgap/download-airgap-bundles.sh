#!/usr/bin/env bash
#
# download-airgap-bundles.sh
#
# Customer-facing script to download airgap bundles from a GCS bucket with
# dependency resolution. Supports combined module bundles and optional
# single-image child bundles (plugins, scanners, etc.).
#
# Usage:
#   ./download-airgap-bundles.sh \
#     --base-url https://storage.googleapis.com/smp-airgap-bundles \
#     --release harness-0.37.0 \
#     --modules ci,sto \
#     --output-dir ./airgap-bundles \
#     [--include-children ci/plugins,sto/scanners] \
#     [--include-bundles kaniko,kaniko-acr] \
#     [--non-interactive]
#

set -e

log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_warn()  { echo "[WARN]  $(date +%H:%M:%S) $*" >&2; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*" >&2; }

# -----------------------------------------------------------------------------
# Usage and help
# -----------------------------------------------------------------------------
usage() {
    cat <<'EOF'
Usage: download-airgap-bundles.sh [OPTIONS]

Required:
  --base-url URL       Base URL for the bundle bucket (e.g. https://storage.googleapis.com/smp-airgap-bundles)
  --release VERSION    Release version (e.g. harness-0.37.0)
  --modules LIST       Comma-separated module names (e.g. ci,sto,platform)
  --output-dir PATH    Directory to save downloaded bundles

Optional:
  --include-children LIST   Comma-separated child section paths (e.g. ci/plugins,sto/scanners)
                            In non-interactive mode: download ALL bundles in these sections
  --include-bundles LIST   Comma-separated bundle names (e.g. kaniko,kaniko-acr)
                           In non-interactive mode: download these specific bundles
  --non-interactive        Skip prompts; use --include-children and/or --include-bundles
  --manifest-file PATH     Use local manifest file instead of downloading (for testing)
  -h, --help               Show this help

Examples:
  # Interactive: select modules, then choose child bundles when prompted
  ./download-airgap-bundles.sh --base-url https://storage.googleapis.com/smp-airgap-bundles \
    --release harness-0.37.0 --modules ci,sto --output-dir ./bundles

  # Non-interactive: download ci, sto, and all ci/plugins + sto/scanners bundles
  ./download-airgap-bundles.sh --base-url https://storage.googleapis.com/smp-airgap-bundles \
    --release harness-0.37.0 --modules ci,sto --output-dir ./bundles \
    --include-children ci/plugins,sto/scanners --non-interactive

  # Non-interactive: download only specific named bundles
  ./download-airgap-bundles.sh --base-url https://storage.googleapis.com/smp-airgap-bundles \
    --release harness-0.37.0 --modules ci --output-dir ./bundles \
    --include-bundles kaniko,kaniko-acr --non-interactive
EOF
    exit 0
}

# -----------------------------------------------------------------------------
# Argument parsing
# -----------------------------------------------------------------------------
BASE_URL=""
RELEASE=""
MODULES_CSV=""
OUTPUT_DIR=""
INCLUDE_CHILDREN_CSV=""
INCLUDE_BUNDLES_CSV=""
NON_INTERACTIVE=false
MANIFEST_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage
            ;;
        --base-url)
            BASE_URL="$2"
            shift 2
            ;;
        --release)
            RELEASE="$2"
            shift 2
            ;;
        --modules)
            MODULES_CSV="$2"
            shift 2
            ;;
        --output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        --include-children)
            INCLUDE_CHILDREN_CSV="$2"
            shift 2
            ;;
        --include-bundles)
            INCLUDE_BUNDLES_CSV="$2"
            shift 2
            ;;
        --non-interactive)
            NON_INTERACTIVE=true
            shift
            ;;
        --manifest-file)
            MANIFEST_FILE="$2"
            shift 2
            ;;
        *)
            log_error "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

if [ -z "$BASE_URL" ] || [ -z "$RELEASE" ] || [ -z "$MODULES_CSV" ] || [ -z "$OUTPUT_DIR" ]; then
    log_error "Missing required arguments (--base-url, --release, --modules, --output-dir)"
    usage
    exit 1
fi

# Normalize base URL (strip trailing slash)
BASE_URL="${BASE_URL%/}"

# -----------------------------------------------------------------------------
# Download helper (curl or wget)
# -----------------------------------------------------------------------------
# Portable file size (macOS: stat -f%z, Linux: stat -c%s)
get_file_size() {
    if [ -f "$1" ]; then
        stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo 0
    else
        echo 0
    fi
}

download_file() {
    local url="$1"
    local dest="$2"
    local dir
    dir=$(dirname "$dest")
    mkdir -p "$dir"

    if command -v curl &>/dev/null; then
        if curl -fSL -o "$dest" "$url" 2>/dev/null; then
            return 0
        fi
    elif command -v wget &>/dev/null; then
        if wget -q -O "$dest" "$url" 2>/dev/null; then
            return 0
        fi
    else
        log_error "Neither curl nor wget found. Please install one."
        exit 1
    fi
    return 1
}

# -----------------------------------------------------------------------------
# Manifest parsing: output format for bash consumption
# MODULE|name|requires|bucket_path|bundle_type
# CHILD|parent|child_name|bucket_path|bundle_type|image1,image2,...
# -----------------------------------------------------------------------------
parse_manifest_python() {
    local manifest_file="$1"
    python3 - "$manifest_file" <<'PYTHON'
import sys
import yaml

def get_short_name(entry):
    if isinstance(entry, dict):
        return entry.get('name', '')
    return str(entry)

def main():
    path = sys.argv[1]
    with open(path) as f:
        data = yaml.safe_load(f)
    modules = data.get('modules', {})
    for mod_name, mod_cfg in modules.items():
        requires = mod_cfg.get('requires', [])
        requires_str = ','.join(requires) if requires else ''
        bucket_path = mod_cfg.get('bucket_path', mod_name)
        bundle_type = mod_cfg.get('bundle_type', 'combined')
        print(f"MODULE|{mod_name}|{requires_str}|{bucket_path}|{bundle_type}")

    for mod_name, mod_cfg in modules.items():
        for child_name, child_cfg in mod_cfg.get('children', {}).items():
            bucket_path = child_cfg.get('bucket_path', f"{mod_name}/{child_name}")
            bundle_type = child_cfg.get('bundle_type', 'single')
            images = child_cfg.get('images', [])
            names = [get_short_name(e) for e in images if get_short_name(e)]
            images_str = ','.join(names)
            print(f"CHILD|{mod_name}|{child_name}|{bucket_path}|{bundle_type}|{images_str}")

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        sys.stderr.write(f"Parse error: {e}\n")
        sys.exit(1)
PYTHON
}

parse_manifest_fallback() {
    local manifest_file="$1"
    # Fallback: grep/sed for simple YAML - best-effort, no python/yq required
    log_warn "Using fallback YAML parsing (install python3+pyyaml for full support)"

    # Output MODULE lines: top-level keys under "modules:" that have requires/bucket_path
    grep -E '^  [a-zA-Z0-9_-]+:$' "$manifest_file" | sed 's/^  //;s/:$//' | while read -r name; do
        [ "$name" = "modules" ] && continue
        [ "$name" = "global_variants" ] && continue
        block=$(sed -n "/^  ${name}:/,/^  [a-zA-Z0-9_-]*:/p" "$manifest_file" | head -50)
        if echo "$block" | grep -q "requires:"; then
            requires=$(echo "$block" | grep "requires:" | head -1 | sed 's/.*\[//;s/\].*//;s/, /,/g')
            bucket_path=$(echo "$block" | grep "bucket_path:" | head -1 | sed 's/.*"\([^"]*\)".*/\1/')
            [ -z "$bucket_path" ] && bucket_path="$name"
            bundle_type=$(echo "$block" | grep "bundle_type:" | head -1 | sed 's/.*bundle_type:[[:space:]]*"\?\([^"]*\)"\?.*/\1/')
            [ -z "$bundle_type" ] && bundle_type="combined"
            echo "MODULE|${name}|${requires}|${bucket_path}|${bundle_type}"
        fi
    done

    # Output CHILD lines: nested keys under children with bundle_type single
    grep -E '^  [a-zA-Z0-9_-]+:$' "$manifest_file" | sed 's/^  //;s/:$//' | while read -r name; do
        block=$(sed -n "/^  ${name}:/,/^  [a-zA-Z0-9_-]*:/p" "$manifest_file" | head -80)
        if ! echo "$block" | grep -q "children:"; then
            continue
        fi
        # Child names: 6 spaces; keys: 8 spaces; images: 10 spaces
        echo "$block" | awk -v parent="$name" '
        /^      [a-zA-Z0-9_-]+:$/ {
            if (child != "" && c_bucket != "" && c_type == "single") {
                print "CHILD|" parent "|" child "|" c_bucket "|" c_type "|" c_images
            }
            sub(/^      /, ""); sub(/:$/, ""); child = $0
            c_bucket = ""; c_type = "single"; c_images = ""
        }
        /^        bucket_path:/ { gsub(/^[^"]*"/, ""); gsub(/".*/, ""); c_bucket = $0 }
        /^        bundle_type:/ { gsub(/^[^:]*:[[:space:]]*"?/, ""); gsub(/".*/, ""); c_type = $0 }
        /^          - [a-zA-Z0-9_-]+$/ { gsub(/^          - /, ""); if (c_images != "") c_images = c_images ","; c_images = c_images $0 }
        /^          - name:/ { gsub(/^[^:]*:[[:space:]]*"?|".*$/, ""); if (c_images != "") c_images = c_images ","; c_images = c_images $0 }
        END {
            if (child != "" && c_bucket != "" && c_type == "single") {
                print "CHILD|" parent "|" child "|" c_bucket "|" c_type "|" c_images
            }
        }
        ' 2>/dev/null
    done | sort -u
}

parse_manifest() {
    local manifest_file="$1"
    if command -v python3 &>/dev/null; then
        if python3 -c "import yaml" 2>/dev/null; then
            parse_manifest_python "$manifest_file"
            return
        fi
    fi
    parse_manifest_fallback "$manifest_file"
}

# -----------------------------------------------------------------------------
# Resolve dependencies: for selected modules, collect all required (deduplicated)
# Uses grep-based lookups for bash 3.x compatibility (no associative arrays)
# -----------------------------------------------------------------------------
resolve_dependencies() {
    local manifest_parsed="$1"
    local modules_csv="$2"
    local mod_arr
    IFS=',' read -ra mod_arr <<< "$modules_csv"

    local resolved=""
    local to_process=("${mod_arr[@]}")
    local seen=""

    while [ ${#to_process[@]} -gt 0 ]; do
        local m="${to_process[0]}"
        to_process=("${to_process[@]:1}")
        m=$(echo "$m" | tr -d ' ')
        [ -z "$m" ] && continue
        echo "$seen" | grep -q "|${m}|" && continue
        seen="${seen}|${m}|"

        local reqs
        reqs=$(echo "$manifest_parsed" | grep "^MODULE|${m}|" | head -1 | cut -d'|' -f3)
        if [ -n "$reqs" ]; then
            IFS=',' read -ra rarr <<< "$reqs"
            for r in "${rarr[@]}"; do
                r=$(echo "$r" | tr -d ' ')
                [ -n "$r" ] && to_process+=("$r")
            done
        fi
        resolved="${resolved}${m} "
    done

    echo "$resolved"
}

# Get bucket_path for a module from parsed manifest
get_module_bucket_path() {
    local manifest_parsed="$1"
    local mod="$2"
    echo "$manifest_parsed" | grep "^MODULE|${mod}|" | head -1 | cut -d'|' -f4
}

# -----------------------------------------------------------------------------
# Get child sections with bundle_type=single for resolved modules
# Output: idx|bucket_path|bundle_name (one per bundle)
# -----------------------------------------------------------------------------
get_single_bundles_from_manifest() {
    local manifest_parsed="$1"
    local resolved_modules="$2"

    # Collect all bundle|bucket_path|name lines, then number them
    local lines=""
    echo "$manifest_parsed" | grep "^CHILD|" | while IFS='|' read -r kind parent child_name bucket_path bundle_type images; do
        [ "$bundle_type" != "single" ] && continue
        # Check if parent is in resolved set
        local found=0
        for m in $resolved_modules; do
            [ "$m" = "$parent" ] && found=1 && break
        done
        [ $found -eq 0 ] && continue

        IFS=',' read -ra imgs <<< "$images"
        for img in "${imgs[@]}"; do
            img=$(echo "$img" | tr -d ' ')
            [ -n "$img" ] || continue
            echo "${bucket_path}|${img}"
        done
    done | sort -u | awk -F'|' '{printf "%d|%s|%s\n", NR, $1, $2}'
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    log_info "Downloading airgap bundles for release: ${RELEASE}"
    log_info "Base URL: ${BASE_URL}"
    log_info "Modules: ${MODULES_CSV}"
    log_info "Output directory: ${OUTPUT_DIR}"

    mkdir -p "$OUTPUT_DIR"
    local tmp_manifest
    tmp_manifest=$(mktemp)
    trap "rm -f ${tmp_manifest}" EXIT

    if [ -n "$MANIFEST_FILE" ]; then
        if [ ! -f "$MANIFEST_FILE" ]; then
            log_error "Manifest file not found: ${MANIFEST_FILE}"
            exit 1
        fi
        log_info "Using local manifest: ${MANIFEST_FILE}"
        cp "$MANIFEST_FILE" "$tmp_manifest"
    else
        local manifest_url="${BASE_URL}/${RELEASE}/bundle-manifest.yaml"
        log_info "Downloading bundle-manifest.yaml..."
        if ! download_file "$manifest_url" "$tmp_manifest"; then
            log_error "Failed to download manifest from ${manifest_url}"
            exit 1
        fi
    fi

    if [ ! -s "$tmp_manifest" ]; then
        log_error "Manifest is empty"
        exit 1
    fi

    # Parse manifest once for reuse
    local manifest_parsed
    manifest_parsed=$(parse_manifest "$tmp_manifest")

    # Resolve dependencies
    local resolved
    resolved=$(resolve_dependencies "$manifest_parsed" "$MODULES_CSV")
    log_info "Resolved modules (with dependencies): $resolved"

    # Download combined bundles for each resolved module
    local combined_count=0
    local combined_size=0
    for mod in $resolved; do
        mod=$(echo "$mod" | tr -d ' ')
        [ -z "$mod" ] && continue
        local bucket_path
        bucket_path=$(get_module_bucket_path "$manifest_parsed" "$mod")
        [ -z "$bucket_path" ] && bucket_path="$mod"
        local bundle_name="${mod}_images.tgz"
        local url="${BASE_URL}/${RELEASE}/${bucket_path}/${bundle_name}"
        local dest="${OUTPUT_DIR}/${bucket_path}/${bundle_name}"
        log_info "Downloading combined bundle: ${mod} -> ${dest}"
        if download_file "$url" "$dest"; then
            combined_count=$((combined_count + 1))
            combined_size=$((combined_size + $(get_file_size "$dest")))
        else
            log_warn "Failed to download ${url}"
        fi
    done

    # Get single bundles (children with bundle_type=single)
    local single_bundles_file
    single_bundles_file=$(mktemp)
    trap "rm -f ${tmp_manifest} ${single_bundles_file}" EXIT
    get_single_bundles_from_manifest "$manifest_parsed" "$resolved" > "$single_bundles_file"

    local single_count=0
    local single_size=0
    local to_download=""

    if [ "$NON_INTERACTIVE" = true ]; then
        local download_list=""
        if [ -n "$INCLUDE_CHILDREN_CSV" ]; then
            IFS=',' read -ra child_paths <<< "$INCLUDE_CHILDREN_CSV"
            while IFS='|' read -r _ bucket_path bundle_name; do
                for cp in "${child_paths[@]}"; do
                    cp=$(echo "$cp" | tr -d ' ')
                    if [ "$bucket_path" = "$cp" ]; then
                        download_list="${download_list}${bucket_path}|${bundle_name}"$'\n'
                        break
                    fi
                done
            done < "$single_bundles_file"
        fi
        if [ -n "$INCLUDE_BUNDLES_CSV" ]; then
            IFS=',' read -ra bundle_names <<< "$INCLUDE_BUNDLES_CSV"
            while IFS='|' read -r _ bucket_path bundle_name; do
                for bn in "${bundle_names[@]}"; do
                    bn=$(echo "$bn" | tr -d ' ')
                    if [ "$bundle_name" = "$bn" ]; then
                        download_list="${download_list}${bucket_path}|${bundle_name}"$'\n'
                        break
                    fi
                done
            done < "$single_bundles_file"
        fi
        # Deduplicate and convert to space-separated for the download loop
        to_download=$(echo "$download_list" | grep -v '^$' | sort -u | tr '\n' ' ')
    else
        # Interactive: show numbered list and prompt
        local total
        total=$(wc -l < "$single_bundles_file" | tr -d ' ')
        if [ "$total" -eq 0 ]; then
            log_info "No optional single bundles available for selected modules."
        else
            echo ""
            log_info "Available optional bundles (single-image):"
            echo "----------------------------------------"
            while IFS='|' read -r idx bucket_path bundle_name; do
                printf "  %3s) %s (%s)\n" "$idx" "$bundle_name" "$bucket_path"
            done < "$single_bundles_file"
            echo "----------------------------------------"
            echo "Enter selection (comma-separated numbers, ranges like 3-10, 'all', or 'none'): "
            read -r selection </dev/tty 2>/dev/null || read -r selection
            selection=$(echo "$selection" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
            if [ "$selection" = "none" ] || [ -z "$selection" ]; then
                log_info "No single bundles selected."
            elif [ "$selection" = "all" ]; then
                while IFS='|' read -r _ bucket_path bundle_name; do
                    to_download="${to_download}${bucket_path}|${bundle_name} "
                done < "$single_bundles_file"
            else
                # Parse: 1,2,3-5,7
                for part in $(echo "$selection" | tr ',' ' '); do
                    if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
                        start="${BASH_REMATCH[1]}"
                        end="${BASH_REMATCH[2]}"
                        for ((i=start; i<=end; i++)); do
                            line=$(sed -n "${i}p" "$single_bundles_file")
                            [ -n "$line" ] && to_download="${to_download}$(echo "$line" | cut -d'|' -f2- | tr '\n' ' ') "
                        done
                    else
                        line=$(sed -n "${part}p" "$single_bundles_file")
                        [ -n "$line" ] && to_download="${to_download}$(echo "$line" | cut -d'|' -f2- | tr '\n' ' ') "
                    fi
                done
            fi
        fi
    fi

    # Download selected single bundles
    for entry in $to_download; do
        [ -z "$entry" ] && continue
        local bucket_path bundle_name
        bucket_path=$(echo "$entry" | cut -d'|' -f1)
        bundle_name=$(echo "$entry" | cut -d'|' -f2)
        local url="${BASE_URL}/${RELEASE}/${bucket_path}/${bundle_name}.tgz"
        local dest="${OUTPUT_DIR}/${bucket_path}/${bundle_name}.tgz"
        log_info "Downloading single bundle: ${bundle_name} -> ${dest}"
        if download_file "$url" "$dest"; then
            single_count=$((single_count + 1))
            single_size=$((single_size + $(get_file_size "$dest")))
        else
            log_warn "Failed to download ${url}"
        fi
    done

    # Summary
    local total_size=$((combined_size + single_size))
    local total_size_mb=$((total_size / 1024 / 1024))
    echo ""
    log_info "=== DOWNLOAD SUMMARY ==="
    log_info "Combined bundles: ${combined_count}"
    log_info "Single bundles:   ${single_count}"
    log_info "Total size:       ~${total_size_mb} MB"
    log_info "Saved to:         ${OUTPUT_DIR}"
    log_info "Done."
}

main "$@"
