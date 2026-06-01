#!/usr/bin/env bash
#
# download-airgap-bundles.sh
#
# Download airgap bundles for Harness Self-Managed Platform.
# Bundles are referenced by their manifest name regardless of type:
#   - Root modules      (e.g. platform, ci, sto)
#   - Sub-bundles       (e.g. ci-plugins, sto-scanners, cdng-agents)
#   - Agent variants    (e.g. delegate, delegate-fips, upgrader)
#
# Usage:
#   # With version (< 0.41.0 uses the default public GCS bucket):
#   ./download-airgap-bundles.sh --version 0.37.0 --output-dir ./airgap-bundles
#
#   # With a custom/self-hosted bundle URL:
#   ./download-airgap-bundles.sh \
#     --url https://my-mirror.example.com/bundles/harness-0.37.0 \
#     --output-dir ./airgap-bundles
#
#   # Releases >= 0.41.0 ship from a private bucket — the manifest containing
#   # per-bundle signed URLs is provided by Harness support:
#   ./download-airgap-bundles.sh \
#     --manifest-file ./harness-manifest.yaml \
#     --output-dir ./airgap-bundles
#

set -euo pipefail

# ─────────────────────────────────────────────────────────────────────────────
# Colours (auto-disabled when stdout is not a terminal)
# ─────────────────────────────────────────────────────────────────────────────
if [ -t 1 ] && command -v tput &>/dev/null && tput colors &>/dev/null 2>&1; then
    RED=$'\033[0;31m'; YELLOW=$'\033[1;33m'; GREEN=$'\033[0;32m'
    CYAN=$'\033[0;36m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
else
    RED=''; YELLOW=''; GREEN=''; CYAN=''; BOLD=''; DIM=''; RESET=''
fi

log_info()  { printf "${GREEN}[INFO]${RESET}  %s %s\n"  "$(date +%H:%M:%S)" "$*"; }
log_warn()  { printf "${YELLOW}[WARN]${RESET}  %s %s\n"  "$(date +%H:%M:%S)" "$*" >&2; }
log_error() { printf "${RED}[ERROR]${RESET} %s %s\n"  "$(date +%H:%M:%S)" "$*" >&2; }
log_step()  { printf "\n${BOLD}${CYAN}┌─ %s${RESET}\n" "$*"; }
log_done()  { printf "${GREEN}  ✓${RESET} %s\n" "$*"; }
log_skip()  { printf "${DIM}  ↷ skipped: %s${RESET}\n" "$*" >&2; }

# ─────────────────────────────────────────────────────────────────────────────
# Usage
# ─────────────────────────────────────────────────────────────────────────────
DEFAULT_BASE_URL="https://storage.googleapis.com/smp-airgap-bundles"

usage_short() {
    cat <<EOF >&2

${BOLD}Bundle source (one required):${RESET}
  -v, --version VERSION    Harness release version  (e.g. 0.37.0)
                             ${DIM}< ${MANIFEST_REQUIRED_VERSION}: uses default public GCS bucket${RESET}
                             ${DIM}>= ${MANIFEST_REQUIRED_VERSION}: also requires --manifest-file (from Harness support)${RESET}
      --url URL            Complete base URL to the release directory
                             ${DIM}(alternative to --version, for self-hosted mirrors)${RESET}
  -m, --manifest-file PATH Local manifest file containing signed download URLs
                             ${DIM}Required for releases >= ${MANIFEST_REQUIRED_VERSION} (request from Harness support)${RESET}

${BOLD}Output:${RESET}
  -o, --output-dir PATH    Directory to save downloaded bundles  ${DIM}(not needed with --list)${RESET}

${BOLD}Non-interactive mode also requires:${RESET}
  -b, --bundles LIST       Comma-separated bundle names  (modules, sub-bundles, or agents)
                             ${DIM}e.g. platform,ci,ci-plugins,delegate,delegate-fips${RESET}
                             ${DIM}Use 'all' to download everything. Run --list to see names.${RESET}

${BOLD}Quick start:${RESET}
  # See what is available:
  ./download-airgap-bundles.sh -v 0.37.0 --list
  ./download-airgap-bundles.sh -m ./manifest.yaml --list

  # Pick interactively and save to a file (no download yet):
  ./download-airgap-bundles.sh -v 0.37.0 --generate-selection-file  (-g)

  # Then download using that saved file:
  ./download-airgap-bundles.sh -v 0.37.0 --output-dir ./bundles --selection-file selection.conf

Run ${BOLD}./download-airgap-bundles.sh --help${RESET} for full usage and examples.
EOF
    exit 1
}

usage() {
    cat <<EOF
${BOLD}Usage:${RESET} download-airgap-bundles.sh [OPTIONS]

${BOLD}Bundle source (one required):${RESET}
  -v, --version VERSION    Harness release version (e.g. 0.37.0 or harness-0.37.0).
                           For versions < ${MANIFEST_REQUIRED_VERSION} this is enough and the
                           default public GCS bucket is used:
                             ${DEFAULT_BASE_URL}
                           For versions >= ${MANIFEST_REQUIRED_VERSION} you must ALSO pass
                           --manifest-file (request from Harness support).
      --url URL            Complete base URL to the release directory.
                           Use this for self-hosted mirrors or non-standard paths.
                             e.g. https://my-mirror.example.com/bundles/harness-0.37.0
  -m, --manifest-file PATH Local manifest YAML containing per-bundle signed
                           download URLs (required for >= ${MANIFEST_REQUIRED_VERSION} releases).
                           Starting from ${MANIFEST_REQUIRED_VERSION}, airgap bundles are served
                           from a private bucket. Request the manifest from Harness
                           support — it carries pre-signed download URLs that
                           expire after a set time.
                           May be combined with --version for the version banner
                           and selection-file metadata.

${BOLD}Output:${RESET}
  -o, --output-dir PATH    Directory to save downloaded bundles (required, except for --list).

${BOLD}Listing available bundles:${RESET}
  -l, --list               Print all available bundles from the manifest, then exit.
                           No download is performed.

${BOLD}Bundle selection:${RESET}
  -b, --bundles LIST       Comma-separated list of bundle names to download, or 'all'.
                           A bundle can be a module, a sub-bundle, or an agent variant —
                           any name shown by --list.
                             e.g. platform,ci,ci-plugins,delegate,delegate-fips
                           When a module is selected its required dependencies are
                           automatically added. Sub-bundles and agents must be named
                           explicitly (or use 'all').
                           Omit in interactive mode to pick from an arrow-key menu.

${BOLD}Selection file (recommended for repeated / automated use):${RESET}
  -s, --selection-file PATH  Path to a plain-text file specifying what to download.
                             Run -g / --generate-selection-file to create one interactively.
                             Format:
                               bundles=platform,ci,ci-plugins,delegate  # or: all
                             CLI flag --bundles overrides the file value.

${BOLD}Flags:${RESET}
  -n, --non-interactive    Skip all prompts. Requires --bundles.
  -g, --generate-selection-file [FILE]
                           Run the interactive selection UI but write a selection
                           file instead of downloading anything.
                           Defaults to selection.conf in the current directory.
  -h, --help               Show this help.

${BOLD}Examples:${RESET}
  # See every available bundle name:
  ./download-airgap-bundles.sh -v 0.37.0 --list
  ./download-airgap-bundles.sh --version 0.37.0 -l

  # Pick interactively, save as a selection file:
  ./download-airgap-bundles.sh -v 0.37.0 -g my-selection.conf
  ./download-airgap-bundles.sh --version 0.37.0 --generate-selection-file my-selection.conf

  # Interactive: pick everything from one arrow-key menu, then download:
  ./download-airgap-bundles.sh -v 0.37.0 -o ./bundles
  ./download-airgap-bundles.sh --version 0.37.0 --output-dir ./bundles

  # Non-interactive via selection file:
  ./download-airgap-bundles.sh -v 0.37.0 -o ./bundles -s selection.conf
  ./download-airgap-bundles.sh --version 0.37.0 --output-dir ./bundles --selection-file selection.conf

  # Non-interactive: ci + ci-plugins + delegate only:
  ./download-airgap-bundles.sh -v 0.37.0 -o ./bundles -b ci,ci-plugins,delegate -n
  ./download-airgap-bundles.sh --version 0.37.0 --output-dir ./bundles \\
    --bundles ci,ci-plugins,delegate --non-interactive

  # Download everything:
  ./download-airgap-bundles.sh -v 0.37.0 -o ./bundles -b all -n
  ./download-airgap-bundles.sh --version 0.37.0 --output-dir ./bundles --bundles all --non-interactive

  # Self-hosted mirror:
  ./download-airgap-bundles.sh \\
    --url https://my-mirror.example.com/bundles/harness-0.37.0 \\
    -o ./bundles -b platform -n

  # Releases >= ${MANIFEST_REQUIRED_VERSION} with a manifest from Harness support (signed URLs):
  ./download-airgap-bundles.sh -m ./harness-manifest.yaml --list
  ./download-airgap-bundles.sh -m ./harness-manifest.yaml -o ./bundles -b all -n
  ./download-airgap-bundles.sh --manifest-file ./harness-manifest.yaml \\
    --output-dir ./bundles --bundles platform,ci,ci-plugins --non-interactive
EOF
    exit 0
}

