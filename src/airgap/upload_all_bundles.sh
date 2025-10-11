#!/bin/bash
set -euo pipefail

# ========================
# Functions
# ========================

upload_to_bucket() {
    local cred_file="$1"
    local source_file="$2"
    local dest_path="$3"

    export GOOGLE_APPLICATION_CREDENTIALS="$cred_file"

    echo "📤 Uploading $source_file to $dest_path ..."
    if ! gsutil cp "$source_file" "$dest_path"; then
        echo "❌ Error uploading $source_file"
        exit 1
    fi
    echo "✅ Uploaded: $source_file → $dest_path"
}

# ========================
# Input Parsing
# ========================

if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <credential_file> <release_number> <bucket_path>"
    echo "Example: $0 /tmp/wif_cred.json 0.19.1 gs://smp-airgap-bundles"
    exit 1
fi

credential_file=$1
release_number=$2
bucket_path=$3

# ========================
# Auth Setup
# ========================

echo "🔐 Authenticating using $credential_file ..."

# Detect whether this is a WIF config or a Service Account key
if grep -q '"credential_source"' "$credential_file"; then
    echo "Detected Workload Identity Federation credentials"
    export GOOGLE_APPLICATION_CREDENTIALS="$credential_file"
else
    echo "Detected Service Account key"
    gcloud auth activate-service-account --key-file="$credential_file" >/dev/null 2>&1 || {
        echo "❌ Failed to activate service account"
        exit 1
    }
fi

gcloud auth list

# ========================
# Collect files
# ========================

files=()
for moduleImageZipFile in $MODULE_IMAGE_ZIP_FILES; do
    files+=("$moduleImageZipFile")
done

if [[ ${#files[@]} -le 2 ]]; then
    echo "Error: No module image zip files provided. Files: ${files[@]}" >&2
    exit 1
fi

# ========================
# Prepare bucket path
# ========================

release_path="${bucket_path%/}/$release_number"

echo "📁 Preparing release folder: $release_path"
touch empty_file
gsutil cp empty_file "$release_path/" >/dev/null
rm -f empty_file

# ========================
# Upload files
# ========================

for file in "${files[@]}"; do
    upload_to_bucket "$credential_file" "$file" "$release_path/$(basename "$file")"
done

# ========================
# Cleanup
# ========================

gsutil rm "$release_path/empty_file" >/dev/null || true

echo "🎉 Uploaded all bundles successfully: https://console.cloud.google.com/storage/browser/${bucket_path#gs://}/$release_number"
