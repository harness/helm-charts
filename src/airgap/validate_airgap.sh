#!/bin/bash
set -e

log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_warn()  { echo "[WARN]  $(date +%H:%M:%S) $*" >&2; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*" >&2; }
log_debug() { [ "${DEBUG:-false}" = "true" ] && echo "[DEBUG] $(date +%H:%M:%S) $*" || true; }

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
    echo "  DEBUG=true   Enable debug logging (shows actual vs expected when validation fails)"
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
    local raw_tags tar_out
    tar_out=$(tar -xzOf "$tgz" manifest.json 2>&1) || true
    raw_tags=$(echo "$tar_out" | jq -r '.[].RepoTags[]? // empty' 2>/dev/null || true)
    if [ -z "$raw_tags" ] && [ -n "$tar_out" ]; then
        log_debug "tar/jq failed for ${tgz}: $(echo "$tar_out" | head -5)"
    fi
    while IFS= read -r tag; do
        [ -n "$tag" ] && strip_registry "$tag" || true
    done <<< "$raw_tags"
}

# Normalise an image ref by stripping the registry hostname prefix if present.
# Applied to BOTH the expected ref (from images_internal.txt) and the actual
# RepoTag (from the bundle), so comparison works regardless of whether the
# bundle was created with docker save (stores full ref) or skopeo (stores
# org/name:tag without registry hostname).
#
strip_registry() {
    local ref="$1"
    local first="${ref%%/*}"
    # grep -q returns 1 when no match; use [[ ]] to avoid set -e exit
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

ERRORS=()

# Count total validations for progress [N/M]: combined=1 per section, single=1 per @image
count_total_validations() {
    local total=0
    local stype=""
    while IFS= read -r line; do
        if [[ "$line" =~ ^#\ @module= ]]; then
            stype=$(extract_attr "$line" "@type=")
            [ "$stype" = "combined" ] && total=$((total + 1)) || true
        elif [[ "$line" =~ ^#\ @image= ]]; then
            [ "$stype" = "single" ] && total=$((total + 1)) || true
        fi
    done < "$INTERNAL_FILE"
    echo $total
}

TOTAL_VALIDATIONS=$(count_total_validations)
CURRENT_VALIDATION=0

validate_combined_bundle() {
    local module="$1"
    local path="$2"
    shift 2
    local expected_images=("$@")

    local bundle_name
    bundle_name=$(echo "${module}" | tr '/' '_')
    local tgz_path="${OUTPUT_DIR}/${path}/${bundle_name}_images.tgz"

    if [ ! -f "$tgz_path" ]; then
        ERRORS+=("Combined bundle not found: ${tgz_path}")
        log_debug "Expected path: ${tgz_path} (module=${module}, path=${path})"
        return
    fi

    if [ ${#expected_images[@]} -eq 0 ]; then
        log_warn "Combined bundle ${module}: no expected images in manifest (section may be misconfigured)"
    fi

    local actual_tags
    actual_tags=$(get_repo_tags_from_tgz "$tgz_path")
    if [ -z "$actual_tags" ]; then
        ERRORS+=("Could not extract RepoTags from ${tgz_path} (invalid or empty manifest; run DEBUG=true for tar/jq details)")
        return
    fi

    local missing=()
    for exp in "${expected_images[@]}"; do
        local norm_exp
        norm_exp=$(strip_registry "$exp")
        if ! echo "$actual_tags" | grep -Fxq "$norm_exp" 2>/dev/null; then
            missing+=("$exp")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        for m in "${missing[@]}"; do
            ERRORS+=("Combined bundle ${module}: missing expected image: ${m}")
        done
        if [ "${DEBUG:-false}" = "true" ]; then
            log_debug "Bundle ${tgz_path} contains: $(echo "$actual_tags" | tr '\n' ' ')"
            log_debug "Expected but missing: ${missing[*]}"
        fi
    fi
}

validate_single_image() {
    local path="$1"
    local image_name="$2"
    shift 2
    local expected_tags=("$@")

    local tgz_path="${OUTPUT_DIR}/${path}/${image_name}.tgz"

    if [ ! -f "$tgz_path" ]; then
        ERRORS+=("Single bundle not found: ${tgz_path}")
        log_debug "Expected path: ${tgz_path} (path=${path}, image=${image_name})"
        return
    fi

    if [ ${#expected_tags[@]} -eq 0 ]; then
        log_warn "Single bundle ${path}/${image_name}: no expected tags in manifest (section may be misconfigured)"
    fi

    local actual_tags
    actual_tags=$(get_repo_tags_from_tgz "$tgz_path")
    if [ -z "$actual_tags" ]; then
        ERRORS+=("Could not extract RepoTags from ${tgz_path} (invalid or empty manifest; run DEBUG=true for tar/jq details)")
        return
    fi

    local missing=()
    for exp in "${expected_tags[@]}"; do
        local norm_exp
        norm_exp=$(strip_registry "$exp")
        if ! echo "$actual_tags" | grep -Fxq "$norm_exp" 2>/dev/null; then
            missing+=("$exp")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        for m in "${missing[@]}"; do
            ERRORS+=("Single bundle ${path}/${image_name}: missing expected tag: ${m}")
        done
        if [ "${DEBUG:-false}" = "true" ]; then
            log_debug "Bundle ${tgz_path} contains: $(echo "$actual_tags" | tr '\n' ' ')"
            log_debug "Expected but missing: ${missing[*]}"
        fi
    fi
}

# Parse and validate
CURRENT_VALIDATION=0
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
            # Validate previous section
            if [ "$section_type" = "combined" ]; then
                CURRENT_VALIDATION=$((CURRENT_VALIDATION + 1))
                log_info "[${CURRENT_VALIDATION}/${TOTAL_VALIDATIONS}] Validating: ${section_module} (combined)"
                validate_combined_bundle "$section_module" "$section_path" "${section_images[@]}"
            fi
            # For single, we validate per @image - already done in @image block
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
            CURRENT_VALIDATION=$((CURRENT_VALIDATION + 1))
            log_info "[${CURRENT_VALIDATION}/${TOTAL_VALIDATIONS}] Validating: ${section_module}/${current_image_name} (single)"
            validate_single_image "$section_path" "$current_image_name" "${current_image_tags_arr[@]}"
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

# Validate last section
if [ "$in_section" = true ]; then
    if [ "$section_type" = "combined" ]; then
        CURRENT_VALIDATION=$((CURRENT_VALIDATION + 1))
        log_info "[${CURRENT_VALIDATION}/${TOTAL_VALIDATIONS}] Validating: ${section_module} (combined)"
        validate_combined_bundle "$section_module" "$section_path" "${section_images[@]}"
    elif [ "$section_type" = "single" ] && [ -n "$current_image_name" ] && [ ${#current_image_tags_arr[@]} -gt 0 ]; then
        CURRENT_VALIDATION=$((CURRENT_VALIDATION + 1))
        log_info "[${CURRENT_VALIDATION}/${TOTAL_VALIDATIONS}] Validating: ${section_module}/${current_image_name} (single)"
        validate_single_image "$section_path" "$current_image_name" "${current_image_tags_arr[@]}"
    fi
fi

# Report summary
echo ""
log_info "=== VALIDATION SUMMARY ==="
if [ ${#ERRORS[@]} -gt 0 ]; then
    log_error "Validation FAILED with ${#ERRORS[@]} error(s):"
    for i in "${!ERRORS[@]}"; do
        log_error "  [$((i+1))] ${ERRORS[$i]}"
    done
    log_error "Run with DEBUG=true for more details (e.g. actual vs expected image tags)"
    exit 1
else
    log_info "Validation PASSED: ${TOTAL_VALIDATIONS} bundle(s) validated successfully."
    exit 0
fi