# ─────────────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────────────
VERSION=""
BUNDLE_URL=""
BUNDLES_CSV=""           # -b / --bundles: flat list of any bundle names
NON_INTERACTIVE=false
OUTPUT_DIR=""
SELECTION_FILE=""        # -s / --selection-file
LIST_ONLY=false          # -l / --list
GENERATE_SELECTION=false # -g / --generate-selection-file
SELECTION_OUTPUT_FILE="" # output path for --generate-selection-file (default: ./selection.conf)
MANIFEST_FILE=""         # -m / --manifest-file: local manifest containing signed download URLs

# For releases >= MANIFEST_REQUIRED_VERSION bundles live in a private bucket
# and the manifest (with signed URLs) must be provided by Harness support.
MANIFEST_REQUIRED_VERSION="0.41.0"

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)             usage ;;
        -v|--version)          VERSION="$2";               shift 2 ;;
        --url)                 BUNDLE_URL="$2";            shift 2 ;;
        -m|--manifest-file)    MANIFEST_FILE="$2";         shift 2 ;;
        -b|--bundles)          BUNDLES_CSV="$2";           shift 2 ;;
        -o|--output-dir)       OUTPUT_DIR="$2";            shift 2 ;;
        -n|--non-interactive)  NON_INTERACTIVE=true;       shift   ;;
        -s|--selection-file)   SELECTION_FILE="$2";        shift 2 ;;
        -l|--list)             LIST_ONLY=true;             shift   ;;
        -g|--generate-selection-file)
            GENERATE_SELECTION=true
            if [ -n "${2:-}" ] && [[ "${2:-}" != --* ]] && [[ "${2:-}" != -* ]]; then
                SELECTION_OUTPUT_FILE="$2"; shift 2
            else
                shift
            fi
            ;;
        *)
            log_error "Unknown option: $1"
            usage_short
            ;;
    esac
done

# version_ge A B   →  returns 0 iff A >= B (semver-ish comparison via sort -V)
version_ge() {
    # If A == B, they're equal (>=). Otherwise sort both; the greater one sorts last.
    [ "$1" = "$2" ] && return 0
    local _top
    _top=$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -n1)
    [ "$_top" = "$1" ]
}

# Validate bundle source. One of --version / --url / --manifest-file is required.
if [ -z "$VERSION" ] && [ -z "$BUNDLE_URL" ] && [ -z "$MANIFEST_FILE" ]; then
    log_error "Bundle source is required: provide --version, --url, or --manifest-file"
    usage_short
fi
if [ -n "$VERSION" ] && [ -n "$BUNDLE_URL" ]; then
    log_error "--version and --url are mutually exclusive; use one or the other"
    usage_short
fi
if [ -z "$OUTPUT_DIR" ] && [ "$LIST_ONLY" = false ] && [ "$GENERATE_SELECTION" = false ]; then
    log_error "Missing required argument: --output-dir"
    usage_short
fi
if [ -z "$BUNDLES_CSV" ] && [ "$NON_INTERACTIVE" = true ] \
        && [ "$LIST_ONLY" = false ] && [ "$GENERATE_SELECTION" = false ]; then
    log_error "Non-interactive mode requires --bundles"
    usage_short
fi

# Normalise: strip any "harness-" prefix so we always control the format
[ -n "$VERSION" ] && VERSION="${VERSION#harness-}"

# Version gate: releases >= 0.41.0 ship from a private bucket and require a
# manifest (with signed download URLs) from Harness support.
if [ -n "$VERSION" ] && [ -z "$MANIFEST_FILE" ] \
        && version_ge "$VERSION" "$MANIFEST_REQUIRED_VERSION"; then
    log_error "Version ${VERSION} requires a manifest file provided by Harness support."
    log_error "Starting from ${MANIFEST_REQUIRED_VERSION}, airgap bundles are served from a"
    log_error "private bucket and each bundle has its own signed download URL baked into"
    log_error "the manifest. Request the manifest from Harness support and re-run with:"
    log_error "    --manifest-file <path-to-manifest.yaml>"
    exit 1
fi

# Derive EFFECTIVE_BASE — used as a fallback when manifest entries lack download_url
# (i.e. legacy < 0.41.0 manifests fetched from the public bucket).
EFFECTIVE_BASE=""
if [ -n "$BUNDLE_URL" ]; then
    EFFECTIVE_BASE="${BUNDLE_URL%/}"
elif [ -n "$VERSION" ]; then
    EFFECTIVE_BASE="${DEFAULT_BASE_URL}/harness-${VERSION}"
fi

# ─────────────────────────────────────────────────────────────────────────────
# Download helper
# ─────────────────────────────────────────────────────────────────────────────
get_file_size() {
    [ -f "$1" ] && { stat -f%z "$1" 2>/dev/null || stat -c%s "$1" 2>/dev/null || echo 0; } || echo 0
}

download_file() {
    local url="$1" dest="$2"
    # $3 (optional) — name of a variable to receive the error message on failure
    local _err_var="${3:-}"
    mkdir -p "$(dirname "$dest")"

    # Use a temp file to capture stderr separately so the progress bar
    # still streams live to the terminal while errors are also preserved.
    local _stderr_tmp
    _stderr_tmp=$(mktemp)

    local _rc=0
    if command -v curl &>/dev/null; then
        # tee stderr to /dev/tty (progress bar live on terminal) AND the temp
        # file (so errors are still capturable on failure).
        curl -fSL --progress-bar -o "$dest" "$url" 2> >(tee "$_stderr_tmp" >/dev/tty)
        _rc=$?
    elif command -v wget &>/dev/null; then
        wget -q --show-progress --progress=bar -O "$dest" "$url" 2> >(tee "$_stderr_tmp" >/dev/tty)
        _rc=$?
    else
        log_error "Neither curl nor wget found."
        rm -f "$_stderr_tmp"
        exit 1
    fi

    if [ "$_rc" -ne 0 ] && [ -n "$_err_var" ]; then
        printf -v "$_err_var" '%s' "$(cat "$_stderr_tmp")"
    fi
    rm -f "$_stderr_tmp"
    return "$_rc"
}

