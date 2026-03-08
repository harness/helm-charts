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
    echo "  -o, --output-dir <path>       Output directory for generated files"
    echo "  -d, --harness-dir <path>      Path to harness chart directory"
    echo "  -k, --keep-transient          Keep images_raw.txt and images_internal.txt"
    echo "  -h, --help                    Show this help message"
    echo ""
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
HARNESS_DIR=${SCRIPT_DIR}/harness
IMAGE_GEN_INPUT_FILE=${SCRIPT_DIR}/generate-image.yaml
OUTPUT_DIR=${SCRIPT_DIR}/harness
KEEP_TRANSIENT=false

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
        -k|--keep-transient)
            KEEP_TRANSIENT=true
            shift
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

if ! command -v python3 &>/dev/null; then
    log_error "python3 not found - cannot resolve bundle manifest"
    exit 1
fi

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
    log_info "Auto-enabled module flags:${AUTO_ENABLE_FLAGS}"
fi


# Auto-flip all enabled:false and create:false keys from values.yaml to true.
# Covers sub-component flags (metrics exporters, ingress, monitoring, etc.)
# not listed as Chart.yaml conditions. See smp-tools.py auto-enable-flags for BLOCKLIST.
VALUES_YAML="${HARNESS_DIR}/values.yaml"
VALUES_FLAGS=""
if [ -f "${VALUES_YAML}" ]; then
    log_info "Scanning ${VALUES_YAML} for disabled flags to enable"
    while IFS= read -r flag; do
        [ -z "$flag" ] && continue
        VALUES_FLAGS="${VALUES_FLAGS} ${flag}"
    done < <(python3 "${SCRIPT_DIR}/smp-tools.py" auto-enable-flags "${VALUES_YAML}")
    if [ -n "${VALUES_FLAGS}" ]; then
        log_info "Auto-enabled values flags:${VALUES_FLAGS}"
    fi
fi

AUTO_ENABLE_FLAGS="${AUTO_ENABLE_FLAGS}${VALUES_FLAGS}"


OVERRIDE_FLAGS=""
if [ -f "${IMAGE_GEN_INPUT_FILE}" ]; then
    log_info "Extracting --set flags from ${IMAGE_GEN_INPUT_FILE}"
    while IFS= read -r flag; do
        [ -z "$flag" ] && continue
        OVERRIDE_FLAGS="${OVERRIDE_FLAGS} ${flag}"
    done < <(python3 "${SCRIPT_DIR}/smp-tools.py" auto-enable-flags --mode true "${IMAGE_GEN_INPUT_FILE}")
    if [ -n "${OVERRIDE_FLAGS}" ]; then
        log_info "Override flags from ${IMAGE_GEN_INPUT_FILE}:${OVERRIDE_FLAGS}"
    fi
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
python3 ${SCRIPT_DIR}/smp-tools.py bundle-images \
    --manifest ${SCRIPT_DIR}/bundle-manifest.yaml \
    --raw-images ${OUTPUT_DIR}/images_raw.txt \
    --output-dir ${OUTPUT_DIR}

log_info "Running bundle manifest validation"
python3 ${SCRIPT_DIR}/smp-tools.py validate-bundle \
    --manifest ${SCRIPT_DIR}/bundle-manifest.yaml

if [ "${KEEP_TRANSIENT}" = false ]; then
    log_info "Cleaning up transient files"
    rm -f ${OUTPUT_DIR}/images_raw.txt
    rm -f ${OUTPUT_DIR}/images_internal.txt
else
    log_info "Keeping transient files (--keep-transient)"
fi

log_info "Image generation complete"
exit 0
