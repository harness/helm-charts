#!/bin/bash
set -e

log_info()  { echo "[INFO]  $(date +%H:%M:%S) $*"; }
log_warn()  { echo "[WARN]  $(date +%H:%M:%S) $*" >&2; }
log_error() { echo "[ERROR] $(date +%H:%M:%S) $*" >&2; }
log_debug() { [ "${DEBUG:-false}" = "true" ] && echo "[DEBUG] $(date +%H:%M:%S) $*"; }

usage() {
    echo "Usage: $0 <service_account_file> <release_number>"
    echo ""
    echo "  service_account_file  Path to GCP service account JSON key file"
    echo "  release_number        Release version (e.g., 1.0.0)"
    echo ""
    echo "Uploads the bundle output directory to gs://smp-airgap-bundles/<release_number>/"
    echo "Uploads bundle-manifest.yaml and images.txt."
    exit 1
}

if [ $# -lt 2 ]; then
    log_error "Missing required arguments"
    usage
fi

SERVICE_ACCOUNT_FILE="$1"
RELEASE_NUMBER="$2"
BUCKET="gs://smp-airgap-bundles"
RELEASE_PATH="${BUCKET}/${RELEASE_NUMBER}"

if [ ! -f "$SERVICE_ACCOUNT_FILE" ]; then
    log_error "Service account file not found: $SERVICE_ACCOUNT_FILE"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Find output directory: look for platform/ or *.tgz in current dir
OUTPUT_DIR=""
if [ -d "platform" ] || [ -d "ci" ]; then
    OUTPUT_DIR="$(pwd)"
elif [ -d "output/platform" ] || [ -d "output/ci" ]; then
    OUTPUT_DIR="$(pwd)/output"
else
    # Look for any .tgz in current dir or subdirs
    if find . -maxdepth 2 -name "*.tgz" -type f 2>/dev/null | head -1 | grep -q .; then
        OUTPUT_DIR="$(pwd)"
    else
        log_error "Could not find output directory (look for platform/, ci/, or *.tgz)"
        exit 1
    fi
fi

log_info "Using output directory: ${OUTPUT_DIR}"

# Find bundle-manifest.yaml and images.txt
BUNDLE_MANIFEST=""
IMAGES_TXT=""

if [ -f "${OUTPUT_DIR}/bundle-manifest.yaml" ]; then
    BUNDLE_MANIFEST="${OUTPUT_DIR}/bundle-manifest.yaml"
elif [ -f "${SRC_DIR}/bundle-manifest.yaml" ]; then
    BUNDLE_MANIFEST="${SRC_DIR}/bundle-manifest.yaml"
fi

if [ -f "${OUTPUT_DIR}/images.txt" ]; then
    IMAGES_TXT="${OUTPUT_DIR}/images.txt"
elif [ -f "${SRC_DIR}/harness/images.txt" ]; then
    IMAGES_TXT="${SRC_DIR}/harness/images.txt"
elif [ -f "${OUTPUT_DIR}/harness/images.txt" ]; then
    IMAGES_TXT="${OUTPUT_DIR}/harness/images.txt"
fi

if [ -z "$BUNDLE_MANIFEST" ]; then
    log_error "bundle-manifest.yaml not found"
    exit 1
fi

if [ -z "$IMAGES_TXT" ]; then
    log_error "images.txt not found"
    exit 1
fi

log_info "Activating gcloud with service account: ${SERVICE_ACCOUNT_FILE}"
gcloud auth activate-service-account --key-file="${SERVICE_ACCOUNT_FILE}" --quiet

log_info "Uploading bundle hierarchy to ${RELEASE_PATH}/"
FILE_COUNT_BEFORE=0
FILE_COUNT_AFTER=0

# Count files before (approximate)
FILE_COUNT_BEFORE=$(find "${OUTPUT_DIR}" -type f 2>/dev/null | wc -l | tr -d '[:space:]')

log_info "Running gsutil -m rsync -r..."
gsutil -m rsync -r -x "images_internal\.txt$" "${OUTPUT_DIR}" "${RELEASE_PATH}/"

# Upload manifest and images.txt to release folder root
log_info "Uploading bundle-manifest.yaml and images.txt to ${RELEASE_PATH}/"
gsutil cp "${BUNDLE_MANIFEST}" "${RELEASE_PATH}/bundle-manifest.yaml"
gsutil cp "${IMAGES_TXT}" "${RELEASE_PATH}/images.txt"

# Get file count from GCS (approximate)
FILE_COUNT_AFTER=$(gsutil ls -r "${RELEASE_PATH}/**" 2>/dev/null | wc -l | tr -d '[:space:]')

echo ""
log_info "=== UPLOAD SUMMARY ==="
log_info "Bucket path: ${RELEASE_PATH}/"
log_info "Files uploaded: ~${FILE_COUNT_AFTER} (including manifest and images.txt)"
log_info "bundle-manifest.yaml: ${RELEASE_PATH}/bundle-manifest.yaml"
log_info "images.txt: ${RELEASE_PATH}/images.txt"
log_info "Upload complete."