# ─────────────────────────────────────────────────────────────────────────────
# Manifest parsing (Python embedded)
#
# Emits lines in one of four formats:
#   META|<key>|<value>                                       (e.g. expires_at_epoch_seconds)
#   MODULE|<name>|<requires_csv>|<bucket_path>|<bundle_type>|<description>|<download_url>
#   CHILD|<name>|<parent>|<bucket_path>|<bundle_type>|<description>|<download_url>
#   AGENT|<section_name>|<bucket_path>|<bundle_name>|<file_name>|<download_url>
#
# The parser pre-expands agent variants: every AGENT row maps to exactly one
# downloadable tgz. <bundle_name> is the user-selectable / display name (with
# any variant suffix appended); <file_name> is the on-disk name (dots in the
# suffix collapsed to dashes).
#
# download_url is empty when absent (legacy < 0.41.0 manifests): callers fall
# back to constructing the URL from EFFECTIVE_BASE + bucket_path.
# ─────────────────────────────────────────────────────────────────────────────
parse_manifest() {
    local manifest_file="$1"
    python3 - "$manifest_file" <<'PYTHON'
import sys
import yaml

def get_name(entry):
    return entry['name'] if isinstance(entry, dict) else str(entry)

def get_variants(entry):
    if isinstance(entry, dict):
        return entry.get('variants', []) or []
    return []

def file_name_for(bundle_name):
    # Variant suffixes can contain dots (e.g. ".minimal-fips"); on disk the
    # file uses dashes throughout (e.g. delegate-minimal-fips.tgz).
    return bundle_name.replace('.', '-')

def emit_agent_entries(section, bucket, entry):
    """Yield (bundle_name, file_name, download_url) for every concrete tgz
    represented by one item in a single-type section's `images:` list.

    Supports both the legacy shape (one entry per image, variants listing every
    suffix, no per-variant URL) and the new 0.41.0+ shape (one entry per
    concrete bundle, variants holding a single suffix, own download_url).
    """
    if not isinstance(entry, dict):
        # Plain string image (not expected in `single` sections, but tolerate).
        yield (str(entry), str(entry), '')
        return

    name          = entry['name']
    variants      = get_variants(entry)
    variants_only = entry.get('variants_only', False)
    download_url  = entry.get('download_url', '') or ''

    if download_url:
        # New-style: this entry IS a single concrete bundle.
        if variants:
            # By convention the new manifest carries exactly one suffix here.
            for suffix in variants:
                bn = f"{name}{suffix}"
                yield (bn, file_name_for(bn), download_url)
        else:
            yield (name, file_name_for(name), download_url)
    else:
        # Legacy-style: one entry covers base + each variant; URLs are
        # constructed from EFFECTIVE_BASE at download time.
        if not variants_only:
            yield (name, file_name_for(name), '')
        for suffix in variants:
            bn = f"{name}{suffix}"
            yield (bn, file_name_for(bn), '')

def main():
    with open(sys.argv[1]) as f:
        data = yaml.safe_load(f)

    # Top-level metadata passed through to the shell as META|key|value lines.
    expires = data.get('expires_at_epoch_seconds')
    if expires is not None:
        print(f"META|expires_at_epoch_seconds|{expires}")

    modules = data.get('modules', {}) or {}

    for mod_name, cfg in modules.items():
        parent       = cfg.get('parent', '') or ''
        bundle_type  = cfg.get('bundle_type', 'combined')
        bucket_path  = cfg.get('bucket_path', mod_name)
        description  = cfg.get('description', mod_name)
        requires     = ','.join(cfg.get('requires', []) or [])
        download_url = cfg.get('download_url', '') or ''

        if parent:
            print(f"CHILD|{mod_name}|{parent}|{bucket_path}|{bundle_type}|{description}|{download_url}")
        else:
            print(f"MODULE|{mod_name}|{requires}|{bucket_path}|{bundle_type}|{description}|{download_url}")

        if bundle_type == 'single':
            for entry in cfg.get('images', []) or []:
                for bundle_name, file_name, url in emit_agent_entries(mod_name, bucket_path, entry):
                    print(f"AGENT|{mod_name}|{bucket_path}|{bundle_name}|{file_name}|{url}")

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

module_requires()     { echo "$1" | awk -F'|' -v m="$2" '$1=="MODULE" && $2==m {print $3}'; }
module_bucket()       { echo "$1" | awk -F'|' -v m="$2" '$1=="MODULE" && $2==m {print $4}'; }
module_download_url() { echo "$1" | awk -F'|' -v m="$2" '$1=="MODULE" && $2==m {print $7}'; }
child_bucket()        { echo "$1" | awk -F'|' -v c="$2" '$1=="CHILD"  && $2==c {print $4}'; }
child_parent()        { echo "$1" | awk -F'|' -v c="$2" '$1=="CHILD"  && $2==c {print $3}'; }
child_download_url()  { echo "$1" | awk -F'|' -v c="$2" '$1=="CHILD"  && $2==c {print $7}'; }
children_of()         { echo "$1" | awk -F'|' -v p="$2" '$1=="CHILD"  && $3==p {print $2}'; }
# agents_in_section: emits one line per concrete agent bundle:
#   <bundle_name>|<file_name>|<download_url>
agents_in_section()   { echo "$1" | awk -F'|' -v s="$2" '$1=="AGENT"  && $2==s {print $4 "|" $5 "|" $6}'; }
all_agent_sections()  { echo "$1" | awk -F'|' '$1=="AGENT" {print $2}' | sort -u; }
manifest_meta()       { echo "$1" | awk -F'|' -v k="$2" '$1=="META" && $2==k {print $3; exit}'; }

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
# List every concrete agent bundle name in a section. The parser has already
# expanded variants, so this is just a projection onto the bundle_name column.
# ─────────────────────────────────────────────────────────────────────────────
expand_agent_section() {
    agents_in_section "$1" "$2" | awk -F'|' '{print $1}'
}

# ─────────────────────────────────────────────────────────────────────────────
# Counters (global)
# ─────────────────────────────────────────────────────────────────────────────
DL_COUNT=0
DL_SIZE=0
DL_FAILED=0

# Heuristic: URL is a pre-signed bucket URL if it carries an expiry parameter.
url_is_signed() {
    case "$1" in
        *Expires=*|*X-Amz-Expires=*|*X-Goog-Expires=*) return 0 ;;
        *)                                             return 1 ;;
    esac
}

