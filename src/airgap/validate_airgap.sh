#!/bin/bash
set -e

log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_warn()  { echo "[WARN]  $(date +%H:%M:%S) $*" >&2; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*" >&2; }

usage() {
    echo "Usage: $0 --internal-file <path> [--output-dir <path>]"
    echo ""
    echo "  --internal-file  Path to images_internal.txt"
    echo "  --output-dir     Bundle output directory (default: current directory)"
    echo ""
    echo "Validates airgap .tgz bundles against expected images from images_internal.txt."
    echo "Exits with code 1 if any validation errors are found."
    echo ""
    echo "Environment:"
    echo "  VALIDATE_PARALLEL=N   Run up to N validations in parallel (default: 8)"
    exit 1
}

INTERNAL_FILE=""
OUTPUT_DIR="."

while [ $# -gt 0 ]; do
    case "$1" in
        --internal-file) INTERNAL_FILE="$2"; shift 2 ;;
        --output-dir)    OUTPUT_DIR="$2"; shift 2 ;;
        -h|--help)       usage ;;
        *)               log_error "Unknown option: $1"; usage ;;
    esac
done

if [ -z "$INTERNAL_FILE" ]; then
    log_error "Missing required --internal-file"
    usage
fi

if [ ! -f "$INTERNAL_FILE" ]; then
    log_error "File not found: $INTERNAL_FILE"
    exit 1
fi

OUTPUT_DIR="$(cd "${OUTPUT_DIR}" 2>/dev/null && pwd)" || {
    log_error "Output directory not found or not accessible: $OUTPUT_DIR"
    exit 1
}

# Portable extraction of @module=, @type=, @path=, @image=
# Uses || true because grep returns 1 when no match; with set -e that would exit the script
extract_attr() {
    echo "$1" | grep -oE "${2}[^ ]+" 2>/dev/null | cut -d= -f2- | head -1 || true
}

get_repo_tags_from_tgz() {
    local tgz="$1"
    if [ ! -f "$tgz" ]; then
        return 1
    fi
    local raw_tags tar_out manifest_path

    # Try manifest.json first (fast when it's first in archive - create-airgap-bundle puts it there)
    for manifest_path in "manifest.json" "./manifest.json"; do
        tar_out=$(tar -xzOf "$tgz" "$manifest_path" 2>&1) || true
        raw_tags=$(echo "$tar_out" | jq -r '.[].RepoTags[]? // empty' 2>/dev/null || true)
        [ -n "$raw_tags" ] && break
    done

    # Fallback: find manifest.json from archive listing (handles older bundles, varying tar implementations)
    if [ -z "$raw_tags" ]; then
        manifest_path=$(tar -tzf "$tgz" 2>/dev/null | grep -E 'manifest\.json$' | head -1)
        if [ -n "$manifest_path" ]; then
            tar_out=$(tar -xzOf "$tgz" "$manifest_path" 2>&1) || true
            raw_tags=$(echo "$tar_out" | jq -r '.[].RepoTags[]? // empty' 2>/dev/null || true)
        fi
    fi

    if [ -z "$raw_tags" ] && [ -n "$tar_out" ]; then
        log_info "tar/jq failed for ${tgz}: $(echo "$tar_out" | head -5)"
    elif [ -z "$raw_tags" ]; then
        log_info "Archive contents of ${tgz}: $(tar -tzf "$tgz" 2>/dev/null | head -10)"
    fi

    while IFS= read -r tag; do
        [ -n "$tag" ] && strip_registry "$tag" || true
    done <<< "$raw_tags"
}

# Normalise an image ref by stripping the registry hostname prefix if present.
# Bundles are written in docker-save format (harness/foo:tag, defaultbackend-amd64:tag).
# Expected refs from images_internal.txt may include registry (docker.io/, registry.k8s.io/).
# We strip so both sides compare as org/name:tag or name:tag.
#
strip_registry() {
    local ref="$1"
    local first="${ref%%/*}"
    if [[ "$first" =~ [.:] ]]; then
        echo "${ref#*/}"
    else
        echo "${ref}"
    fi
}

# Check if jq is available
if ! command -v jq &>/dev/null; then
    log_error "jq is required for validation. Install with: brew install jq (macOS) or apt-get install jq (Linux)"
    exit 1
fi

