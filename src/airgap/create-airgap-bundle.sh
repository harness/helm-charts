#!/bin/bash

set -e

log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_warn()  { echo "[WARN]  $(date +%H:%M:%S) $*" >&2; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*" >&2; }

SKOPEO_ARCH="${SKOPEO_ARCH:-amd64}"
SKOPEO_OS="${SKOPEO_OS:-linux}"

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
MAX_PARALLEL_BUNDLES="${MAX_PARALLEL_BUNDLES:-4}"

for cmd in skopeo pigz jq; do
    if ! command -v "$cmd" &>/dev/null; then
        log_error "Required command not found: ${cmd}"
        exit 1
    fi
done

copy_image() {
    local image="$1"
    local output_tar="$2"
    local attempt=0
    local delay="${PULL_RETRY_DELAY}"

    while [ $attempt -lt "${MAX_PULL_RETRIES}" ]; do
        attempt=$((attempt + 1))
        if skopeo copy --quiet \
            --override-arch "${SKOPEO_ARCH}" --override-os "${SKOPEO_OS}" \
            "docker://${image}" "docker-archive:${output_tar}:${image}" 2>&1; then
            log_info "Copied (attempt ${attempt}): ${image}"
            return 0
        fi
        if [ $attempt -lt "${MAX_PULL_RETRIES}" ]; then
            log_warn "Copy attempt ${attempt}/${MAX_PULL_RETRIES} failed for: ${image} — retrying in ${delay}s"
            sleep "${delay}"
            delay=$((delay * 2))
        fi
    done

    log_error "Failed to copy after ${MAX_PULL_RETRIES} attempts: ${image}"
    return 1
}

# Run at most MAX_PARALLEL_PULLS copies concurrently to avoid registry rate limiting.
copy_images_bounded() {
    local staging_dir="$1"
    shift
    local images=("$@")
    local failed=0
    local pids=()
    local active=0
    local idx=0

    for img in "${images[@]}"; do
        copy_image "${img}" "${staging_dir}/image_${idx}.tar" </dev/null &
        pids+=($!)
        active=$((active + 1))
        idx=$((idx + 1))

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

# Merge individual docker-archive tars into a single archive compressed with pigz.
# Each input tar has its own manifest.json; the merged output contains a combined
# manifest so that `docker load` restores all images at once.
merge_and_compress() {
    local tgz_file="$1"
    local staging_dir="$2"

    local merge_dir
    merge_dir="$(mktemp -d)"
    local combined_manifest="[]"

    for tar_file in "${staging_dir}"/*.tar; do
        [ -f "$tar_file" ] || continue

        local this_manifest
        this_manifest=$(tar -xf "$tar_file" -O manifest.json 2>/dev/null) || {
            log_error "Failed to read manifest.json from ${tar_file}"
            rm -rf "${merge_dir}"
            return 1
        }
        combined_manifest=$(echo "${combined_manifest}" | jq --argjson new "${this_manifest}" '. + $new')

        # Layers and configs are content-addressed; duplicates overwrite harmlessly.
        tar -xf "$tar_file" -C "${merge_dir}"
    done

    echo "${combined_manifest}" > "${merge_dir}/manifest.json"

    tar -cf - -C "${merge_dir}" . | pigz > "${tgz_file}"
    rm -rf "${merge_dir}"
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

    local staging_dir
    staging_dir="$(mktemp -d)"

    log_info "Copying ${#images[@]} images for combined bundle: ${section_name} (parallel limit: ${MAX_PARALLEL_PULLS}, retries: ${MAX_PULL_RETRIES})"

    if ! copy_images_bounded "${staging_dir}" "${images[@]}"; then
        log_error "Some images failed to copy for section: ${section_name}"
        rm -rf "${staging_dir}"
        return 1
    fi

    local count
    count=$(find "${staging_dir}" -name '*.tar' | wc -l | tr -d '[:space:]')
    log_info "Creating ${tgz_file} with ${count} images"

    merge_and_compress "${tgz_file}" "${staging_dir}"
    rm -rf "${staging_dir}"

    log_info "Combined bundle created: ${tgz_file}"
}

bundle_one_image() {
    local out_dir="$1"
    local img_name="$2"
    shift 2
    local img_tags=("$@")

    if [ ${#img_tags[@]} -eq 0 ]; then
        return
    fi

    local tgz_file="${out_dir}/${img_name}.tgz"
    local staging_dir
    staging_dir="$(mktemp -d)"

    log_info "Copying ${#img_tags[@]} tags for single bundle: ${img_name}"

    if ! copy_images_bounded "${staging_dir}" "${img_tags[@]}"; then
        log_error "Some tags failed to copy for image: ${img_name}"
        rm -rf "${staging_dir}"
        return 1
    fi

    local count
    count=$(find "${staging_dir}" -name '*.tar' | wc -l | tr -d '[:space:]')
    log_info "Creating ${tgz_file} with ${count} tags"

    merge_and_compress "${tgz_file}" "${staging_dir}"
    rm -rf "${staging_dir}"

    log_info "Single bundle created: ${tgz_file}"
}

create_single_bundles() {
    local section_name="$1"
    local bucket_path="$2"
    shift 2
    local section_lines=("$@")

    local out_dir="${OUTPUT_DIR}/${bucket_path}"
    mkdir -p "${out_dir}"

    # Parse all image groups before dispatching so we can parallelize.
    local -a group_names=()
    local -a group_tags=()
    local current_name=""
    local current_tags=""

    for line in "${section_lines[@]}"; do
        if [[ "$line" =~ ^#\ @image= ]]; then
            if [ -n "$current_name" ] && [ -n "$current_tags" ]; then
                group_names+=("$current_name")
                group_tags+=("$current_tags")
            fi
            current_name="${line#*@image=}"
            current_tags=""
        elif [ -n "$line" ] && [[ ! "$line" =~ ^# ]]; then
            current_tags="${current_tags:+${current_tags}$'\n'}${line}"
        fi
    done

    if [ -n "$current_name" ] && [ -n "$current_tags" ]; then
        group_names+=("$current_name")
        group_tags+=("$current_tags")
    fi

    local total=${#group_names[@]}
    log_info "Bundling ${total} image groups for: ${section_name} (parallel limit: ${MAX_PARALLEL_BUNDLES})"

    local pids=()
    local active=0
    local failed=0

    for i in "${!group_names[@]}"; do
        local name="${group_names[$i]}"
        local tags_str="${group_tags[$i]}"

        local -a tags_arr=()
        while IFS= read -r t; do
            [ -n "$t" ] && tags_arr+=("$t")
        done <<< "$tags_str"

        bundle_one_image "$out_dir" "$name" "${tags_arr[@]}" </dev/null &
        pids+=($!)
        active=$((active + 1))

        if [ "$active" -ge "${MAX_PARALLEL_BUNDLES}" ]; then
            wait "${pids[0]}" || failed=1
            pids=("${pids[@]:1}")
            active=$((active - 1))
        fi
    done

    for pid in "${pids[@]}"; do
        wait "$pid" || failed=1
    done

    if [ $failed -eq 1 ]; then
        log_error "Some single bundles failed for section: ${section_name}"
        return 1
    fi

    log_info "Single bundles created in: ${out_dir} (processed ${total} image groups)"
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