do_download() {
    local url="$1" dest="$2" label="$3"
    log_info "Downloading ${BOLD}${label}${RESET}"
    # Never print the full signed URL (querystring contains a signature). Print
    # just the scheme+host+path so logs don't leak credentials.
    local _display_url="$url"
    if url_is_signed "$url"; then
        _display_url="${url%%\?*}  ${DIM}(signed)${RESET}"
    fi
    printf "    ${DIM}URL: %s${RESET}\n" "$_display_url"
    local _dl_err=""
    if download_file "$url" "$dest" _dl_err; then
        local sz
        sz=$(get_file_size "$dest")
        DL_COUNT=$((DL_COUNT + 1))
        DL_SIZE=$((DL_SIZE + sz))
        log_done "Saved → ${dest}  ${DIM}($(( sz / 1024 / 1024 )) MB)${RESET}"
    else
        log_warn "Failed to download: ${BOLD}${label}${RESET}"
        if [ -n "$_dl_err" ]; then
            # Indent each line of the error for readability
            echo "$_dl_err" | while IFS= read -r _line; do
                printf "    ${RED}│${RESET} ${DIM}%s${RESET}\n" "$_line"
            done
        fi
        if url_is_signed "$url"; then
            printf "    ${RED}│${RESET} ${DIM}%s${RESET}\n" \
                "signed URL may have expired — request a fresh manifest from Harness support"
        fi
        DL_FAILED=$((DL_FAILED + 1))
    fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Resolve an effective URL: prefer manifest-provided URL, fall back to one
# constructed from EFFECTIVE_BASE + bucket path. Fails if neither is available.
# ─────────────────────────────────────────────────────────────────────────────
resolve_url() {
    local manifest_url="$1" fallback_path="$2" label="$3"
    if [ -n "$manifest_url" ]; then
        echo "$manifest_url"
        return 0
    fi
    if [ -z "$EFFECTIVE_BASE" ]; then
        log_warn "No download URL for ${label} in manifest and no --version/--url given — skipping"
        return 1
    fi
    echo "${EFFECTIVE_BASE}/${fallback_path}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Download a combined module bundle
# ─────────────────────────────────────────────────────────────────────────────
download_module() {
    local parsed="$1" mod="$2"
    local bucket manifest_url url
    bucket=$(module_bucket "$parsed" "$mod")
    [ -z "$bucket" ] && bucket="$mod"
    manifest_url=$(module_download_url "$parsed" "$mod")
    url=$(resolve_url "$manifest_url" "${bucket}/${mod}_images.tgz" "module: ${mod}") || {
        DL_FAILED=$((DL_FAILED + 1)); return;
    }
    local dest="${OUTPUT_DIR}/${bucket}/${mod}_images.tgz"
    do_download "$url" "$dest" "module: ${mod}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Download a child (sub-bundle) — combined type: one tgz for the whole section
# ─────────────────────────────────────────────────────────────────────────────
download_child() {
    local parsed="$1" child="$2"
    local bucket manifest_url url
    bucket=$(child_bucket "$parsed" "$child")
    [ -z "$bucket" ] && bucket="$child"
    manifest_url=$(child_download_url "$parsed" "$child")
    url=$(resolve_url "$manifest_url" "${bucket}/${child}_images.tgz" "sub-bundle: ${child}") || {
        DL_FAILED=$((DL_FAILED + 1)); return;
    }
    local dest="${OUTPUT_DIR}/${bucket}/${child}_images.tgz"
    do_download "$url" "$dest" "sub-bundle: ${child}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Download a single agent bundle by its full bundle name (e.g. delegate-fips,
# delegate.minimal, aqua-trivy-job-runner). The parser has already produced one
# AGENT row per concrete tgz with its file name and download_url.
# ─────────────────────────────────────────────────────────────────────────────
download_agent() {
    local parsed="$1" agent_name="$2"
    local row bucket file_name manifest_url url
    row=$(echo "$parsed" | awk -F'|' -v a="$agent_name" '$1=="AGENT" && $4==a {print; exit}')
    if [ -z "$row" ]; then
        log_warn "Agent '${agent_name}' not found in manifest — skipping"
        return
    fi
    bucket=$(echo "$row"       | awk -F'|' '{print $3}')
    file_name=$(echo "$row"    | awk -F'|' '{print $5}')
    manifest_url=$(echo "$row" | awk -F'|' '{print $6}')
    [ -z "$bucket" ] && bucket="$agent_name"
    url=$(resolve_url "$manifest_url" "${bucket}/${file_name}.tgz" "agent: ${agent_name}") || {
        DL_FAILED=$((DL_FAILED + 1)); return;
    }
    local dest="${OUTPUT_DIR}/${bucket}/${file_name}.tgz"
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
    local total="${2:-}"   # optional: total number of items in the list
    # All display output goes to stderr so it remains visible when called inside $()
    echo "" >&2
    printf "  ${BOLD}${CYAN}?${RESET} ${BOLD}%s${RESET}\n" "$msg" >&2
    echo "" >&2
    printf "  ${DIM}How to select:${RESET}\n" >&2
    printf "  ${DIM}  single item   →  1${RESET}\n" >&2
    if [ -n "$total" ] && [ "$total" -ge 3 ] 2>/dev/null; then
        local mid=$(( total / 2 ))
        local hi=$(( total < 5 ? total : 5 ))
        printf "  ${DIM}  multiple      →  1,%d,%d${RESET}\n" "$mid" "$hi" >&2
        printf "  ${DIM}  range         →  1-%d${RESET}\n" "$hi" >&2
    else
        printf "  ${DIM}  multiple      →  1,2,3${RESET}\n" >&2
        printf "  ${DIM}  range         →  1-4${RESET}\n" >&2
    fi
    printf "  ${DIM}  everything    →  all${RESET}\n" >&2
    printf "  ${DIM}  skip / none   →  none  (or press Enter)${RESET}\n" >&2
    echo "" >&2
    printf "  ${CYAN}›${RESET} " >&2
    local ans
    read -r ans </dev/tty 2>/dev/null || read -r ans
    echo "$ans"   # only the answer goes to stdout, captured by $()
}

# Print a confirmation list of items about to be downloaded
print_download_plan() {
    local label="$1"; shift
    echo ""
    printf "  ${BOLD}%s to download:${RESET}\n" "$label"
    for item in "$@"; do
        printf "    ${CYAN}•${RESET} %s\n" "$item"
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# print_selection_plan — show what will be downloaded (non-interactive / file mode).
# ─────────────────────────────────────────────────────────────────────────────
print_selection_plan() {
    local parsed="$1"
    shift
    # remaining args: space-separated lists modules_to_dl children_to_dl agents_to_dl
    local _mods="$1" _children="$2" _agents="$3"

    echo ""
    printf "  ${BOLD}Download plan:${RESET}\n"
    for _b in $_mods $_children $_agents; do
        [ -z "$_b" ] && continue
        local _desc
        _desc=$(echo "$parsed" | awk -F'|' -v n="$_b" '
            ($1=="MODULE" || $1=="CHILD") && $2==n { print $6; exit }')
        [ -z "$_desc" ] && _desc="$_b"
        printf "    ${CYAN}•${RESET} %-28s ${DIM}%s${RESET}\n" "$_b" "$_desc"
    done
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# list_bundles — print every available bundle name and exit.
# ─────────────────────────────────────────────────────────────────────────────
list_bundles() {
    local parsed="$1"
    local _ver_label="${VERSION:-${BUNDLE_URL:-${MANIFEST_FILE}}}"
    echo ""
    printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}\n"
    printf "${BOLD}${CYAN}║   Available Harness Airgap Bundles                  ║${RESET}\n"
    printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}\n"
    echo ""
    printf "${DIM}Source: %s${RESET}\n" "$_ver_label"
    printf "${DIM}Use any NAME below with: -b / --bundles NAME,NAME,...${RESET}\n"
    echo ""

    printf "${BOLD}Modules${RESET}\n"
    printf "  %-24s %-12s  %s\n" "NAME" "REQUIRES" "DESCRIPTION"
    printf "  %s\n" "──────────────────────────────────────────────────────────────"
    while IFS='|' read -r _mname _mdesc _mreqs; do
        printf "  ${GREEN}%-24s${RESET} ${DIM}%-12s${RESET}  %s\n" "$_mname" "${_mreqs:-(none)}" "$_mdesc"
    done < <(echo "$parsed" | awk -F'|' '$1=="MODULE" {print $2 "|" $6 "|" $3}' | sort -t'|' -k3 -r)
    echo ""

    printf "${BOLD}Sub-bundles${RESET}\n"
    printf "  %-24s %-12s  %s\n" "NAME" "PARENT" "DESCRIPTION"
    printf "  %s\n" "──────────────────────────────────────────────────────────────"
    local _prev_parent=""
    while IFS='|' read -r _cname _cparent _cdesc _cbtype; do
        [ "$_cbtype" = "single" ] && continue
        [ "$_cparent" != "$_prev_parent" ] && [ -n "$_prev_parent" ] && echo ""
        _prev_parent="$_cparent"
        printf "  ${YELLOW}%-24s${RESET} ${DIM}%-12s${RESET}  %s\n" "$_cname" "$_cparent" "$_cdesc"
    done < <(echo "$parsed" | awk -F'|' '$1=="CHILD" {print $2 "|" $3 "|" $6 "|" $5}' | sort -t'|' -k2,2 -k1,1)
    echo ""

    printf "${BOLD}Agents  ${DIM}(individual image archives)${RESET}\n"
    printf "  %-24s  %s\n" "NAME" "SECTION"
    printf "  %s\n" "──────────────────────────────────────────────────────────────"
    local _prev_sect=""
    while IFS='|' read -r _aname _asect; do
        [ "$_asect" != "$_prev_sect" ] && [ -n "$_prev_sect" ] && echo ""
        _prev_sect="$_asect"
        printf "  ${CYAN}%-24s${RESET}  ${DIM}%s${RESET}\n" "$_aname" "$_asect"
    done < <(echo "$parsed" | awk -F'|' '$1=="AGENT" {print $4 "|" $3}' | sort -t'|' -k2,2 -k1,1)
    echo ""

    printf "${DIM}Run --generate-selection-file (-g) to pick interactively and save a selection file.${RESET}\n"
    printf "${DIM}Run --selection-file (-s) selection.conf to download from a saved file.${RESET}\n"
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# load_selection_file — read a selection.conf and set BUNDLES_CSV.
# Format (order-independent, '#' comments stripped):
#   bundles=platform,ci,ci-plugins,delegate
# ─────────────────────────────────────────────────────────────────────────────
load_selection_file() {
    local _file="$1"
    [ ! -f "$_file" ] && log_error "Selection file not found: ${_file}" && exit 1
    log_info "Loading selections from: ${BOLD}${_file}${RESET}"
    while IFS= read -r _line; do
        _line="${_line%%#*}"
        _line="${_line#"${_line%%[![:space:]]*}"}"
        _line="${_line%"${_line##*[![:space:]]}"}"
        [ -z "$_line" ] && continue
        local _key _val
        _key="${_line%%=*}"
        _val="${_line#*=}"
        case "$_key" in
            bundles) [ -z "$BUNDLES_CSV" ] && BUNDLES_CSV="$_val" ;;
        esac
    done < "$_file"
}

# ─────────────────────────────────────────────────────────────────────────────
# checkbox_menu — interactive checkbox selector with arrow-key navigation
#
# Usage:
#   result=$(checkbox_menu "Title" "Label|value" "Label|value|dep1,dep2" ...)
#
# Item format:  "display label | value | dep_value1,dep_value2"
#   - The optional 3rd field lists values of items that should be auto-checked
#     when this item is toggled on (e.g. required dependencies).
#
# All display goes to /dev/tty so the UI is visible even inside $().
# Selected values are written to stdout, one per line.
#
# Keys:  ↑/↓ navigate   Space toggle   a all   n none   Enter confirm
# ─────────────────────────────────────────────────────────────────────────────
checkbox_menu() {
    # set -e (errexit) causes false-returning [ ] && cmd expressions to kill the
    # script. This is a UI function full of intentional short-circuits, so we
    # save the flag and disable it for the duration of the function, then restore.
    local _cbm_e=0
    case "$-" in *e*) _cbm_e=1 ;; esac
    set +e

    local _title="$1"; shift
    # _auto[i]=1 means this item was checked automatically as a dependency
    declare -a _labels _values _deps _checked _auto
    local _n=0 _i
    for _item in "$@"; do
        _labels[$_n]="${_item%%|*}"
        local _vd="${_item#*|}"          # "value"  or  "value|deps"
        if [[ "$_vd" == *"|"* ]]; then
            _values[$_n]="${_vd%%|*}"
            _deps[$_n]="${_vd#*|}"
        else
            _values[$_n]="$_vd"
            _deps[$_n]=""
        fi
        _checked[$_n]=0
        _auto[$_n]=0
        _n=$((_n + 1))
    done
    if [ "$_n" -eq 0 ]; then
        [ "$_cbm_e" = "1" ] && set -e
        return
    fi

    local _cursor=0 _drawn=0
    # Skip any leading non-selectable header rows
    while [ "$_cursor" -lt "$_n" ] && [ -z "${_values[$_cursor]}" ]; do
        _cursor=$((_cursor + 1))
    done
    local _EL=$'\033[K'   # clear to end of line — prevents stale chars when redrawing

    # ── Viewport: clamp list to terminal height so we never overdraw ──────────
    local _term_h
    _term_h=$(tput lines 2>/dev/null || echo 24)
    # Reserve lines: title block (3) + above/below indicators (2) + footer (3) = 8
    local _view_size=$(( _term_h - 8 ))
    if [ "$_view_size" -lt 3 ]; then _view_size=3; fi
    if [ "$_view_size" -gt "$_n" ]; then _view_size="$_n"; fi
    local _view_top=0

    # ── Auto-check a dep by value (only if not already manually checked) ─────
    _cm_autocheck() {
        local _dep_val="$1"
        for ((_j=0; _j<_n; _j++)); do
            if [ "${_values[$_j]}" = "$_dep_val" ] && [ "${_checked[$_j]}" = "0" ]; then
                _checked[$_j]=1
                _auto[$_j]=1
            fi
        done
    }

    # ── When unchecking item at index $1, release any auto-deps that are no
    #    longer required by another checked item ─────────────────────────────
    _cm_release_deps() {
        local _idx="$1"
        local _dep _k _d _still_needed

        for _dep in ${_deps[$_idx]//,/ }; do
            [ -z "$_dep" ] && continue
            _still_needed=0

            # Search every OTHER checked item to see if it still needs this dep
            for ((_k=0; _k<_n; _k++)); do
                [ "$_k" -eq "$_idx" ] && continue
                [ "${_checked[$_k]}" != "1" ] && continue
                for _d in ${_deps[$_k]//,/ }; do
                    if [ "$_d" = "$_dep" ]; then
                        _still_needed=1
                        break 2   # exits both for _d and for ((_k)) at once
                    fi
                done
            done

            # If nothing else needs it and it was auto-selected, release it
            if [ "$_still_needed" = "0" ]; then
                for ((_k=0; _k<_n; _k++)); do
                    if [ "${_values[$_k]}" = "$_dep" ] && [ "${_auto[$_k]}" = "1" ]; then
                        _checked[$_k]=0
                        _auto[$_k]=0
                    fi
                done
            fi
        done
    }

    # ── Terminal: raw mode + hidden cursor ───────────────────────────────────
    local _saved_tty=""
    _saved_tty=$(stty -g </dev/tty 2>/dev/null) || true
    stty -echo -icanon min 1 time 0 </dev/tty 2>/dev/null || true
    tput civis >/dev/tty 2>/dev/null || true

    _cm_restore() {
        stty "$_saved_tty" </dev/tty 2>/dev/null || true
        tput cnorm >/dev/tty 2>/dev/null || true
    }
    trap '_cm_restore; exit 130' INT
    trap '_cm_restore' EXIT

    # ── Draw / redraw the viewport ───────────────────────────────────────────
    # Total drawn height is always _view_size + 5 (constant) so cursor-up
    # always lands at the exact right position on redraw.
    _cm_draw() {
        # Scroll viewport to keep cursor visible
        if [ "$_cursor" -lt "$_view_top" ]; then
            _view_top="$_cursor"
        elif [ "$_cursor" -ge $(( _view_top + _view_size )) ]; then
            _view_top=$(( _cursor - _view_size + 1 ))
        fi

        if [ "$_drawn" -gt 0 ]; then
            printf '\033[%dA' "$_drawn" >/dev/tty
        fi
        _drawn=0

        # ── "above" indicator (always 1 line) ────────────────────────────────
        if [ "$_view_top" -gt 0 ]; then
            printf "  ${DIM}  ▲ %d more above${_EL}${RESET}\n" "$_view_top" >/dev/tty
        else
            printf "${_EL}\n" >/dev/tty
        fi
        _drawn=1

        # ── Items in viewport (always _view_size lines, padded if needed) ─────
        local _slot _idx _box _row
        for (( _slot=0; _slot<_view_size; _slot++ )); do
            _idx=$(( _view_top + _slot ))
            if [ "$_idx" -ge "$_n" ]; then
                printf "${_EL}\n" >/dev/tty   # blank padding at bottom
            else
                local _lbl="${_labels[$_idx]}"
                local _val="${_values[$_idx]}"
                if [ -z "$_val" ]; then
                    # Non-selectable header row — no checkbox, dimmed
                    printf "    ${DIM}%s${_EL}${RESET}\n" "$_lbl" >/dev/tty
                else
                    if [ "${_checked[$_idx]}" = "1" ]; then
                        if [ "${_auto[$_idx]}" = "1" ]; then _box="[↑]"; else _box="[✓]"; fi
                    else
                        _box="[ ]"
                    fi
                    if [ "$_idx" -eq "$_cursor" ]; then
                        _row="  ${CYAN}${BOLD}▶ %s  %s${_EL}${RESET}\n"
                    elif [ "${_auto[$_idx]}" = "1" ]; then
                        _row="  ${DIM}  %s  %s${_EL}${RESET}\n"
                    else
                        _row="    %s  %s${_EL}\n"
                    fi
                    printf "$_row" "$_box" "$_lbl" >/dev/tty
                fi
            fi
            _drawn=$((_drawn + 1))
        done

        # ── "below" indicator (always 1 line) ────────────────────────────────
        local _below=$(( _n - _view_top - _view_size ))
        if [ "$_below" -gt 0 ]; then
            printf "  ${DIM}  ▼ %d more below${_EL}${RESET}\n" "$_below" >/dev/tty
        else
            printf "${_EL}\n" >/dev/tty
        fi
        _drawn=$((_drawn + 1))

        # ── Footer (blank + 4 help lines = 5 lines) ──────────────────────────
        printf "\n  ${DIM}↑/↓ = navigate.${_EL}${RESET}\n" >/dev/tty
        printf "  ${DIM}Space = toggle, Enter = confirm.${_EL}${RESET}\n" >/dev/tty
        printf "  ${DIM}a = all, n = none.${_EL}${RESET}\n" >/dev/tty
        printf "  ${DIM}[↑] = auto-selected dependency.${_EL}${RESET}\n" >/dev/tty
        _drawn=$((_drawn + 5))
    }

    # Header is printed once (not part of the redraw region)
    printf "\n${BOLD}${CYAN}  %s${RESET}\n\n" "$_title" >/dev/tty
    _cm_draw

    # ── Event loop ───────────────────────────────────────────────────────────
    local _key _seq
    while true; do
        _key=""
        IFS= read -rsn1 _key </dev/tty
        case "$_key" in
            $'\x1b')
                IFS= read -rsn2 -t 1 _seq </dev/tty
                case "$_seq" in
                    '[A')  # Up — skip non-selectable (empty value) header rows
                        local _nc=$((_cursor - 1))
                        while [ "$_nc" -gt 0 ] && [ -z "${_values[$_nc]}" ]; do
                            _nc=$((_nc - 1))
                        done
                        if [ "$_nc" -ge 0 ] && [ -n "${_values[$_nc]}" ]; then
                            _cursor="$_nc"
                        fi
                        ;;
                    '[B')  # Down — skip non-selectable header rows
                        local _nc=$((_cursor + 1))
                        while [ "$_nc" -lt $((_n - 1)) ] && [ -z "${_values[$_nc]}" ]; do
                            _nc=$((_nc + 1))
                        done
                        if [ "$_nc" -lt "$_n" ] && [ -n "${_values[$_nc]}" ]; then
                            _cursor="$_nc"
                        fi
                        ;;
                esac
                ;;
            ' ')  # Toggle current item (no-op on non-selectable header rows)
                if [ -z "${_values[$_cursor]}" ]; then : ; \
                elif [ "${_checked[$_cursor]}" = "1" ]; then
                    _checked[$_cursor]=0
                    _auto[$_cursor]=0
                    # Release auto-checked deps that are no longer needed
                    if [ -n "${_deps[$_cursor]}" ]; then
                        _cm_release_deps "$_cursor"
                    fi
                else
                    _checked[$_cursor]=1
                    _auto[$_cursor]=0   # manually checked — not auto
                    # Auto-check declared dependencies
                    if [ -n "${_deps[$_cursor]}" ]; then
                        local _dep
                        for _dep in ${_deps[$_cursor]//,/ }; do
                            _cm_autocheck "$_dep"
                        done
                    fi
                fi
                ;;
            'a'|'A')
                for ((_i=0; _i<_n; _i++)); do
                    [ -n "${_values[$_i]}" ] && _checked[$_i]=1 && _auto[$_i]=0
                done
                ;;
            'n'|'N')
                for ((_i=0; _i<_n; _i++)); do _checked[$_i]=0; _auto[$_i]=0; done
                ;;
            '') break ;;  # Enter — confirm
        esac
        _cm_draw
    done

    # ── Restore terminal ─────────────────────────────────────────────────────
    _cm_restore
    trap - INT EXIT
    printf "\n" >/dev/tty

    # ── Emit selected values to stdout (captured by the caller's $()) ────────
    # Restore set -e before returning so the caller's error handling is intact
    [ "$_cbm_e" = "1" ] && set -e
    for ((_i=0; _i<_n; _i++)); do
        if [ -n "${_values[$_i]}" ] && [ "${_checked[$_i]}" = "1" ]; then
            echo "${_values[$_i]}"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
main() {
    [ -n "$SELECTION_FILE" ] && load_selection_file "$SELECTION_FILE"

    echo ""
    printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}\n"
    if [ "$LIST_ONLY" = true ]; then
        printf "${BOLD}${CYAN}║   Harness Airgap Bundle Lister                      ║${RESET}\n"
    elif [ "$GENERATE_SELECTION" = true ]; then
        printf "${BOLD}${CYAN}║   Harness Airgap — Generate Selection File          ║${RESET}\n"
    else
        printf "${BOLD}${CYAN}║   Harness Airgap Bundle Downloader                  ║${RESET}\n"
    fi
    printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}\n"
    echo ""
    if [ -n "$MANIFEST_FILE" ]; then
        log_info "Manifest      : ${BOLD}${MANIFEST_FILE}${RESET}  ${DIM}(local file)${RESET}"
    else
        log_info "Bundle source : ${BOLD}${EFFECTIVE_BASE}${RESET}"
    fi
    [ -n "$VERSION" ] && log_info "Version       : ${BOLD}${VERSION}${RESET}"
    if [ "$LIST_ONLY" = false ] && [ "$GENERATE_SELECTION" = false ]; then
        log_info "Output dir    : ${BOLD}${OUTPUT_DIR}${RESET}"
        mkdir -p "$OUTPUT_DIR"
    fi
    if [ "$GENERATE_SELECTION" = true ]; then
        local _sel_out="${SELECTION_OUTPUT_FILE:-selection.conf}"
        log_info "Selection file: ${BOLD}${_sel_out}${RESET}  ${DIM}(no download will be performed)${RESET}"
    fi

    # ── Load manifest ─────────────────────────────────────────────────────────
    local tmp_manifest
    if [ -n "$MANIFEST_FILE" ]; then
        # Local file provided (required for >= 0.41.0).
        if [ ! -f "$MANIFEST_FILE" ]; then
            log_error "Manifest file not found: ${MANIFEST_FILE}"
            exit 1
        fi
        if [ ! -s "$MANIFEST_FILE" ]; then
            log_error "Manifest file is empty: ${MANIFEST_FILE}"
            exit 1
        fi
        tmp_manifest="$MANIFEST_FILE"
        log_done "Manifest loaded from local file"
    else
        tmp_manifest=$(mktemp)
        trap "rm -f ${tmp_manifest}" EXIT

        local manifest_url="${EFFECTIVE_BASE}/bundle-manifest.yaml"
        log_info "Fetching manifest → ${manifest_url}"
        local _manifest_err=""
        if ! download_file "$manifest_url" "$tmp_manifest" _manifest_err || [ ! -s "$tmp_manifest" ]; then
            log_warn "Manifest not found at bundle source."
            if [ -n "$_manifest_err" ]; then
                echo "$_manifest_err" | while IFS= read -r _line; do
                    printf "    ${RED}│${RESET} ${DIM}%s${RESET}\n" "$_line"
                done
            fi
            if [ -n "$VERSION" ]; then
                local github_manifest_url="https://raw.githubusercontent.com/harness/helm-charts/${VERSION}/src/bundle-manifest.yaml"
                log_info "Trying GitHub fallback → ${github_manifest_url}"
                rm -f "$tmp_manifest"; tmp_manifest=$(mktemp)
                local _gh_err=""
                if ! download_file "$github_manifest_url" "$tmp_manifest" _gh_err || [ ! -s "$tmp_manifest" ]; then
                    log_error "Manifest not found on GitHub either."
                    if [ -n "$_gh_err" ]; then
                        echo "$_gh_err" | while IFS= read -r _line; do
                            printf "    ${RED}│${RESET} ${DIM}%s${RESET}\n" "$_line"
                        done
                    fi
                    log_error "  Checked: ${manifest_url}"
                    log_error "  Checked: ${github_manifest_url}"
                    log_error "If this is a ${MANIFEST_REQUIRED_VERSION}+ release, request the manifest"
                    log_error "from Harness support and pass it with --manifest-file."
                    exit 1
                fi
                log_done "Manifest loaded from GitHub (harness-${VERSION})"
            else
                log_error "Manifest not found at the provided --url."
                log_error "  Checked: ${manifest_url}"
                log_error "GitHub fallback is only available with --version."
                log_error "If this is a ${MANIFEST_REQUIRED_VERSION}+ release, request the manifest"
                log_error "from Harness support and pass it with --manifest-file."
                exit 1
            fi
        fi
        [ ! -s "$tmp_manifest" ] && log_error "Manifest is empty" && exit 1
        log_done "Manifest loaded successfully"
    fi

    local parsed
    parsed=$(parse_manifest "$tmp_manifest")

    # ── Signed-URL expiry check ───────────────────────────────────────────────
    # New-format manifests carry a top-level expires_at_epoch_seconds equal to
    # the signed-URL Expires= timestamp. Warn the user before they waste time.
    local _expires_at _now _seconds_left
    _expires_at=$(manifest_meta "$parsed" "expires_at_epoch_seconds")
    if [ -n "$_expires_at" ] && [[ "$_expires_at" =~ ^[0-9]+$ ]]; then
        _now=$(date +%s)
        _seconds_left=$(( _expires_at - _now ))
        if [ "$_seconds_left" -le 0 ]; then
            log_error "This manifest's signed URLs EXPIRED $(( -_seconds_left / 3600 )) hour(s) ago."
            log_error "Request a fresh manifest from Harness support before proceeding."
            # Non-fatal for --list / --generate-selection-file; fatal for actual downloads.
            if [ "$LIST_ONLY" = false ] && [ "$GENERATE_SELECTION" = false ]; then
                exit 1
            fi
        elif [ "$_seconds_left" -lt 3600 ]; then
            log_warn "Signed URLs in this manifest expire in $(( _seconds_left / 60 )) minute(s)."
            log_warn "Downloads may fail partway through. Consider requesting a fresh manifest."
        elif [ "$_seconds_left" -lt 86400 ]; then
            log_warn "Signed URLs in this manifest expire in $(( _seconds_left / 3600 )) hour(s)."
        fi
    fi

    if [ "$LIST_ONLY" = true ]; then
        list_bundles "$parsed"
        exit 0
    fi

    # ── Build the flat universe of every selectable name ─────────────────────
    # Order: platform first (no requires), then modules with deps, each followed
    # by their children (combined sub-bundles, then agent sections with variants).
    #
    # Each checkbox_menu item: "LABEL|VALUE|DEPS"
    # Agent-section rows are header-only (non-selectable): VALUE="" so checkbox_menu
    # emits nothing for them and they can never be "selected" themselves.
    declare -a _universe_items   # items for checkbox_menu
    declare -a _universe_values  # parallel: just the values (for 'all' expansion)

    local _ui=0

    # Sort modules: empty requires first (platform), then by requires length ascending.
    # awk prints "name|requires", sort -t'|' -k2 puts empty string first.
    local _mod_order
    _mod_order=$(echo "$parsed" | awk -F'|' '$1=="MODULE" {print $2 "|" $3}' | sort -t'|' -k2,2 | awk -F'|' '{print $1}')

    while IFS= read -r _mname; do
        [ -z "$_mname" ] && continue
        local _mdesc _mreqs _mlabel
        _mdesc=$(echo "$parsed" | awk -F'|' -v m="$_mname" '$1=="MODULE" && $2==m {print $6}')
        _mreqs=$(echo "$parsed" | awk -F'|' -v m="$_mname" '$1=="MODULE" && $2==m {print $3}')
        _mlabel="${_mname}  —  ${_mdesc}"
        [ -n "$_mreqs" ] && _mlabel="${_mlabel}  ${DIM}(requires: ${_mreqs})${RESET}"
        _universe_items[$_ui]="${_mlabel}|${_mname}|${_mreqs}"
        _universe_values[$_ui]="$_mname"
        _ui=$((_ui + 1))

        # Children of this module — combined sub-bundles first, then single (agents section)
        while IFS= read -r _cname; do
            [ -z "$_cname" ] && continue
            local _cdesc _cbtype
            _cdesc=$(echo "$parsed" | awk -F'|' -v c="$_cname" '$1=="CHILD" && $2==c {print $6}')
            _cbtype=$(echo "$parsed" | awk -F'|' -v c="$_cname" '$1=="CHILD" && $2==c {print $5}')
            if [ "$_cbtype" = "single" ]; then
                # Agent section: non-selectable header row (VALUE is empty so nothing emitted)
                _universe_items[$_ui]="  ↳ ${_cdesc}  ${DIM}[agents]${RESET}||"
                _universe_values[$_ui]=""   # not selectable
                _ui=$((_ui + 1))
                # One concrete agent bundle per row — parser already expanded variants.
                while IFS='|' read -r _aname _afname _aurl; do
                    _universe_items[$_ui]="    ↳ ${_aname}|${_aname}|"
                    _universe_values[$_ui]="$_aname"
                    _ui=$((_ui + 1))
                done < <(agents_in_section "$parsed" "$_cname")
            else
                _universe_items[$_ui]="  ↳ ${_cname}  —  ${_cdesc}|${_cname}|"
                _universe_values[$_ui]="$_cname"
                _ui=$((_ui + 1))
            fi
        done < <(children_of "$parsed" "$_mname")
    done <<< "$_mod_order"

    # ── Resolve BUNDLES_CSV or run interactive menu ───────────────────────────
    local selected_values=""   # space-separated list of selected names

    if [ -n "$BUNDLES_CSV" ]; then
        # Non-interactive / selection-file path
        local _bundles_lower
        _bundles_lower=$(echo "$BUNDLES_CSV" | tr '[:upper:]' '[:lower:]')
        if [ "$_bundles_lower" = "all" ]; then
            for _v in "${_universe_values[@]}"; do
                [ -n "$_v" ] && selected_values="${selected_values} ${_v}"
            done
        else
            IFS=',' read -ra _req <<< "$BUNDLES_CSV"
            for _r in "${_req[@]}"; do
                _r="${_r// /}"
                [ -n "$_r" ] && selected_values="${selected_values} ${_r}"
            done
        fi
    elif [ "$NON_INTERACTIVE" = false ]; then
        # ── Step 1: select modules ────────────────────────────────────────────
        declare -a _mod_items
        local _mi=0
        while IFS= read -r _mname; do
            [ -z "$_mname" ] && continue
            local _mdesc2 _mreqs2 _ml2
            _mdesc2=$(echo "$parsed" | awk -F'|' -v m="$_mname" '$1=="MODULE" && $2==m {print $6}')
            _mreqs2=$(echo "$parsed" | awk -F'|' -v m="$_mname" '$1=="MODULE" && $2==m {print $3}')
            _ml2="${_mname}  —  ${_mdesc2}"
            [ -n "$_mreqs2" ] && _ml2="${_ml2}  ${DIM}(requires: ${_mreqs2})${RESET}"
            _mod_items[$_mi]="${_ml2}|${_mname}|${_mreqs2}"
            _mi=$((_mi + 1))
        done <<< "$_mod_order"

        local _sel_mods=""
        _sel_mods=$(checkbox_menu "Step 1 of 3 — Select modules" "${_mod_items[@]}")

        local _picked_modules=""
        while IFS= read -r _v; do
            [ -n "$_v" ] && _picked_modules="${_picked_modules} ${_v}"
        done <<< "$_sel_mods"

        # Resolve module deps so step 2/3 includes children of auto-added deps
        local _resolved_for_menu=""
        if [ -n "$(echo "$_picked_modules" | tr -d ' ')" ]; then
            local _pm_csv
            _pm_csv=$(echo "$_picked_modules" | tr ' ' ',' | sed 's/^,//')
            _resolved_for_menu=$(resolve_modules "$parsed" "$_pm_csv")
        fi

        for _m in $_resolved_for_menu; do
            selected_values="${selected_values} ${_m}"
        done

        # ── Step 2: combined sub-bundles from all resolved modules (one menu) ─
        declare -a _combined_items
        local _ci=0
        for _m in $_resolved_for_menu; do
            while IFS= read -r _cname; do
                [ -z "$_cname" ] && continue
                local _cbt2
                _cbt2=$(echo "$parsed" | awk -F'|' -v c="$_cname" '$1=="CHILD" && $2==c {print $5}')
                [ "$_cbt2" != "combined" ] && continue
                local _cdesc2
                _cdesc2=$(echo "$parsed" | awk -F'|' -v c="$_cname" '$1=="CHILD" && $2==c {print $6}')
                _combined_items[$_ci]="${_cname}  —  ${_cdesc2}  ${DIM}[${_m}]${RESET}|${_cname}|"
                _ci=$((_ci + 1))
            done < <(children_of "$parsed" "$_m")
        done

        if [ "$_ci" -gt 0 ]; then
            local _sel_combined=""
            _sel_combined=$(checkbox_menu "Step 2 of 3 — Select sub-bundles  (optional)" "${_combined_items[@]}")
            while IFS= read -r _v; do
                [ -n "$_v" ] && selected_values="${selected_values} ${_v}"
            done <<< "$_sel_combined"
        fi

        # ── Step 3: agent variants — one menu per agent section across resolved modules ─
        local _agent_step=1
        local _total_agent_sections=0
        for _m in $_resolved_for_menu; do
            while IFS= read -r _cname; do
                [ -z "$_cname" ] && continue
                local _cbt3
                _cbt3=$(echo "$parsed" | awk -F'|' -v c="$_cname" '$1=="CHILD" && $2==c {print $5}')
                [ "$_cbt3" = "single" ] && _total_agent_sections=$((_total_agent_sections + 1))
            done < <(children_of "$parsed" "$_m")
        done

        for _m in $_resolved_for_menu; do
            while IFS= read -r _cname; do
                [ -z "$_cname" ] && continue
                local _cbt4
                _cbt4=$(echo "$parsed" | awk -F'|' -v c="$_cname" '$1=="CHILD" && $2==c {print $5}')
                [ "$_cbt4" != "single" ] && continue

                local _cdesc4
                _cdesc4=$(echo "$parsed" | awk -F'|' -v c="$_cname" '$1=="CHILD" && $2==c {print $6}')

                declare -a _agent_items
                local _ai=0
                # One concrete agent bundle per row — parser already expanded variants.
                while IFS='|' read -r _aname _afname _aurl; do
                    _agent_items[$_ai]="${_aname}|${_aname}|"
                    _ai=$((_ai + 1))
                done < <(agents_in_section "$parsed" "$_cname")

                if [ "$_ai" -gt 0 ]; then
                    local _sel_agents=""
                    _sel_agents=$(checkbox_menu \
                        "Step 3 of 3 — ${_cdesc4}  [${_m}]  (${_agent_step}/${_total_agent_sections}, optional)" \
                        "${_agent_items[@]}")
                    while IFS= read -r _v; do
                        [ -n "$_v" ] && selected_values="${selected_values} ${_v}"
                    done <<< "$_sel_agents"
                    _agent_step=$((_agent_step + 1))
                    unset _agent_items
                fi
            done < <(children_of "$parsed" "$_m")
        done

        BUNDLES_CSV=$(echo "$selected_values" | tr ' ' ',' | sed 's/^,//;s/,$//')
    fi

    # ── Classify selected names into modules / children / agents ─────────────
    # Modules get dependency-resolved; children and agents are taken as-is.
    local raw_modules="" children_to_dl="" agents_to_dl=""

    for _sel in $selected_values; do
        _sel="${_sel// /}"
        [ -z "$_sel" ] && continue
        if echo "$parsed" | grep -q "^MODULE|${_sel}|"; then
            raw_modules="${raw_modules} ${_sel}"
        elif echo "$parsed" | grep -q "^CHILD|${_sel}|"; then
            local _btype
            _btype=$(echo "$parsed" | awk -F'|' -v c="$_sel" '$1=="CHILD" && $2==c {print $5}')
            if [ "$_btype" = "single" ]; then
                # This is an agent-section name, not a downloadable bundle itself — skip;
                # the user should pick individual agent variants instead.
                log_warn "'${_sel}' is an agent section, not a downloadable bundle. Select specific agent names (e.g. delegate, upgrader)."
            else
                children_to_dl="${children_to_dl} ${_sel}"
            fi
        else
            # Assume agent variant name
            agents_to_dl="${agents_to_dl} ${_sel}"
        fi
    done

    # Resolve module dependencies (adds required modules not yet in the list)
    local resolved_modules=""
    if [ -n "$raw_modules" ]; then
        local _mcsv
        _mcsv=$(echo "$raw_modules" | tr ' ' ',' | sed 's/^,//')
        resolved_modules=$(resolve_modules "$parsed" "$_mcsv")
    fi

    # Show summary
    local all_selected="${resolved_modules} ${children_to_dl} ${agents_to_dl}"
    if [ -n "$(echo "$all_selected" | tr -d ' ')" ]; then
        local _display
        _display=$(echo "$all_selected" | tr ' ' ',' | sed 's/^,//;s/,$//')
        log_info "Bundles to download: ${BOLD}${_display}${RESET}"
        if [ "$NON_INTERACTIVE" = true ] || [ -n "${SELECTION_FILE:-}" ]; then
            print_selection_plan "$parsed" "$resolved_modules" "$children_to_dl" "$agents_to_dl"
        fi
    else
        log_skip "Nothing selected"
    fi

    # ── Download phase ────────────────────────────────────────────────────────
    if [ "$GENERATE_SELECTION" = false ]; then
        log_step "Starting downloads"

        if [ -n "$resolved_modules" ]; then
            # shellcheck disable=SC2086
            print_download_plan "Modules" $resolved_modules
            log_step "Downloading module bundles"
            for mod in $resolved_modules; do
                mod="${mod// /}"
                [ -z "$mod" ] && continue
                echo "$parsed" | grep -q "^MODULE|${mod}|" && download_module "$parsed" "$mod"
            done
        fi

        if [ -n "$children_to_dl" ]; then
            # shellcheck disable=SC2086
            print_download_plan "Sub-bundles" $children_to_dl
            log_step "Downloading sub-bundles"
            for child in $children_to_dl; do
                child="${child// /}"
                [ -z "$child" ] && continue
                download_child "$parsed" "$child"
            done
        fi

        if [ -n "$agents_to_dl" ]; then
            # shellcheck disable=SC2086
            print_download_plan "Agents" $agents_to_dl
            log_step "Downloading agents"
            for agent in $agents_to_dl; do
                agent="${agent// /}"
                [ -z "$agent" ] && continue
                download_agent "$parsed" "$agent"
            done
        fi

        if [ -z "$resolved_modules" ] && [ -z "$children_to_dl" ] && [ -z "$agents_to_dl" ]; then
            log_skip "No bundles selected"
        fi
    fi

    # ── Write selection file ──────────────────────────────────────────────────
    if [ "$GENERATE_SELECTION" = true ]; then
        local _sel_out="${SELECTION_OUTPUT_FILE:-selection.conf}"
        local _abs_sel_out
        case "$_sel_out" in
            /*) _abs_sel_out="$_sel_out" ;;
            *)  _abs_sel_out="$PWD/$_sel_out" ;;
        esac

        local _bundles_out
        _bundles_out=$(echo "$BUNDLES_CSV" | sed 's/^,//;s/,$//')

        # Header shows whichever bundle-source the user provided.
        local _source_label="${VERSION:-${BUNDLE_URL:-${MANIFEST_FILE:-unknown}}}"

        # The follow-up command template mirrors the bundle source used here:
        # prefer --manifest-file if present, else --version, else --url.
        local _source_flags
        if [ -n "$MANIFEST_FILE" ]; then
            _source_flags="--manifest-file ${MANIFEST_FILE}"
        elif [ -n "$VERSION" ]; then
            _source_flags="--version ${VERSION}"
        else
            _source_flags="--url ${BUNDLE_URL}"
        fi

        cat > "$_abs_sel_out" <<EOF
# Harness Airgap Bundle Selection File
# Generated: $(date '+%Y-%m-%d %H:%M:%S')  source: ${_source_label}
# ──────────────────────────────────────────────────────────────────────────────
# Use with:
#   ./download-airgap-bundles.sh ${_source_flags} --output-dir ./bundles \\
#       --selection-file ${_abs_sel_out}
# ──────────────────────────────────────────────────────────────────────────────
# bundles: comma-separated list of bundle names (modules, sub-bundles, agents),
#          or 'all'.  Run --list to see all available names.

bundles=${_bundles_out:-none}
EOF
        echo ""
        printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}\n"
        printf "${BOLD}${CYAN}║   Selection File Written                             ║${RESET}\n"
        printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}\n"
        printf "  ${GREEN}✓ Saved to${RESET} : ${BOLD}%s${RESET}\n" "$_abs_sel_out"
        printf "  ${CYAN}  Bundles${RESET}   : ${BOLD}%s${RESET}\n" "$_bundles_out"
        echo ""
        printf "  ${DIM}To download, run:${RESET}\n"
        printf "  ${BOLD}./download-airgap-bundles.sh %s --output-dir ./bundles \\\\\n" "$_source_flags"
        printf "      --selection-file %s${RESET}\n" "$_abs_sel_out"
        echo ""
        exit 0
    fi

    # ── Download summary ──────────────────────────────────────────────────────
    local total_mb=$(( DL_SIZE / 1024 / 1024 ))
    echo ""
    printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}\n"
    printf "${BOLD}${CYAN}║   Download Summary                                   ║${RESET}\n"
    printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}\n"
    printf "  ${GREEN}✓ Downloaded${RESET} : ${BOLD}%d${RESET} bundle(s)\n" "$DL_COUNT"
    if [ "$DL_FAILED" -gt 0 ]; then
        printf "  ${RED}✗ Failed${RESET}     : ${BOLD}%d${RESET} bundle(s)\n" "$DL_FAILED"
    fi
    printf "  ${CYAN}≈ Total size${RESET} : ${BOLD}%d MB${RESET}\n" "$total_mb"
    printf "  ${CYAN}  Saved to${RESET}   : ${BOLD}%s${RESET}\n" "$OUTPUT_DIR"
    echo ""
    [ "$DL_FAILED" -gt 0 ] && exit 1
    exit 0
}

main "$@"
