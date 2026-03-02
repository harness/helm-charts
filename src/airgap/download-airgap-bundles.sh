#!/usr/bin/env bash
#
# download-airgap-bundles.sh
#
# Download airgap bundles from a GCS bucket with full manifest awareness:
#   - Root modules (combined bundles, e.g. platform, ci, sto)
#   - Sub-bundles attached to a parent (e.g. ci/plugins, sto/scanners)
#   - Single-image bundles (e.g. platform/agents: delegate, upgrader)
#     with variant awareness (delegate-fips, delegate.minimal, etc.)
#
# Usage:
#   ./download-airgap-bundles.sh \
#     --base-url https://storage.googleapis.com/smp-airgap-bundles \
#     --release harness-0.37.0 \
#     --output-dir ./airgap-bundles \
#     [--modules ci,sto] \
#     [--agents delegate,delegate-fips,upgrader] \
#     [--non-interactive]
#

set -euo pipefail

log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_warn()  { echo "[WARN]  $(date +%H:%M:%S) $*" >&2; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*" >&2; }

# ─────────────────────────────────────────────────────────────────────────────
# Usage
# ─────────────────────────────────────────────────────────────────────────────
usage() {
    cat <<'EOF'
Usage: download-airgap-bundles.sh [OPTIONS]

Required:
  --base-url URL       Base URL for the bundle bucket
                       (e.g. https://storage.googleapis.com/smp-airgap-bundles)
  --release VERSION    Release version (e.g. harness-0.37.0)
  --output-dir PATH    Directory to save downloaded bundles

Module selection (at least one required unless --agents is used alone):
  --modules LIST       Comma-separated root module names (e.g. ci,sto,platform)
                       Dependencies (requires) are resolved and downloaded automatically.
                       Sub-bundles (plugins, scanners) are shown interactively unless
                       --non-interactive is set.

Agent selection:
  --agents LIST        Comma-separated agent bundle names to download directly.
                       Supports base name and variants, e.g.:
                         delegate            → base delegate bundle only
                         delegate-fips       → FIPS variant
                         delegate.minimal    → minimal variant
                         all                 → every delegate + upgrader variant
                       When omitted in interactive mode, available agents are shown.

Sub-bundle selection (non-interactive):
  --include-children LIST   Comma-separated sub-bundle paths (e.g. ci/plugins,sto/scanners)
                            Downloads ALL bundles in those sections.
  --include-bundles LIST    Comma-separated individual bundle names (e.g. kaniko,grype-job-runner)

Flags:
  --non-interactive    Skip all prompts. Requires --modules and/or --agents.
  --manifest-file PATH Use a local manifest file instead of downloading it.
  -h, --help           Show this help.

Examples:
  # Interactive: pick modules, sub-bundles and agents from menus
  ./download-airgap-bundles.sh \
    --base-url https://storage.googleapis.com/smp-airgap-bundles \
    --release harness-0.37.0 --output-dir ./bundles

  # Non-interactive: ci + sto with all scanners, no agents
  ./download-airgap-bundles.sh \
    --base-url https://storage.googleapis.com/smp-airgap-bundles \
    --release harness-0.37.0 --output-dir ./bundles \
    --modules ci,sto --include-children sto/scanners --non-interactive

  # Download only specific agents (no module bundles)
  ./download-airgap-bundles.sh \
    --base-url https://storage.googleapis.com/smp-airgap-bundles \
    --release harness-0.37.0 --output-dir ./bundles \
    --agents delegate,delegate-fips,upgrader --non-interactive

  # Download ci module + all agent variants
  ./download-airgap-bundles.sh \
    --base-url https://storage.googleapis.com/smp-airgap-bundles \
    --release harness-0.37.0 --output-dir ./bundles \
    --modules ci --agents all --non-interactive
EOF
    exit 0
}

# ─────────────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────────────
BASE_URL=""
RELEASE=""
MODULES_CSV=""
OUTPUT_DIR=""
INCLUDE_CHILDREN_CSV=""
INCLUDE_BUNDLES_CSV=""
AGENTS_CSV=""
NON_INTERACTIVE=false
MANIFEST_FILE=""

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)             usage ;;
        --base-url)            BASE_URL="$2";             shift 2 ;;
        --release)             RELEASE="$2";              shift 2 ;;
        --modules)             MODULES_CSV="$2";          shift 2 ;;
        --output-dir)          OUTPUT_DIR="$2";           shift 2 ;;
        --include-children)    INCLUDE_CHILDREN_CSV="$2"; shift 2 ;;
        --include-bundles)     INCLUDE_BUNDLES_CSV="$2";  shift 2 ;;
        --agents)              AGENTS_CSV="$2";           shift 2 ;;
        --non-interactive)     NON_INTERACTIVE=true;      shift   ;;
        --manifest-file)       MANIFEST_FILE="$2";        shift 2 ;;
        *)
            log_error "Unknown option: $1"
            usage
            ;;
    esac
