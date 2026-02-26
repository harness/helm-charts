#!/bin/bash

set -o errexit
set -o pipefail

log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*" >&2; }

usage () {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -i, --image-gen-input <path>  Path to generate-image.yaml overrides file"
    echo "  -o, --output-dir <path>       Output directory for images_raw.txt"
    echo "  -d, --harness-dir <path>      Path to harness chart directory"
    echo "  -h, --help                    Show this help message"
    echo ""
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
HARNESS_DIR=${SCRIPT_DIR}/harness
IMAGE_GEN_INPUT_FILE=${SCRIPT_DIR}/generate-image.yaml
OUTPUT_DIR=${SCRIPT_DIR}/harness

while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -i|--image-gen-input)
            IMAGE_GEN_INPUT_FILE="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -d|--harness-dir)
            HARNESS_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

CHART_YAML="${HARNESS_DIR}/Chart.yaml"
if [ ! -f "${CHART_YAML}" ]; then
    log_error "Chart.yaml not found at ${CHART_YAML}"
    exit 1
fi

log_info "Auto-detecting module conditions from Chart.yaml"
AUTO_ENABLE_FLAGS=""
while IFS= read -r condition; do
    condition=$(echo "$condition" | xargs)
    [ -z "$condition" ] && continue
    AUTO_ENABLE_FLAGS="${AUTO_ENABLE_FLAGS} --set ${condition}=true"
done < <(grep "condition:" "${CHART_YAML}" | awk -F'condition:' '{print $2}')

if [ -n "${AUTO_ENABLE_FLAGS}" ]; then
    log_info "Auto-enabled flags:${AUTO_ENABLE_FLAGS}"
fi

OVERRIDE_FLAGS=""
if [ -f "${IMAGE_GEN_INPUT_FILE}" ]; then
    OVERRIDE_FLAGS="-f ${IMAGE_GEN_INPUT_FILE}"
    log_info "Using overrides from ${IMAGE_GEN_INPUT_FILE}"
fi

log_info "Running helm template to extract images"
helm template ${HARNESS_DIR} ${AUTO_ENABLE_FLAGS} ${OVERRIDE_FLAGS} \
    | grep -i image | grep \/ | grep -v imagePullPolicy | grep -v "#" \
    | awk '{$1=$1};1' | sort -u \
    | sed 's/^[^:]*: //g' \
    | sed -e "s/^'//" -e "s/'$//" \
    | sed -e 's/^"//' -e 's/"$//' \
    > ${OUTPUT_DIR}/images_tmp.txt

awk -F: '{ print $1 ":" $2 }' ${OUTPUT_DIR}/images_tmp.txt | sort -u > ${OUTPUT_DIR}/images_raw.txt
rm ${OUTPUT_DIR}/images_tmp.txt

sed -i '' -e '/index\.docker\.io\/chaosnative:/d' -e '/^$/d' ${OUTPUT_DIR}/images_raw.txt 2>/dev/null || \
    sed -i -e '/index\.docker\.io\/chaosnative:/d' -e '/^$/d' ${OUTPUT_DIR}/images_raw.txt

IMAGE_COUNT=$(wc -l < ${OUTPUT_DIR}/images_raw.txt | tr -d '[:space:]')
log_info "Generated images_raw.txt with ${IMAGE_COUNT} base images (no variants)"

log_info "Resolving bundle manifest to generate images.txt and images_internal.txt"
if command -v python3 &>/dev/null; then
    python3 ${SCRIPT_DIR}/generate_bundle_images.py \
        --manifest ${SCRIPT_DIR}/bundle-manifest.yaml \
        --raw-images ${OUTPUT_DIR}/images_raw.txt \
        --output-dir ${OUTPUT_DIR}
else
    log_error "python3 not found - cannot resolve bundle manifest"
    exit 1
fi

log_info "Image generation complete"
exit 0
