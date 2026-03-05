#!/usr/bin/env bash
#
# download-airgap-bundles.sh
#
# Download airgap bundles for Harness Self-Managed Platform with full manifest
# awareness:
#   - Root modules (combined bundles, e.g. platform, ci, sto)
#   - Sub-bundles attached to a parent (e.g. ci/plugins, sto/scanners)
#   - Single-image bundles (e.g. platform/agents: delegate, upgrader)
#     with variant awareness (delegate-fips, delegate.minimal, etc.)
#
# Usage:
#   # With version (uses default GCS bucket):
#   ./download-airgap-bundles.sh \
#     --version 0.37.0 \
#     --output-dir ./airgap-bundles
#
#   # With a custom/self-hosted bundle URL:
#   ./download-airgap-bundles.sh \
#     --url https://my-mirror.example.com/bundles/harness-0.37.0 \
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

${BOLD}Required inputs:${RESET}
  --version VERSION    Harness release version  (e.g. 0.37.0)
                         ${DIM}Uses default GCS bucket: ${DEFAULT_BASE_URL}${RESET}
  --url URL            Complete base URL to the release directory
                         ${DIM}(alternative to --version, for self-hosted mirrors)${RESET}
  --output-dir PATH    Directory to save downloaded bundles  ${DIM}(not needed with --list)${RESET}

${BOLD}Non-interactive mode also requires:${RESET}
  --modules LIST       Comma-separated modules   (e.g. platform,ci,sto)
  --agents LIST        Comma-separated agents    (e.g. delegate,upgrader)
                         ${DIM}At least one of --modules or --agents must be provided.${RESET}

${BOLD}Quick start:${RESET}
  # See what is available before choosing what to download:
  ./download-airgap-bundles.sh --version 0.37.0 --list

  # Pick interactively and save to a file (no download yet):
  ./download-airgap-bundles.sh --version 0.37.0 --generate-selection-file

  # Then download using that saved file:
  ./download-airgap-bundles.sh --version 0.37.0 --output-dir ./bundles --selection-file selection.conf

Run ${BOLD}./download-airgap-bundles.sh --help${RESET} for full usage and examples.
EOF
    exit 1
}

usage() {
    cat <<EOF
${BOLD}Usage:${RESET} download-airgap-bundles.sh [OPTIONS]

${BOLD}Bundle source (one required):${RESET}
  --version VERSION    Harness release version (e.g. 0.37.0 or harness-0.37.0).
                       Uses the default GCS bucket:
                         ${DEFAULT_BASE_URL}
  --url URL            Complete base URL to the release directory.
                       Use this for self-hosted mirrors or non-standard paths.
                         e.g. https://my-mirror.example.com/bundles/harness-0.37.0

${BOLD}Output:${RESET}
  --output-dir PATH    Directory to save downloaded bundles (required, except for --list).

${BOLD}Listing available bundles:${RESET}
  --list               Print all available modules, sub-bundles and agents from the
                       manifest, then exit. No download is performed.
                       Also prints a selection file template you can save and reuse.

${BOLD}Selection file (recommended for repeated / automated use):${RESET}
  --selection-file PATH  Path to a plain-text file specifying what to download.
                         Run --generate-selection-file to create one interactively.
                         Format:
                           modules=cdng,ci,platform
                           sub-bundles=cdng-agents,ci-plugins,delegate,upgrader
                                       # combined bundles AND agent images in one key
                                       # or: all / none
                         CLI flags (--modules, --sub-bundles, --agents) override file values.

${BOLD}Module selection:${RESET}
  --modules LIST       Comma-separated module names (e.g. ci,sto,platform).
                       Dependencies are resolved automatically.
                       Omit in interactive mode to pick from an arrow-key menu.

${BOLD}Sub-bundle selection (non-interactive only):${RESET}
  --sub-bundles LIST   Comma-separated sub-bundle names, or 'all' / 'none'.
                       Run --list to see available sub-bundle names.
                       In interactive mode, a menu is shown automatically.

${BOLD}Agent selection:${RESET}
  --agents LIST        Comma-separated agent names, or 'all' / 'none'.
                         delegate            → base delegate bundle only
                         delegate-fips       → FIPS variant
                         delegate.minimal    → minimal variant
                         all                 → every agent variant
                       Omit in interactive mode to pick from an arrow-key menu.

${BOLD}Flags:${RESET}
  --non-interactive          Skip all prompts. Requires --modules and/or --agents.
  --generate-selection-file [FILE]  Run the interactive selection UI but write a selection
                                    file instead of downloading anything.
                                    Defaults to selection.conf in the current directory.
  -h, --help                        Show this help.

${BOLD}Examples:${RESET}
  # See what modules / sub-bundles / agents are available:
  ./download-airgap-bundles.sh --version 0.37.0 --list

  # Pick what to download via interactive menus, save as a selection file:
  ./download-airgap-bundles.sh --version 0.37.0 --generate-selection-file my-selection.conf

  # Interactive: pick everything from arrow-key menus
  ./download-airgap-bundles.sh \\
    --version 0.37.0 --output-dir ./bundles

  # Non-interactive via selection file (generate template with --list first):
  ./download-airgap-bundles.sh \\
    --version 0.37.0 --output-dir ./bundles --selection-file selection.conf

  # Non-interactive: ci + sto with specific sub-bundles, no agents
  ./download-airgap-bundles.sh \\
    --version 0.37.0 --output-dir ./bundles \\
    --modules ci,sto --sub-bundles sto-scanners --agents none --non-interactive

  # Download only agents
  ./download-airgap-bundles.sh \\
    --version 0.37.0 --output-dir ./bundles \\
    --agents delegate,delegate-fips,upgrader --non-interactive

  # Download ci module + all sub-bundles + all agents
  ./download-airgap-bundles.sh \\
    --version 0.37.0 --output-dir ./bundles \\
    --modules ci --sub-bundles all --agents all --non-interactive

  # Self-hosted mirror
  ./download-airgap-bundles.sh \\
    --url https://my-mirror.example.com/bundles/harness-0.37.0 \\
    --output-dir ./bundles --modules platform --non-interactive
EOF
    exit 0
}