done

if [ -z "$BASE_URL" ] || [ -z "$RELEASE" ] || [ -z "$OUTPUT_DIR" ]; then
    log_error "Missing required arguments (--base-url, --release, --output-dir)"
    usage
fi

if [ -z "$MODULES_CSV" ] && [ -z "$AGENTS_CSV" ] && [ "$NON_INTERACTIVE" = true ]; then
    log_error "Non-interactive mode requires --modules and/or --agents"
    usage
fi

BASE_URL="${BASE_URL%/}"

# ─────────────────────────────────────────────────────────────────────────────
# Download helper
# ─────────────────────────────────────────────────────────────────────────────
get_file_size() {
    [ -f "$1" ] && { stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo 0; } || echo 0
}

download_file() {
    local url="$1" dest="$2"
    mkdir -p "$(dirname "$dest")"
    if command -v curl &>/dev/null; then
        curl -fSL --progress-bar -o "$dest" "$url" 2>/dev/null && return 0
    elif command -v wget &>/dev/null; then
        wget -q --show-progress -O "$dest" "$url" 2>/dev/null && return 0
    else
        log_error "Neither curl nor wget found."
        exit 1
    fi
    return 1
}

# ─────────────────────────────────────────────────────────────────────────────
# Manifest parsing (Python embedded)
#
# Emits lines in one of three formats:
#   MODULE|<name>|<requires_csv>|<bucket_path>|<bundle_type>|<description>
#   CHILD|<name>|<parent>|<bucket_path>|<bundle_type>|<description>
#   AGENT|<section_name>|<bucket_path>|<image_name>|<suffixes_csv>
#
# AGENT lines are emitted for every image in a `single` bundle-type section
# that has a `parent` (i.e. sub-bundles like platform-agents, sto-scanners).
# ─────────────────────────────────────────────────────────────────────────────
parse_manifest() {
    local manifest_file="$1"
    python3 - "$manifest_file" <<'PYTHON'
import sys
import yaml

def get_name(entry):
    return entry['name'] if isinstance(entry, dict) else str(entry)

def get_suffixes(entry):
    if isinstance(entry, dict):
        return entry.get('variants', [])
    return []

def main():
    with open(sys.argv[1]) as f:
        data = yaml.safe_load(f)

    modules = data.get('modules', {})

    for mod_name, cfg in modules.items():
        parent      = cfg.get('parent', '')
        bundle_type = cfg.get('bundle_type', 'combined')
        bucket_path = cfg.get('bucket_path', mod_name)
        description = cfg.get('description', mod_name)
        requires    = ','.join(cfg.get('requires', []))

        if parent:
            print(f"CHILD|{mod_name}|{parent}|{bucket_path}|{bundle_type}|{description}")
        else:
            print(f"MODULE|{mod_name}|{requires}|{bucket_path}|{bundle_type}|{description}")

        # Emit AGENT lines for every image in single-type sections
        if bundle_type == 'single':
            for entry in cfg.get('images', []):
                name     = get_name(entry)
                suffixes = ','.join(get_suffixes(entry))
                print(f"AGENT|{mod_name}|{bucket_path}|{name}|{suffixes}")

if __name__ == '__main__':
    try:
        main()
    except Exception as e:
        sys.stderr.write(f"Parse error: {e}\n")
        sys.exit(1)
PYTHON
}

