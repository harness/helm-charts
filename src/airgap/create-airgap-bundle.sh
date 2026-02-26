#!/bin/bash

set -e

log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_warn()  { echo "[WARN]  $(date +%H:%M:%S) $*" >&2; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*" >&2; }

export DOCKER_DEFAULT_PLATFORM=linux/amd64

usage() {
    echo "Usage: $0 --internal-file <path> [--section <name> | --all]"
    echo ""
    echo "  --internal-file  Path to images_internal.txt"
    echo "  --section        Process a single section (e.g., 'ci', 'sto-scanners@1')"
    echo "  --all            Process all sections"
    echo "  --output-dir     Output directory (default: current directory)"
    exit 1
}

INTERNAL_FILE=""
SECTION=""
PROCESS_ALL=false
OUTPUT_DIR="."

while [ $# -gt 0 ]; do
    case "$1" in
        --internal-file) INTERNAL_FILE="$2"; shift 2 ;;
        --section)       SECTION="$2"; shift 2 ;;
        --all)           PROCESS_ALL=true; shift ;;
        --output-dir)    OUTPUT_DIR="$2"; shift 2 ;;
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

if [ -z "$SECTION" ] && [ "$PROCESS_ALL" = false ]; then
    log_error "Must specify --section <name> or --all"
    usage
fi

MAX_PULL_RETRIES="${MAX_PULL_RETRIES:-3}"
PULL_RETRY_DELAY="${PULL_RETRY_DELAY:-10}"
MAX_PARALLEL_PULLS="${MAX_PARALLEL_PULLS:-6}"

pull_image() {
    local image="$1"
    local pulled_file="$2"
    local attempt=0
    local delay="${PULL_RETRY_DELAY}"

    while [ $attempt -lt "${MAX_PULL_RETRIES}" ]; do
        attempt=$((attempt + 1))
        if docker pull --quiet "${image}" 2>&1; then
            log_info "Pulled (attempt ${attempt}): ${image}"
            echo "${image}" >> "${pulled_file}"
            return 0
        fi
        if [ $attempt -lt "${MAX_PULL_RETRIES}" ]; then
            log_warn "Pull attempt ${attempt}/${MAX_PULL_RETRIES} failed for: ${image} — retrying in ${delay}s"
            sleep "${delay}"
            delay=$((delay * 2))
        fi
    done

    log_error "Failed to pull after ${MAX_PULL_RETRIES} attempts: ${image}"
    return 1
}

# Run at most MAX_PARALLEL_PULLS pulls concurrently to avoid Docker Hub rate limiting.
pull_images_bounded() {
    local pulled_file="$1"
    shift
    local images=("$@")
    local failed=0
    local pids=()
    local active=0

    for img in "${images[@]}"; do
        pull_image "${img}" "${pulled_file}" </dev/null &
        pids+=($!)
        active=$((active + 1))

        if [ "$active" -ge "${MAX_PARALLEL_PULLS}" ]; then
            wait "${pids[0]}" || failed=1
            pids=("${pids[@]:1}")
            active=$((active - 1))
        fi
    done

    for pid in "${pids[@]}"; do
        wait "$pid" || failed=1
    done

    return $failed
}

create_combined_bundle() {
    local section_name="$1"
    local bucket_path="$2"
    shift 2
    local images=("$@")

    local out_dir="${OUTPUT_DIR}/${bucket_path}"
    mkdir -p "${out_dir}"

    local bundle_name
    bundle_name=$(echo "${section_name}" | tr '/' '_')
    local tgz_file="${out_dir}/${bundle_name}_images.tgz"

    local pulled_file
    pulled_file="$(mktemp)"

    log_info "Pulling ${#images[@]} images for combined bundle: ${section_name} (parallel limit: ${MAX_PARALLEL_PULLS}, retries: ${MAX_PULL_RETRIES})"

    if ! pull_images_bounded "${pulled_file}" "${images[@]}"; then
        log_error "Some images failed to pull for section: ${section_name}"
        rm -f "${pulled_file}"
        return 1
    fi

    local pulled
    pulled=$(cat "${pulled_file}")
    local count
    count=$(echo "${pulled}" | wc -w | tr -d '[:space:]')
    log_info "Creating ${tgz_file} with ${count} images"
    docker save ${pulled} | gzip --stdout > "${tgz_file}"

    rm -f "${pulled_file}"

    for img in ${pulled}; do
        docker rmi -f "${img}" 2>/dev/null || true
    done

    log_info "Combined bundle created: ${tgz_file}"
}