# ─────────────────────────────────────────────────────────────────────────────
# Argument parsing
# ─────────────────────────────────────────────────────────────────────────────
VERSION=""
BUNDLE_URL=""
MODULES_CSV=""
OUTPUT_DIR=""
SUB_BUNDLES_CSV=""       # replaces --include-children / --include-bundles
AGENTS_CSV=""
COMBINED_SUBS_CSV=""     # loaded from selection file 'sub-bundles=' key; classified after manifest load
NON_INTERACTIVE=false
SELECTION_FILE=""        # --selection-file: read modules/sub-bundles/agents from a file
LIST_ONLY=false          # --list: print available bundles and exit (no download)
GENERATE_SELECTION=false # --generate-selection-file: run interactive UI, write selection file, no download
SELECTION_OUTPUT_FILE="" # output path for --generate-selection-file (default: ./selection.conf)

while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)             usage ;;
        --version)             VERSION="$2";               shift 2 ;;
        --url)                 BUNDLE_URL="$2";            shift 2 ;;
        --modules)             MODULES_CSV="$2";           shift 2 ;;
        --output-dir)          OUTPUT_DIR="$2";            shift 2 ;;
        --sub-bundles)         SUB_BUNDLES_CSV="$2";       shift 2 ;;
        --agents)              AGENTS_CSV="$2";            shift 2 ;;
        --non-interactive)     NON_INTERACTIVE=true;       shift   ;;
        --selection-file)      SELECTION_FILE="$2";        shift 2 ;;
        --list)                LIST_ONLY=true;             shift   ;;
        --generate-selection-file)
            GENERATE_SELECTION=true
            # Optional value: if the next token exists and is not a flag, treat it as the output path
            if [ -n "${2:-}" ] && [[ "${2:-}" != --* ]]; then
                SELECTION_OUTPUT_FILE="$2"; shift 2
            else
                shift
            fi
            ;;
        # Kept for backward compatibility — map to --sub-bundles
        --include-children)    SUB_BUNDLES_CSV="$2";       shift 2 ;;
        --include-bundles)     SUB_BUNDLES_CSV="${SUB_BUNDLES_CSV:+${SUB_BUNDLES_CSV},}$2"; shift 2 ;;
        *)
            log_error "Unknown option: $1"
            usage_short
            ;;
    esac
done

# Validate bundle source
if [ -z "$VERSION" ] && [ -z "$BUNDLE_URL" ]; then
    log_error "Bundle source is required: provide --version or --url"
    usage_short
fi
if [ -n "$VERSION" ] && [ -n "$BUNDLE_URL" ]; then
    log_error "--version and --url are mutually exclusive; use one or the other"
    usage_short
fi
# --output-dir is required except for --list and --generate-selection-file (no download)
if [ -z "$OUTPUT_DIR" ] && [ "$LIST_ONLY" = false ] && [ "$GENERATE_SELECTION" = false ]; then
    log_error "Missing required argument: --output-dir"
    usage_short
fi
if [ -z "$MODULES_CSV" ] && [ -z "$AGENTS_CSV" ] && [ "$NON_INTERACTIVE" = true ] \
        && [ "$LIST_ONLY" = false ] && [ "$GENERATE_SELECTION" = false ]; then
    log_error "Non-interactive mode requires --modules and/or --agents"
    usage_short
fi

# Derive EFFECTIVE_BASE — every URL in the script is ${EFFECTIVE_BASE}/<path>
if [ -n "$BUNDLE_URL" ]; then
    EFFECTIVE_BASE="${BUNDLE_URL%/}"