# ─────────────────────────────────────────────────────────────────────────────
# Manifest query helpers (all operate on the parsed string)
# ─────────────────────────────────────────────────────────────────────────────

# module_requires <parsed> <mod>  →  comma-separated requires
module_requires()   { echo "$1" | awk -F'|' -v m="$2" '$1=="MODULE" && $2==m {print $3}'; }
# module_bucket <parsed> <mod>
module_bucket()     { echo "$1" | awk -F'|' -v m="$2" '$1=="MODULE" && $2==m {print $4}'; }
# child_bucket <parsed> <child>
child_bucket()      { echo "$1" | awk -F'|' -v c="$2" '$1=="CHILD"  && $2==c {print $4}'; }
# child_parent <parsed> <child>
child_parent()      { echo "$1" | awk -F'|' -v c="$2" '$1=="CHILD"  && $2==c {print $3}'; }
# children_of <parsed> <parent>  →  newline-separated child names
children_of()       { echo "$1" | awk -F'|' -v p="$2" '$1=="CHILD"  && $3==p {print $2}'; }
# agents_in_section <parsed> <section>  →  lines: name|suffixes_csv
agents_in_section() { echo "$1" | awk -F'|' -v s="$2" '$1=="AGENT"  && $2==s {print $4 "|" $5}'; }
# all_agent_sections <parsed>  →  unique section names that have AGENT lines
all_agent_sections(){ echo "$1" | awk -F'|' '$1=="AGENT" {print $2}' | sort -u; }