VALIDATE_PARALLEL="${VALIDATE_PARALLEL:-8}"
[ "$VALIDATE_PARALLEL" -lt 1 ] && VALIDATE_PARALLEL=1
ERRORS=()
ERRORS_FILE=""

# Outputs errors to stdout (one per line). Caller collects into ERRORS or file.
validate_combined_bundle() {
    local module="$1"
    local path="$2"
    shift 2
    local expected_images=("$@")

    local bundle_name
    bundle_name=$(echo "${module}" | tr '/' '_')
    local tgz_path="${OUTPUT_DIR}/${path}/${bundle_name}_images.tgz"

    if [ ! -f "$tgz_path" ]; then
        log_info "Combined bundle path checked: ${tgz_path}"
        echo "Combined bundle not found: ${tgz_path}"
        return
    fi

    if [ ${#expected_images[@]} -eq 0 ]; then
        log_warn "Combined bundle ${module}: no expected images in manifest (section may be misconfigured)"
    fi

    local actual_tags
    actual_tags=$(get_repo_tags_from_tgz "$tgz_path")
    if [ -z "$actual_tags" ]; then
        echo "Could not extract RepoTags from ${tgz_path} (invalid or empty manifest)"
        return
    fi

    local expected_norm
    expected_norm=$(for exp in "${expected_images[@]}"; do strip_registry "$exp"; done | sort -u)
    local missing_norm
    missing_norm=$(comm -23 <(echo "$expected_norm") <(echo "$actual_tags" | sort -u) 2>/dev/null) || true

    if [ -n "$missing_norm" ]; then
        log_info "Combined ${module}: expected=$(echo "$expected_norm" | tr '\n' ' '), actual=$(echo "$actual_tags" | tr '\n' ' ')"
        while IFS= read -r m; do
            [ -n "$m" ] && echo "Combined bundle ${module}: missing expected image: ${m}"
        done <<< "$missing_norm"
    fi
}

# Outputs errors to stdout (one per line). Caller collects into ERRORS or file.
validate_single_image() {
    local path="$1"
    local image_name="$2"
    shift 2
    local expected_tags=("$@")

    if [ ${#expected_tags[@]} -eq 0 ]; then
        log_warn "Single bundle ${path}/${image_name}: no expected tags in manifest (section may be misconfigured)"
        return
    fi

    local tgz_path="${OUTPUT_DIR}/${path}/${image_name}.tgz"

    if [ ! -f "$tgz_path" ]; then
        log_info "Single bundle path checked: ${tgz_path}"
        echo "Single bundle not found: ${tgz_path}"
        return
    fi

    local actual_tags
    actual_tags=$(get_repo_tags_from_tgz "$tgz_path")
    if [ -z "$actual_tags" ]; then
        echo "Could not extract RepoTags from ${tgz_path} (invalid or empty manifest)"
        return
    fi

    local expected_norm
    expected_norm=$(for exp in "${expected_tags[@]}"; do strip_registry "$exp"; done | sort -u)
    local missing_norm
    missing_norm=$(comm -23 <(echo "$expected_norm") <(echo "$actual_tags" | sort -u) 2>/dev/null) || true

    if [ -n "$missing_norm" ]; then
        log_info "Single ${path}/${image_name}: expected=$(echo "$expected_norm" | tr '\n' ' '), actual=$(echo "$actual_tags" | tr '\n' ' ')"
        while IFS= read -r m; do
            [ -n "$m" ] && echo "Single bundle ${path}/${image_name}: missing expected tag: ${m}"
        done <<< "$missing_norm"
    fi
}

# Collect validation tasks
declare -a TASK_TYPE TASK_MODULE TASK_PATH TASK_NAME TASK_EXPECTED

run_one_validation() {
    local type="$1"
    local module="$2"
    local path="$3"
    local name="$4"
    shift 4
    local expected=("$@")
    local out
    if [ "$type" = "combined" ]; then
        out=$(validate_combined_bundle "$module" "$path" "${expected[@]}" 2>/dev/null) || true
    else
        out=$(validate_single_image "$path" "$name" "${expected[@]}" 2>/dev/null) || true
    fi
    [ -n "$out" ] && echo "$out"
    true
}

# Parse and collect tasks
in_section=false
section_module=""
section_type=""
section_path=""
section_images=()
current_image_name=""
declare -a current_image_tags_arr

while IFS= read -r line; do
    if [[ "$line" =~ ^#\ @module= ]]; then
        if [ "$in_section" = true ]; then
            if [ "$section_type" = "combined" ]; then
                TASK_TYPE+=("combined")
                TASK_MODULE+=("$section_module")
                TASK_PATH+=("$section_path")
                TASK_NAME+=("")
                TASK_EXPECTED+=("${section_images[*]}")
            fi
        fi

        section_module=$(extract_attr "$line" "@module=")
        section_type=$(extract_attr "$line" "@type=")
        section_path=$(extract_attr "$line" "@path=")
        section_images=()
        current_image_name=""
        current_image_tags_arr=()
        in_section=true

    elif [[ "$line" =~ ^#\ @image= ]]; then
        if [ "$section_type" = "single" ] && [ -n "$current_image_name" ] && [ ${#current_image_tags_arr[@]} -gt 0 ]; then
            TASK_TYPE+=("single")
            TASK_MODULE+=("$section_module")
            TASK_PATH+=("$section_path")
            TASK_NAME+=("$current_image_name")
            TASK_EXPECTED+=("${current_image_tags_arr[*]}")
        fi
        current_image_name="${line#*@image=}"
        current_image_name="${current_image_name%% *}"
        current_image_tags_arr=()

    elif [ "$in_section" = true ] && [ -n "$line" ] && [[ ! "$line" =~ ^# ]]; then
        if [ "$section_type" = "combined" ]; then
            section_images+=("$line")
        else
            current_image_tags_arr+=("$line")
        fi
    fi
done < "$INTERNAL_FILE"

if [ "$in_section" = true ]; then
    if [ "$section_type" = "combined" ]; then
        TASK_TYPE+=("combined")
        TASK_MODULE+=("$section_module")
        TASK_PATH+=("$section_path")
        TASK_NAME+=("")
        TASK_EXPECTED+=("${section_images[*]}")
    elif [ "$section_type" = "single" ] && [ -n "$current_image_name" ] && [ ${#current_image_tags_arr[@]} -gt 0 ]; then
        TASK_TYPE+=("single")
        TASK_MODULE+=("$section_module")
        TASK_PATH+=("$section_path")
        TASK_NAME+=("$current_image_name")
        TASK_EXPECTED+=("${current_image_tags_arr[*]}")
    fi
fi

# Run validations in parallel
ERRORS_FILE=$(mktemp)
trap "rm -f $ERRORS_FILE" EXIT

export -f run_one_validation validate_combined_bundle validate_single_image get_repo_tags_from_tgz strip_registry log_info 2>/dev/null || true
export OUTPUT_DIR

running=0
total=${#TASK_TYPE[@]}
declare -a pids=()

for ((i=0; i<total; i++)); do
    type="${TASK_TYPE[$i]}"
    module="${TASK_MODULE[$i]}"
    path="${TASK_PATH[$i]}"
    name="${TASK_NAME[$i]}"
    expected_str="${TASK_EXPECTED[$i]}"
    expected_arr=()
    [ -n "$expected_str" ] && read -ra expected_arr <<< "$expected_str"

    if [ "$type" = "combined" ]; then
        label="${module} (combined)"
    else
        label="${module}/${name} (single)"
    fi
    log_info "[$((i + 1))/${total}] Validating: ${label}"

    (
        run_one_validation "$type" "$module" "$path" "$name" "${expected_arr[@]}"
    ) >> "$ERRORS_FILE" 2>&1 &
    pids+=($!)

    running=$((running + 1))
    if [ "$running" -ge "$VALIDATE_PARALLEL" ]; then
        wait "${pids[0]}" 2>/dev/null || true
        pids=("${pids[@]:1}")
        running=$((running - 1))
    fi
done
for pid in "${pids[@]}"; do wait "$pid" 2>/dev/null || true; done

# Collect errors
while IFS= read -r line; do
    [ -n "$line" ] && ERRORS+=("$line")
done < "$ERRORS_FILE"

# Report summary
echo ""
log_info "=== VALIDATION SUMMARY ==="
if [ ${#ERRORS[@]} -gt 0 ]; then
    log_error "Validation FAILED with ${#ERRORS[@]} error(s):"
    for i in "${!ERRORS[@]}"; do
        log_error "  [$((i+1))] ${ERRORS[$i]}"
    done
    log_error "See actual vs expected above for each failed bundle."
    exit 1
else
    log_info "Validation PASSED: ${total} bundle(s) validated successfully."
    exit 0
fi