else
    # Normalise: strip any "harness-" prefix so we always control the format
    VERSION="${VERSION#harness-}"
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

module_requires()   { echo "$1" | awk -F'|' -v m="$2" '$1=="MODULE" && $2==m {print $3}'; }
module_bucket()     { echo "$1" | awk -F'|' -v m="$2" '$1=="MODULE" && $2==m {print $4}'; }
child_bucket()      { echo "$1" | awk -F'|' -v c="$2" '$1=="CHILD"  && $2==c {print $4}'; }
child_parent()      { echo "$1" | awk -F'|' -v c="$2" '$1=="CHILD"  && $2==c {print $3}'; }
children_of()       { echo "$1" | awk -F'|' -v p="$2" '$1=="CHILD"  && $3==p {print $2}'; }
agents_in_section() { echo "$1" | awk -F'|' -v s="$2" '$1=="AGENT"  && $2==s {print $4 "|" $5}'; }
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
# Counters (global)
# ─────────────────────────────────────────────────────────────────────────────
DL_COUNT=0
DL_SIZE=0
DL_FAILED=0

do_download() {
    local url="$1" dest="$2" label="$3"
    log_info "Downloading ${BOLD}${label}${RESET}"
    printf "    ${DIM}URL: %s${RESET}\n" "$url"
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
    local url="${EFFECTIVE_BASE}/${bucket}/${mod}_images.tgz"
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
    local url="${EFFECTIVE_BASE}/${bucket}/${child}_images.tgz"
    local dest="${OUTPUT_DIR}/${bucket}/${child}_images.tgz"
    do_download "$url" "$dest" "sub-bundle: ${child}"
}

# ─────────────────────────────────────────────────────────────────────────────
# Download a single agent bundle by its full name (e.g. delegate-fips)
# ─────────────────────────────────────────────────────────────────────────────
download_agent() {
    local parsed="$1" agent_name="$2"
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
    local url="${EFFECTIVE_BASE}/${bucket}/${agent_name}.tgz"
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
# print_selection_plan — show what will be downloaded per module.
# Called after module resolution when selections come from a file / CLI flags.
# ─────────────────────────────────────────────────────────────────────────────
print_selection_plan() {
    local parsed="$1" modules="$2"
    echo ""
    printf "  ${BOLD}Download plan:${RESET}\n"

    local mod
    for mod in $modules; do
        mod="${mod// /}"
        [ -z "$mod" ] && continue

        local mod_desc
        mod_desc=$(echo "$parsed" | awk -F'|' -v m="$mod" '$1=="MODULE" && $2==m {print $6}')

        printf "\n  ${CYAN}${BOLD}  %-18s${RESET} ${DIM}%s${RESET}\n" "$mod" "$mod_desc"

        local _has_extras=false

        # ── Combined sub-bundles belonging to this module ─────────────────────
        while IFS= read -r child; do
            [ -z "$child" ] && continue
            local btype
            btype=$(echo "$parsed" | awk -F'|' -v c="$child" '$1=="CHILD" && $2==c {print $5}')
            [ "$btype" = "single" ] && continue

            local _inc=false
            if [ "$SUB_BUNDLES_CSV" = "all" ]; then
                _inc=true
            elif [ -n "${SUB_BUNDLES_CSV:-}" ] && [ "$SUB_BUNDLES_CSV" != "none" ]; then
                echo ",${SUB_BUNDLES_CSV}," | grep -qF ",${child}," && _inc=true
            fi

            if [ "$_inc" = true ]; then
                local cdesc
                cdesc=$(echo "$parsed" | awk -F'|' -v c="$child" '$1=="CHILD" && $2==c {print $6}')
                printf "    ${DIM}├─ %-20s  %s${RESET}\n" "$child" "$cdesc"
                _has_extras=true
            fi
        done < <(children_of "$parsed" "$mod")

        # ── Agent sections belonging to this module ───────────────────────────
        while IFS= read -r sec; do
            [ -z "$sec" ] && continue
            local btype
            btype=$(echo "$parsed" | awk -F'|' -v c="$sec" '$1=="CHILD" && $2==c {print $5}')
            [ "$btype" != "single" ] && continue

            local sec_desc
            sec_desc=$(echo "$parsed" | awk -F'|' -v c="$sec" '$1=="CHILD" && $2==c {print $6}')

            local _sec_agents=""
            while IFS='|' read -r aname asuffixes; do
                # base image
                if [ "$AGENTS_CSV" = "all" ] || echo ",${AGENTS_CSV:-}," | grep -qF ",${aname},"; then
                    _sec_agents="${_sec_agents:+${_sec_agents}, }${aname}"
                fi
                # variant images
                if [ -n "$asuffixes" ]; then
                    local _sv _s
                    IFS=',' read -ra _sv <<< "$asuffixes"
                    for _s in "${_sv[@]}"; do
                        local vn="${aname}${_s}"
                        if [ "$AGENTS_CSV" = "all" ] || echo ",${AGENTS_CSV:-}," | grep -qF ",${vn},"; then
                            _sec_agents="${_sec_agents:+${_sec_agents}, }${vn}"
                        fi
                    done
                fi
            done < <(agents_in_section "$parsed" "$sec")

            if [ -n "$_sec_agents" ]; then
                printf "    ${DIM}├─ %-20s  %s${RESET}\n" "$sec_desc" "$_sec_agents"
                _has_extras=true
            fi
        done < <(children_of "$parsed" "$mod")

        if [ "$_has_extras" = false ]; then
            printf "    ${DIM}└─ (base bundle only)${RESET}\n"
        fi
    done
    echo ""
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
                printf "$_row" "$_box" "${_labels[$_idx]}" >/dev/tty
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

        # ── Footer (blank + nav hint + legend = 3 lines) ─────────────────────
        printf "\n  ${DIM}↑/↓ navigate  Space toggle  a all  n none  Enter confirm${_EL}${RESET}\n" >/dev/tty
        printf "  ${DIM}[↑] = auto-selected required dependency${_EL}${RESET}\n" >/dev/tty
        _drawn=$((_drawn + 3))
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
                    '[A')  # Up
                        if [ "$_cursor" -gt 0 ]; then _cursor=$((_cursor - 1)); fi
                        ;;
                    '[B')  # Down
                        if [ "$_cursor" -lt $((_n - 1)) ]; then _cursor=$((_cursor + 1)); fi
                        ;;
                esac
                ;;
            ' ')  # Toggle current item
                if [ "${_checked[$_cursor]}" = "1" ]; then
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
                for ((_i=0; _i<_n; _i++)); do _checked[$_i]=1; _auto[$_i]=0; done
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
        if [ "${_checked[$_i]}" = "1" ]; then
            echo "${_values[$_i]}"
        fi
    done
}

