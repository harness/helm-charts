#!/bin/bash

upload_to_bucket() {
    export GOOGLE_APPLICATION_CREDENTIALS=$1
    gsutil_command=("gsutil" "cp" "$2" "$3")

    if ! "${gsutil_command[@]}"; then
        echo "An error occurred while uploading the file: $?"
        exit 1
    fi

    echo "File $2 uploaded to $3."
}

# Define the bucket path
bucket_path="gs://smp-airgap-bundles"

# Parse command line arguments
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <service_account_file> <release_number>"
    exit 1
fi

service_account_file=$1
release_number=$2

# Array of files to upload
for moduleImageZipFile in $MODULE_IMAGE_ZIP_FILES; do
    files+=("$moduleImageZipFile")
done

if [ ${#files[@]} -le 2 ]; then # validation with 2 to make sure multiple elements are in list
    echo "Error: No module image zip files provided. Files: ${files[@]}" >&2
    exit 1
fi

# Create an empty file and upload it to the destination bucket path
touch empty_file
gsutil cp empty_file "$bucket_path/$release_number/"

# Iterate over the files and upload each one
for file in "${files[@]}"; do
    upload_to_bucket "$service_account_file" "$file" "$bucket_path/$release_number/$file"
done

# Remove the empty file from the release number directory
gsutil rm "$bucket_path/$release_number/empty_file"