# ─────────────────────────────────────────────────────────────────────────────
# Dependency resolution (BFS, bash 3.x compatible)
# ─────────────────────────────────────────────────────────────────────────────
resolve_modules() {
    local parsed="$1"
    local csv="$2"
    local seen="" resolved=""
    local queue=()
    IFS=',' read -ra queue <<< "$csv"

    while [ ${#queue[@]} -gt 0 ]; do
        local m="${queue[0]}"
        queue=("${queue[@]:1}")
        m="${m// /}"
        [ -z "$m" ] && continue
        echo "$seen" | grep -qF "|${m}|" && continue
        seen="${seen}|${m}|"
        resolved="${resolved} ${m}"
        local reqs
        reqs=$(module_requires "$parsed" "$m")
        if [ -n "$reqs" ]; then
            IFS=',' read -ra rarr <<< "$reqs"
            for r in "${rarr[@]}"; do
                r="${r// /}"
                [ -n "$r" ] && queue+=("$r")
            done
        fi
    done
    echo "$resolved"
}

# ─────────────────────────────────────────────────────────────────────────────
# Build the full list of agent bundle names for a section (base + variants)
# e.g. section=platform-agents → delegate, delegate.minimal, delegate-fips, upgrader, upgrader-fips
# ─────────────────────────────────────────────────────────────────────────────
expand_agent_section() {
    local parsed="$1"
    local section="$2"
    agents_in_section "$parsed" "$section" | while IFS='|' read -r name suffixes; do
        echo "$name"
        if [ -n "$suffixes" ]; then
            IFS=',' read -ra sarr <<< "$suffixes"
            for s in "${sarr[@]}"; do
                echo "${name}${s}"
            done
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Print a formatted agent menu for a section
# ─────────────────────────────────────────────────────────────────────────────
print_agent_menu() {
    local parsed="$1"
    local section="$2"
    local description="$3"
    local idx=1
    echo ""
    echo "  ── ${description} ──"
    agents_in_section "$parsed" "$section" | while IFS='|' read -r name suffixes; do
        printf "    %3d) %-40s (base)\n" "$idx" "$name"
        idx=$((idx + 1))
        if [ -n "$suffixes" ]; then
            IFS=',' read -ra sarr <<< "$suffixes"
            for s in "${sarr[@]}"; do
                printf "    %3d) %-40s (variant: %s)\n" "$idx" "${name}${s}" "$s"
                idx=$((idx + 1))
            done
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Counters (global)
# ─────────────────────────────────────────────────────────────────────────────
DL_COUNT=0
DL_SIZE=0
DL_FAILED=0

do_download() {
    local url="$1" dest="$2" label="$3"
    log_info "Downloading ${label}"
    log_info "  → ${url}"
    if download_file "$url" "$dest"; then
        local sz
        sz=$(get_file_size "$dest")
        DL_COUNT=$((DL_COUNT + 1))
        DL_SIZE=$((DL_SIZE + sz))
        log_info "  ✓ saved to ${dest} ($(( sz / 1024 / 1024 )) MB)"
    else
        log_warn "  ✗ failed: ${url}"
        DL_FAILED=$((DL_FAILED + 1))
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Download a combined module bundle
# ─────────────────────────────────────────────────────────────────────────────
download_module() {
    local parsed="$1" mod="$2"
    local bucket
    bucket=$(module_bucket "$parsed" "$mod")
    [ -z "$bucket" ] && bucket="$mod"
    local url="${BASE_URL}/${RELEASE}/${bucket}/${mod}_images.tgz"
    local dest="${OUTPUT_DIR}/${bucket}/${mod}_images.tgz"
    do_download "$url" "$dest" "module: ${mod}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Download a child (sub-bundle) — combined type: one tgz for the whole section
# ─────────────────────────────────────────────────────────────────────────────
download_child() {
    local parsed="$1" child="$2"
    local bucket
    bucket=$(child_bucket "$parsed" "$child")
    [ -z "$bucket" ] && bucket="$child"
    local url="${BASE_URL}/${RELEASE}/${bucket}/${child}_images.tgz"
    local dest="${OUTPUT_DIR}/${bucket}/${child}_images.tgz"
    do_download "$url" "$dest" "sub-bundle: ${child}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Download a single agent bundle by its full name (e.g. delegate-fips)
# ─────────────────────────────────────────────────────────────────────────────
download_agent() {
    local parsed="$1" agent_name="$2"
    # Find which section owns this agent name
    local section bucket
    section=$(echo "$parsed" | awk -F'|' -v a="$agent_name" '
        $1=="AGENT" {
            name=$4
            split($5, sfx, ",")
            if (name == a) { print $2; exit }
            for (i in sfx) {
                if (name sfx[i] == a) { print $2; exit }
            }
        }')
    if [ -z "$section" ]; then
        log_warn "Agent '${agent_name}' not found in manifest — skipping"
        return
    fi
    bucket=$(echo "$parsed" | awk -F'|' -v s="$section" '$1=="AGENT" && $2==s {print $3; exit}')
    [ -z "$bucket" ] && bucket="$section"
    local url="${BASE_URL}/${RELEASE}/${bucket}/${agent_name}.tgz"
    local dest="${OUTPUT_DIR}/${bucket}/${agent_name}.tgz"
    do_download "$url" "$dest" "agent: ${agent_name}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Interactive selection helper: parses "1,3-5,all,none" against a numbered list
# Input: a file with lines "idx|value"
# Output: space-separated "value" tokens to process
# ─────────────────────────────────────────────────────────────────────────────
parse_selection() {
    local list_file="$1"
    local selection="$2"
    local total
    total=$(wc -l < "$list_file" | tr -d ' ')
    local result=""

    selection=$(echo "$selection" | tr -d '[:space:]' | tr '[:upper:]' '[:lower:]')
    [ "$selection" = "none" ] || [ -z "$selection" ] && echo "" && return
    if [ "$selection" = "all" ]; then
        while IFS='|' read -r _ val; do result="${result} ${val}"; done < "$list_file"
        echo "$result"; return
    fi
    for part in $(echo "$selection" | tr ',' ' '); do
        if [[ "$part" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            for ((i=${BASH_REMATCH[1]}; i<=${BASH_REMATCH[2]}; i++)); do
                val=$(awk -F'|' -v n="$i" '$1==n {print $2}' "$list_file")
                [ -n "$val" ] && result="${result} ${val}"
            done
        else
            val=$(awk -F'|' -v n="$part" '$1==n {print $2}' "$list_file")
            [ -n "$val" ] && result="${result} ${val}"
        fi
    done
    echo "$result"
}

prompt() {
    local msg="$1"
    echo ""
    printf "%s: " "$msg"
    local ans
    read -r ans </dev/tty 2>/dev/null || read -r ans
    echo "$ans"
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
main() {
    log_info "Harness Airgap Bundle Downloader"
    log_info "Release:    ${RELEASE}"
    log_info "Base URL:   ${BASE_URL}"
    log_info "Output dir: ${OUTPUT_DIR}"
    mkdir -p "$OUTPUT_DIR"

    # ── Fetch / load manifest ─────────────────────────────────────────────────
    local tmp_manifest
    tmp_manifest=$(mktemp)
    trap "rm -f ${tmp_manifest}" EXIT

    if [ -n "$MANIFEST_FILE" ]; then
        [ ! -f "$MANIFEST_FILE" ] && log_error "Manifest not found: ${MANIFEST_FILE}" && exit 1
        log_info "Using local manifest: ${MANIFEST_FILE}"
        cp "$MANIFEST_FILE" "$tmp_manifest"
    else
        local manifest_url="${BASE_URL}/${RELEASE}/bundle-manifest.yaml"
        log_info "Fetching manifest from ${manifest_url}..."
        if ! download_file "$manifest_url" "$tmp_manifest"; then
            log_error "Failed to download manifest"
            exit 1
        fi
    fi
    [ ! -s "$tmp_manifest" ] && log_error "Manifest is empty" && exit 1

    local parsed
    parsed=$(parse_manifest "$tmp_manifest")

    # ── Interactive module selection (if --modules not given) ─────────────────
    if [ -z "$MODULES_CSV" ] && [ "$NON_INTERACTIVE" = false ]; then
        echo ""
        echo "═══════════════════════════════════════════════════════"
        echo "  Available Modules"
        echo "═══════════════════════════════════════════════════════"
        local mod_list
        mod_list=$(mktemp)
        trap "rm -f ${tmp_manifest} ${mod_list}" EXIT
        local idx=1
        echo "$parsed" | awk -F'|' '$1=="MODULE" {print $2 "|" $6 "|" $3}' | while IFS='|' read -r name desc reqs; do
            local req_label=""
            [ -n "$reqs" ] && req_label=" [requires: ${reqs}]"
            printf "  %3d) %-20s %s%s\n" "$idx" "$name" "$desc" "$req_label"
            echo "${idx}|${name}" >> "$mod_list"
            idx=$((idx + 1))
        done
        echo "───────────────────────────────────────────────────────"
        local sel
        sel=$(prompt "Select modules (numbers, ranges, 'all', or 'none')")
        local selected_mods
        selected_mods=$(parse_selection "$mod_list" "$sel")
        MODULES_CSV=$(echo "$selected_mods" | tr ' ' ',' | sed 's/^,//;s/,$//')
        rm -f "$mod_list"
    fi

    # ── Resolve module dependencies ───────────────────────────────────────────
    local resolved_modules=""
    if [ -n "$MODULES_CSV" ]; then
        resolved_modules=$(resolve_modules "$parsed" "$MODULES_CSV")
        log_info "Resolved modules (with dependencies): $(echo "$resolved_modules" | tr ' ' ',')"

        # Download combined module bundles
        echo ""
        log_info "── Downloading module bundles ──────────────────────────"
        for mod in $resolved_modules; do
            mod="${mod// /}"
            [ -z "$mod" ] && continue
            # Only download if it's a root module (has MODULE line), not a child
            echo "$parsed" | grep -q "^MODULE|${mod}|" && download_module "$parsed" "$mod"
        done
    fi

    # ── Sub-bundles (children with combined bundle_type) ─────────────────────
    # Collect all children of resolved modules
    local available_children=""
    if [ -n "$resolved_modules" ]; then
        for mod in $resolved_modules; do
            mod="${mod// /}"
            [ -z "$mod" ] && continue
            while IFS= read -r child; do
                [ -z "$child" ] && continue
                # Only combined-type children here; single-type are handled as agents
                local btype
                btype=$(echo "$parsed" | awk -F'|' -v c="$child" '$1=="CHILD" && $2==c {print $5}')
                [ "$btype" = "single" ] && continue
                available_children="${available_children} ${child}"
            done < <(children_of "$parsed" "$mod")
        done
    fi

    if [ -n "$available_children" ]; then
        local children_to_dl=""

        if [ "$NON_INTERACTIVE" = true ]; then
            if [ -n "$INCLUDE_CHILDREN_CSV" ]; then
                IFS=',' read -ra wanted_paths <<< "$INCLUDE_CHILDREN_CSV"
                for child in $available_children; do
                    local cbucket
                    cbucket=$(child_bucket "$parsed" "$child")
                    for wp in "${wanted_paths[@]}"; do
                        wp="${wp// /}"
                        [ "$cbucket" = "$wp" ] && children_to_dl="${children_to_dl} ${child}" && break
                    done
                done
            fi
            if [ -n "$INCLUDE_BUNDLES_CSV" ]; then
                IFS=',' read -ra wanted_names <<< "$INCLUDE_BUNDLES_CSV"
                for child in $available_children; do
                    for wn in "${wanted_names[@]}"; do
                        wn="${wn// /}"
                        [ "$child" = "$wn" ] && children_to_dl="${children_to_dl} ${child}" && break
                    done
                done
            fi
        else
            # Interactive sub-bundle selection
            echo ""
            echo "═══════════════════════════════════════════════════════"
            echo "  Available Sub-bundles (Plugins, etc.)"
            echo "═══════════════════════════════════════════════════════"
            local child_list
            child_list=$(mktemp)
            trap "rm -f ${tmp_manifest} ${child_list}" EXIT
            local cidx=1
            for child in $available_children; do
                local cdesc cbucket cparent
                cdesc=$(echo "$parsed" | awk -F'|' -v c="$child" '$1=="CHILD" && $2==c {print $6}')
                cbucket=$(child_bucket "$parsed" "$child")
                cparent=$(child_parent "$parsed" "$child")
                printf "  %3d) %-25s %-30s [parent: %s]\n" "$cidx" "$child" "$cdesc" "$cparent"
                echo "${cidx}|${child}" >> "$child_list"
                cidx=$((cidx + 1))
            done
            echo "───────────────────────────────────────────────────────"
            local csel
            csel=$(prompt "Select sub-bundles (numbers, ranges, 'all', or 'none')")
            children_to_dl=$(parse_selection "$child_list" "$csel")
            rm -f "$child_list"
        fi

        if [ -n "$children_to_dl" ]; then
            echo ""
            log_info "── Downloading sub-bundles ─────────────────────────────"
            for child in $children_to_dl; do
                child="${child// /}"
                [ -z "$child" ] && continue
                download_child "$parsed" "$child"
            done
        fi
    fi

    # ── Agents ────────────────────────────────────────────────────────────────
    # Collect all agent sections relevant to the resolved modules (or all if no modules)
    local relevant_agent_sections=""
    if [ -n "$resolved_modules" ]; then
        for mod in $resolved_modules; do
            mod="${mod// /}"
            [ -z "$mod" ] && continue
            while IFS= read -r child; do
                [ -z "$child" ] && continue
                local btype
                btype=$(echo "$parsed" | awk -F'|' -v c="$child" '$1=="CHILD" && $2==c {print $5}')
                [ "$btype" = "single" ] && relevant_agent_sections="${relevant_agent_sections} ${child}"
            done < <(children_of "$parsed" "$mod")
        done
    else
        # No modules selected — show all agent sections
        while IFS= read -r sec; do
            relevant_agent_sections="${relevant_agent_sections} ${sec}"
        done < <(all_agent_sections "$parsed")
    fi

    if [ -n "$relevant_agent_sections" ]; then
        local agents_to_dl=""

        if [ -n "$AGENTS_CSV" ]; then
            # --agents given: expand "all" or resolve named agents
            local agents_lower
            agents_lower=$(echo "$AGENTS_CSV" | tr '[:upper:]' '[:lower:]')
            if [ "$agents_lower" = "all" ]; then
                for sec in $relevant_agent_sections; do
                    sec="${sec// /}"
                    while IFS= read -r agent; do
                        agents_to_dl="${agents_to_dl} ${agent}"
                    done < <(expand_agent_section "$parsed" "$sec")
                done
            else
                IFS=',' read -ra wanted <<< "$AGENTS_CSV"
                for w in "${wanted[@]}"; do
                    w="${w// /}"
                    agents_to_dl="${agents_to_dl} ${w}"
                done
            fi
        elif [ "$NON_INTERACTIVE" = false ]; then
            # Interactive agent selection
            echo ""
            echo "═══════════════════════════════════════════════════════"
            echo "  Available Agents & Variants"
            echo "═══════════════════════════════════════════════════════"
            local agent_list
            agent_list=$(mktemp)
            trap "rm -f ${tmp_manifest} ${agent_list}" EXIT
            local aidx=1
            for sec in $relevant_agent_sections; do
                sec="${sec// /}"
                local sec_desc
                sec_desc=$(echo "$parsed" | awk -F'|' -v s="$sec" '$1=="CHILD" && $2==s {print $6}')
                [ -z "$sec_desc" ] && sec_desc="$sec"
                echo "  ── ${sec_desc} ──"
                agents_in_section "$parsed" "$sec" | while IFS='|' read -r name suffixes; do
                    printf "    %3d) %-45s  base\n" "$aidx" "$name"
                    echo "${aidx}|${name}" >> "$agent_list"
                    aidx=$((aidx + 1))
                    if [ -n "$suffixes" ]; then
                        IFS=',' read -ra sarr <<< "$suffixes"
                        for s in "${sarr[@]}"; do
                            printf "    %3d) %-45s  variant: %s\n" "$aidx" "${name}${s}" "$s"
                            echo "${aidx}|${name}${s}" >> "$agent_list"
                            aidx=$((aidx + 1))
                        done
                    fi
                done
            done
            echo "───────────────────────────────────────────────────────"
            local asel
            asel=$(prompt "Select agents (numbers, ranges, 'all', or 'none')")
            agents_to_dl=$(parse_selection "$agent_list" "$asel")
            rm -f "$agent_list"
        fi

        if [ -n "$agents_to_dl" ]; then
            echo ""
            log_info "── Downloading agents ──────────────────────────────────"
            for agent in $agents_to_dl; do
                agent="${agent// /}"
                [ -z "$agent" ] && continue
                download_agent "$parsed" "$agent"
            done
        fi
    fi

    # ── Summary ───────────────────────────────────────────────────────────────
    local total_mb=$(( DL_SIZE / 1024 / 1024 ))
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  Download Summary"
    echo "═══════════════════════════════════════════════════════"
    log_info "Downloaded : ${DL_COUNT} bundle(s)"
    log_info "Failed     : ${DL_FAILED} bundle(s)"
    log_info "Total size : ~${total_mb} MB"
    log_info "Saved to   : ${OUTPUT_DIR}"
    echo "═══════════════════════════════════════════════════════"
    [ "$DL_FAILED" -gt 0 ] && exit 1
    exit 0
}

main "$@"