# ─────────────────────────────────────────────────────────────────────────────
# list_bundles — print every available module, sub-bundle and agent, then exit.
# Requires $parsed (the output of parse_manifest) to already be set.
# ─────────────────────────────────────────────────────────────────────────────
list_bundles() {
    local parsed="$1"
    local _ver_label="${VERSION:-${BUNDLE_URL}}"
    echo ""
    printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}\n"
    printf "${BOLD}${CYAN}║   Available Harness Airgap Bundles                  ║${RESET}\n"
    printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}\n"
    echo ""
    printf "${DIM}Source: %s${RESET}\n" "$_ver_label"
    echo ""

    # ── Modules ──────────────────────────────────────────────────────────────
    printf "${BOLD}Modules  (use with --modules)${RESET}\n"
    printf "  %-22s %-10s  %s\n" "NAME" "REQUIRES" "DESCRIPTION"
    printf "  %s\n" "────────────────────────────────────────────────────────────"
    while IFS='|' read -r _mname _mdesc _mreqs; do
        local _req_col="${_mreqs:-(none)}"
        printf "  ${GREEN}%-22s${RESET} ${DIM}%-10s${RESET}  %s\n" "$_mname" "$_req_col" "$_mdesc"
    done < <(echo "$parsed" | awk -F'|' '$1=="MODULE" {print $2 "|" $6 "|" $3}' | sort -t'|' -k3 -r)
    echo ""

    # ── Sub-bundles (combined type only — single-type are always downloaded) ─
    printf "${BOLD}Sub-bundles  (use with --sub-bundles; always included if parent module selected)${RESET}\n"
    printf "  %-30s %-12s  %s\n" "NAME" "PARENT" "DESCRIPTION"
    printf "  %s\n" "────────────────────────────────────────────────────────────"
    local _prev_parent=""
    while IFS='|' read -r _cname _cparent _cdesc _cbtype; do
        [ "$_cbtype" = "single" ] && continue
        if [ "$_cparent" != "$_prev_parent" ]; then
            [ -n "$_prev_parent" ] && echo ""
            _prev_parent="$_cparent"
        fi
        printf "  ${YELLOW}%-30s${RESET} ${DIM}%-12s${RESET}  %s\n" "$_cname" "$_cparent" "$_cdesc"
    done < <(echo "$parsed" | awk -F'|' '$1=="CHILD" {print $2 "|" $3 "|" $6 "|" $5}' | sort -t'|' -k2,2 -k1,1)
    echo ""

    # ── Agents ───────────────────────────────────────────────────────────────
    printf "${BOLD}Agents  (use with --agents; 'all' downloads every variant)${RESET}\n"
    printf "  %-35s %s\n" "NAME" "SECTION"
    printf "  %s\n" "────────────────────────────────────────────────────────────"
    local _prev_sect=""
    while IFS='|' read -r _aname _asect; do
        if [ "$_asect" != "$_prev_sect" ]; then
            [ -n "$_prev_sect" ] && echo ""
            _prev_sect="$_asect"
        fi
        printf "  ${CYAN}%-35s${RESET} ${DIM}%s${RESET}\n" "$_aname" "$_asect"
    done < <(echo "$parsed" | awk -F'|' '$1=="AGENT" {print $4 "|" $3}' | sort -t'|' -k2,2 -k1,1)
    echo ""

    printf "${DIM}See selection.conf.example (in this directory) for the selection file format.${RESET}\n"
    printf "${DIM}Usage: --selection-file selection.conf${RESET}\n"
    echo ""
}