create_single_bundles() {
    local section_name="$1"
    local bucket_path="$2"
    shift 2
    local section_lines=("$@")

    local out_dir="${OUTPUT_DIR}/${bucket_path}"
    mkdir -p "${out_dir}"

    local current_image_name=""
    local current_images=()
    local processed=0

    bundle_one_image() {
        local img_name="$1"
        shift
        local img_tags=("$@")

        if [ ${#img_tags[@]} -eq 0 ]; then
            return
        fi

        local tgz_file="${out_dir}/${img_name}.tgz"
        local pulled_file
        pulled_file="$(mktemp)"

        log_info "Pulling ${#img_tags[@]} tags for single bundle: ${img_name}"

        if ! pull_images_bounded "${pulled_file}" "${img_tags[@]}"; then
            log_error "Some tags failed to pull for image: ${img_name}"
            rm -f "${pulled_file}"
            return 1
        fi

        local pulled
        pulled=$(cat "${pulled_file}")
        local count
        count=$(echo "${pulled}" | wc -w | tr -d '[:space:]')
        log_info "Creating ${tgz_file} with ${count} tags"
        docker save ${pulled} </dev/null | gzip --stdout > "${tgz_file}"

        rm -f "${pulled_file}"

        for img in ${pulled}; do
            docker rmi -f "${img}" </dev/null 2>/dev/null || true
        done

        log_info "Single bundle created: ${tgz_file}"
    }

    for line in "${section_lines[@]}"; do
        if [[ "$line" =~ ^#\ @image= ]]; then
            if [ -n "$current_image_name" ] && [ ${#current_images[@]} -gt 0 ]; then
                bundle_one_image "$current_image_name" "${current_images[@]}"
                processed=$((processed + 1))
            fi
            current_image_name="${line#*@image=}"
            current_images=()
        elif [ -n "$line" ] && [[ ! "$line" =~ ^# ]]; then
            current_images+=("$line")
        fi
    done

    if [ -n "$current_image_name" ] && [ ${#current_images[@]} -gt 0 ]; then
        bundle_one_image "$current_image_name" "${current_images[@]}"
        processed=$((processed + 1))
    fi

    log_info "Single bundles created in: ${out_dir} (processed ${processed} image groups)"
}

process_section() {
    local target_section="$1"

    local in_section=false
    local section_module=""
    local section_type=""
    local section_path=""
    local section_images=()

    while IFS= read -r line; do
        if [[ "$line" =~ ^#\ @module= ]]; then
            if [ "$in_section" = true ]; then
                break
            fi

            local mod_val
            mod_val=$(echo "$line" | sed 's/.*@module=\([^ ]*\).*/\1/')
            local type_val
            type_val=$(echo "$line" | sed 's/.*@type=\([^ ]*\).*/\1/')
            local path_val
            path_val=$(echo "$line" | sed 's/.*@path=\([^ ]*\).*/\1/')

            if [ "$mod_val" = "$target_section" ]; then
                in_section=true
                section_module="$mod_val"
                section_type="$type_val"
                section_path="$path_val"
            fi
        elif [ "$in_section" = true ]; then
            if [ -n "$line" ]; then
                section_images+=("$line")
            fi
        fi
    done < "$INTERNAL_FILE"

    if [ "$in_section" = false ]; then
        log_error "Section '${target_section}' not found in ${INTERNAL_FILE}"
        return 1
    fi

    log_info "Processing section: ${section_module} (type=${section_type}, path=${section_path})"

    if [ "$section_type" = "combined" ]; then
        local images_only=()
        for item in "${section_images[@]}"; do
            [[ "$item" =~ ^# ]] || images_only+=("$item")
        done
        create_combined_bundle "$section_module" "$section_path" "${images_only[@]}"
    elif [ "$section_type" = "single" ]; then
        create_single_bundles "$section_module" "$section_path" "${section_images[@]}"
    else
        log_error "Unknown bundle type: ${section_type}"
        return 1
    fi
}

get_all_sections() {
    grep '# @module=' "$INTERNAL_FILE" | sed 's/.*@module=\([^ ]*\).*/\1/'
}

if [ "$PROCESS_ALL" = true ]; then
    sections=$(get_all_sections)
    total=$(echo "$sections" | wc -l | tr -d '[:space:]')
    idx=0
    for sec in $sections; do
        idx=$((idx + 1))
        log_info "[${idx}/${total}] Processing section: ${sec}"
        process_section "$sec"
    done
    log_info "All ${total} sections processed"
else
    process_section "$SECTION"
fi

log_info "Bundle creation complete"