# ─────────────────────────────────────────────────────────────────────────────
# load_selection_file — read a selection.conf file and populate global vars.
# Format (lines are order-independent, '#' comments are ignored):
#   modules=cdng,ci,platform
#   sub-bundles=cdng-agents,ci-plugins,delegate,upgrader   (or: all / none)
#
# The 'sub-bundles' key covers both combined bundles (ci-plugins) and
# individual agent images (delegate, upgrader). They are classified after
# the manifest is loaded.  The legacy 'agents=' key is still accepted for
# backward compatibility with older selection files.
# ─────────────────────────────────────────────────────────────────────────────
load_selection_file() {
    local _file="$1"
    [ ! -f "$_file" ] && log_error "Selection file not found: ${_file}" && exit 1
    log_info "Loading selections from: ${BOLD}${_file}${RESET}"
    while IFS= read -r _line; do
        # Strip comments and leading/trailing whitespace
        _line="${_line%%#*}"
        _line="${_line#"${_line%%[![:space:]]*}"}"
        _line="${_line%"${_line##*[![:space:]]}"}"
        [ -z "$_line" ] && continue
        local _key _val
        _key="${_line%%=*}"
        _val="${_line#*=}"
        case "$_key" in
            modules)     [ -z "$MODULES_CSV"      ] && MODULES_CSV="$_val" ;;
            sub-bundles) [ -z "$COMBINED_SUBS_CSV" ] && COMBINED_SUBS_CSV="$_val" ;;
            # legacy key — map directly so old files keep working
            agents)      [ -z "$AGENTS_CSV"        ] && AGENTS_CSV="$_val" ;;
        esac
    done < "$_file"
}

# ─────────────────────────────────────────────────────────────────────────────
# classify_subs — split COMBINED_SUBS_CSV (from selection file 'sub-bundles=')
# into SUB_BUNDLES_CSV (combined tarballs) and AGENTS_CSV (single images)
# by consulting the parsed manifest.  CLI flags already set take precedence.
# ─────────────────────────────────────────────────────────────────────────────
classify_subs() {
    local parsed="$1"
    [ -z "${COMBINED_SUBS_CSV:-}" ] && return

    if [ "$COMBINED_SUBS_CSV" = "all" ]; then
        [ -z "$SUB_BUNDLES_CSV" ] && SUB_BUNDLES_CSV="all"
        [ -z "$AGENTS_CSV"      ] && AGENTS_CSV="all"
        return
    fi
    if [ "$COMBINED_SUBS_CSV" = "none" ]; then
        [ -z "$SUB_BUNDLES_CSV" ] && SUB_BUNDLES_CSV="none"
        [ -z "$AGENTS_CSV"      ] && AGENTS_CSV="none"
        return
    fi

    # Build a space-delimited string of every valid agent name (base + variants)
    local _all_agent_names=" "
    while IFS='|' read -r _ainame _asuffixes; do
        _all_agent_names="${_all_agent_names}${_ainame} "
        if [ -n "$_asuffixes" ]; then
            local _sv
            IFS=',' read -ra _sv <<< "$_asuffixes"
            local _s
            for _s in "${_sv[@]}"; do
                _all_agent_names="${_all_agent_names}${_ainame}${_s} "
            done
        fi
    done < <(echo "$parsed" | awk -F'|' '$1=="AGENT" {print $4 "|" $5}')

    local _subs="" _agents=""
    IFS=',' read -ra _items <<< "$COMBINED_SUBS_CSV"
    local _item
    for _item in "${_items[@]}"; do
        _item="${_item// /}"
        [ -z "$_item" ] && continue
        if echo "$parsed" | grep -q "^CHILD|${_item}|"; then
            _subs="${_subs:+${_subs},}${_item}"
        elif echo "$_all_agent_names" | grep -qF " ${_item} "; then
            _agents="${_agents:+${_agents},}${_item}"
        else
            log_warn "Unknown sub-bundle/agent in selection file: '${_item}' — skipping"
        fi
    done
    [ -n "$_subs"   ] && [ -z "$SUB_BUNDLES_CSV" ] && SUB_BUNDLES_CSV="$_subs"
    [ -n "$_agents" ] && [ -z "$AGENTS_CSV"       ] && AGENTS_CSV="$_agents"
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────
main() {
    # Load selections from file before anything else so CLI flags take precedence
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
    log_info "Bundle source : ${BOLD}${EFFECTIVE_BASE}${RESET}"
    if [ "$LIST_ONLY" = false ] && [ "$GENERATE_SELECTION" = false ]; then
        log_info "Output dir    : ${BOLD}${OUTPUT_DIR}${RESET}"
        mkdir -p "$OUTPUT_DIR"
    fi
    if [ "$GENERATE_SELECTION" = true ]; then
        local _sel_out="${SELECTION_OUTPUT_FILE:-selection.conf}"
        log_info "Selection file: ${BOLD}${_sel_out}${RESET}  ${DIM}(no download will be performed)${RESET}"
    fi

    # ── Fetch / load manifest ─────────────────────────────────────────────────
    local tmp_manifest
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
        # Fall back to GitHub only when a version tag is known
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
                exit 1
            fi
            log_done "Manifest loaded from GitHub (harness-${VERSION})"
        else
            log_error "Manifest not found at the provided --url."
            log_error "  Checked: ${manifest_url}"
            log_error "GitHub fallback is only available with --version."
            exit 1
        fi
    fi
    [ ! -s "$tmp_manifest" ] && log_error "Manifest is empty" && exit 1
    log_done "Manifest loaded successfully"

    local parsed
    parsed=$(parse_manifest "$tmp_manifest")

    # Classify 'sub-bundles' from selection file into SUB_BUNDLES_CSV / AGENTS_CSV
    classify_subs "$parsed"

    # ── --list: print everything and exit ────────────────────────────────────
    if [ "$LIST_ONLY" = true ]; then
        list_bundles "$parsed"
        exit 0
    fi

    # ── Interactive module selection (if --modules not given) ─────────────────
    if [ -z "$MODULES_CSV" ] && [ "$NON_INTERACTIVE" = false ]; then
        declare -a _mod_items
        local _mn=0
        # Sort: modules WITH requires first (they sort before empty string), platform last.
        # Reverse sort on field 3 achieves this: "platform" > "" so non-empty sorts first.
        while IFS='|' read -r _mname _mdesc _mreqs; do
            local _mlabel="${_mname} — ${_mdesc}"
            [ -n "$_mreqs" ] && _mlabel="${_mlabel}  (requires: ${_mreqs})"
            # Pass requires as 3rd field so checkbox_menu can auto-check them
            _mod_items[$_mn]="${_mlabel}|${_mname}|${_mreqs}"
            _mn=$((_mn + 1))
        done < <(echo "$parsed" | awk -F'|' '$1=="MODULE" {print $2 "|" $6 "|" $3}' | sort -t'|' -k3 -r)
        local _selected_raw
        _selected_raw=$(checkbox_menu "Select Modules to Download  (selecting a module auto-checks its dependencies)" "${_mod_items[@]}")
        MODULES_CSV=$(echo "$_selected_raw" | tr '\n' ',' | sed 's/,$//')
    fi

    # ── Resolve module dependencies ───────────────────────────────────────────
    local resolved_modules=""
    if [ -n "$MODULES_CSV" ]; then
        resolved_modules=$(resolve_modules "$parsed" "$MODULES_CSV")
        local resolved_display
        resolved_display=$(echo "$resolved_modules" | tr ' ' ',' | sed 's/^,//')
        log_info "Modules selected (with auto-resolved deps): ${BOLD}${resolved_display}${RESET}"

        # Show per-module breakdown when selections came from a file or CLI flags
        # (not from the interactive menus, where it would just repeat what was shown)
        if [ -n "${SELECTION_FILE:-}" ] || [ "$NON_INTERACTIVE" = true ]; then
            print_selection_plan "$parsed" "$resolved_modules"
        fi

        if [ "$GENERATE_SELECTION" = false ]; then
            log_step "Downloading module bundles"
            for mod in $resolved_modules; do
                mod="${mod// /}"
                [ -z "$mod" ] && continue
                echo "$parsed" | grep -q "^MODULE|${mod}|" && download_module "$parsed" "$mod"
            done
            if [ "$DL_FAILED" -gt 0 ]; then
                log_error "${DL_FAILED} module bundle(s) failed to download — aborting."
                log_error "Fix the errors above before downloading sub-bundles or agents."
                exit 1
            fi
        fi
    fi

    # ── Sub-bundles (children with combined bundle_type) ─────────────────────
    local available_children=""
    if [ -n "$resolved_modules" ]; then
        for mod in $resolved_modules; do
            mod="${mod// /}"
            [ -z "$mod" ] && continue
            while IFS= read -r child; do
                [ -z "$child" ] && continue
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
            # --sub-bundles all  → include every available combined sub-bundle
            # --sub-bundles none → skip all sub-bundles
            # --sub-bundles LIST → match by exact sub-bundle name
            if [ "$SUB_BUNDLES_CSV" = "all" ]; then
                children_to_dl="$available_children"
            elif [ "$SUB_BUNDLES_CSV" = "none" ] || [ -z "$SUB_BUNDLES_CSV" ]; then
                children_to_dl=""
            else
                IFS=',' read -ra _wanted <<< "$SUB_BUNDLES_CSV"
                for child in $available_children; do
                    for _w in "${_wanted[@]}"; do
                        _w="${_w// /}"
                        if [ "$child" = "$_w" ]; then
                            children_to_dl="${children_to_dl} ${child}"
                            break
                        fi
                    done
                done
            fi
        else
            # One menu per parent module — collect unique parents in order first
            local _seen_parents=""
            local _parent_order=""
            for child in $available_children; do
                local _cp
                _cp=$(child_parent "$parsed" "$child")
                if [[ "$_seen_parents" != *"|${_cp}|"* ]]; then
                    _seen_parents="${_seen_parents}|${_cp}|"
                    _parent_order="${_parent_order} ${_cp}"
                fi
            done

            for _parent in $_parent_order; do
                [ -z "$_parent" ] && continue
                declare -a _child_items=()
                local _ci=0
                for child in $available_children; do
                    [ "$(child_parent "$parsed" "$child")" != "$_parent" ] && continue
                    local _cdesc
                    _cdesc=$(echo "$parsed" | awk -F'|' -v c="$child" '$1=="CHILD" && $2==c {print $6}')
                    _child_items[$_ci]="${child} — ${_cdesc}|${child}"
                    _ci=$((_ci + 1))
                done
                if [ "$_ci" -gt 0 ]; then
                    local _parent_desc
                    _parent_desc=$(echo "$parsed" | awk -F'|' -v m="$_parent" '$1=="MODULE" && $2==m {print $6}')
                    [ -z "$_parent_desc" ] && _parent_desc="$_parent"
                    local _raw=""
                    _raw=$(checkbox_menu "Sub-bundles for ${_parent} — ${_parent_desc}" "${_child_items[@]}")
                    while IFS= read -r _v; do
                        [ -n "$_v" ] && children_to_dl="${children_to_dl} ${_v}"
                    done <<< "$_raw"
                fi
            done
        fi

        if [ -n "$children_to_dl" ]; then
            if [ "$GENERATE_SELECTION" = false ]; then
                # shellcheck disable=SC2086
                print_download_plan "Sub-bundles" $children_to_dl
                log_step "Downloading sub-bundles"
                for child in $children_to_dl; do
                    child="${child// /}"
                    [ -z "$child" ] && continue
                    download_child "$parsed" "$child"
                done
            fi
        else
            log_skip "No sub-bundles selected"
        fi
    fi

    # ── Agents ────────────────────────────────────────────────────────────────
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
        while IFS= read -r sec; do
            relevant_agent_sections="${relevant_agent_sections} ${sec}"
        done < <(all_agent_sections "$parsed")
    fi

    if [ -n "$relevant_agent_sections" ]; then
        local agents_to_dl=""

        if [ -n "$AGENTS_CSV" ]; then
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
            # One menu per agent section
            for sec in $relevant_agent_sections; do
                sec="${sec// /}"
                local _sec_desc
                _sec_desc=$(echo "$parsed" | awk -F'|' -v s="$sec" '$1=="CHILD" && $2==s {print $6}')
                [ -z "$_sec_desc" ] && _sec_desc="$sec"
                declare -a _agent_items=()
                local _ai=0
                while IFS='|' read -r name suffixes; do
                    _agent_items[$_ai]="${name}  (base)|${name}"
                    _ai=$((_ai + 1))
                    if [ -n "$suffixes" ]; then
                        IFS=',' read -ra sarr <<< "$suffixes"
                        for s in "${sarr[@]}"; do
                            _agent_items[$_ai]="${name}${s}  (variant: ${s})|${name}${s}"
                            _ai=$((_ai + 1))
                        done
                    fi
                done < <(agents_in_section "$parsed" "$sec")
                if [ "$_ai" -gt 0 ]; then
                    local _raw=""
                    _raw=$(checkbox_menu "Select agents — ${_sec_desc}" "${_agent_items[@]}")
                    while IFS= read -r _v; do
                        [ -n "$_v" ] && agents_to_dl="${agents_to_dl} ${_v}"
                    done <<< "$_raw"
                fi
            done
        fi

        if [ -n "$agents_to_dl" ]; then
            if [ "$GENERATE_SELECTION" = false ]; then
                # shellcheck disable=SC2086
                print_download_plan "Agents" $agents_to_dl
                log_step "Downloading agents"
                for agent in $agents_to_dl; do
                    agent="${agent// /}"
                    [ -z "$agent" ] && continue
                    download_agent "$parsed" "$agent"
                done
            fi
        else
            log_skip "No agents selected"
        fi
    fi

    # ── Write selection file (--generate-selection-file) ─────────────────────
    if [ "$GENERATE_SELECTION" = true ]; then
        local _sel_out="${SELECTION_OUTPUT_FILE:-selection.conf}"

        # Resolve to absolute path (portable — no dependency on realpath)
        local _abs_sel_out
        case "$_sel_out" in
            /*) _abs_sel_out="$_sel_out" ;;
            *)  _abs_sel_out="$PWD/$_sel_out" ;;
        esac

        # Build clean CSV values from what was selected
        local _mods_out _sub_out _agents_out _combined_subs_out
        _mods_out=$(echo "$resolved_modules" | tr ' ' ',' | sed 's/^,//;s/,$//')
        _sub_out=$(echo "${children_to_dl:-}"  | tr ' ' ',' | sed 's/^,//;s/,$//')
        _agents_out=$(echo "${agents_to_dl:-}" | tr ' ' ',' | sed 's/^,//;s/,$//')

        # Merge combined sub-bundles + agents into one 'sub-bundles' key
        local _parts=""
        [ -n "$_sub_out"    ] && _parts="$_sub_out"
        [ -n "$_agents_out" ] && _parts="${_parts:+${_parts},}${_agents_out}"
        _combined_subs_out="${_parts:-none}"

        cat > "$_abs_sel_out" <<EOF
# Harness Airgap Bundle Selection File
# Generated: $(date '+%Y-%m-%d %H:%M:%S')  version: ${VERSION:-${BUNDLE_URL}}
# ──────────────────────────────────────────────────────────────────────────────
# Use with:
#   ./download-airgap-bundles.sh --version <ver> --output-dir ./bundles \\
#       --selection-file ${_abs_sel_out}
# ──────────────────────────────────────────────────────────────────────────────

modules=${_mods_out}

# sub-bundles: comma-separated list of combined bundles AND agent images to
# download, or 'all' / 'none'.  Run --list to see available names.
sub-bundles=${_combined_subs_out}
EOF
        echo ""
        printf "${BOLD}${CYAN}╔══════════════════════════════════════════════════════╗${RESET}\n"
        printf "${BOLD}${CYAN}║   Selection File Written                             ║${RESET}\n"
        printf "${BOLD}${CYAN}╚══════════════════════════════════════════════════════╝${RESET}\n"
        printf "  ${GREEN}✓ Saved to${RESET}    : ${BOLD}%s${RESET}\n" "$_abs_sel_out"
        printf "  ${CYAN}  Modules${RESET}      : ${BOLD}%s${RESET}\n" "$_mods_out"
        printf "  ${CYAN}  Sub-bundles${RESET}  : ${BOLD}%s${RESET}\n" "$_sub_out"

        # Agents — grouped by section for readability
        local _any_agents=false
        for _asec in $relevant_agent_sections; do
            _asec="${_asec// /}"
            local _asec_desc
            _asec_desc=$(echo "$parsed" | awk -F'|' -v s="$_asec" '$1=="CHILD" && $2==s {print $6}')
            [ -z "$_asec_desc" ] && _asec_desc="$_asec"

            local _sec_selected=""
            while IFS='|' read -r _aname _asuffixes; do
                # base
                if echo " ${agents_to_dl:-} " | grep -qF " ${_aname} "; then
                    _sec_selected="${_sec_selected:+${_sec_selected},}${_aname}"
                fi
                # variants
                if [ -n "$_asuffixes" ]; then
                    local _sv
                    IFS=',' read -ra _svarr <<< "$_asuffixes"
                    for _sv in "${_svarr[@]}"; do
                        local _vn="${_aname}${_sv}"
                        if echo " ${agents_to_dl:-} " | grep -qF " ${_vn} "; then
                            _sec_selected="${_sec_selected:+${_sec_selected},}${_vn}"
                        fi
                    done
                fi
            done < <(agents_in_section "$parsed" "$_asec")

            if [ -n "$_sec_selected" ]; then
                printf "  ${CYAN}  %-22s${RESET}: ${BOLD}%s${RESET}\n" "$_asec_desc" "$_sec_selected"
                _any_agents=true
            fi
        done
        if [ "$_any_agents" = false ]; then
            printf "  ${CYAN}  Agents${RESET}        : ${BOLD}none${RESET}\n"
        fi

        echo ""
        printf "  ${DIM}To download, run:${RESET}\n"
        printf "  ${BOLD}./download-airgap-bundles.sh --version %s --output-dir ./bundles \\\\\n" "${VERSION:-<version>}"
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
