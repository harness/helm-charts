#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No release number supplied as command line argument."
    echo "Usage: ./upload_bundles.sh release_number (harness-x.x.x)"
    exit 1
fi

release_number=$1

files=("platform_images.tgz" "cdng_images.tgz" "ccm_images.tgz" "srm_images.tgz" "ce_images.tgz" "ff_images.tgz" "ci_images.tgz" "sto_images.tgz")

touch empty_file
gsutil cp empty_file gs://smp-airgap-bundles/${release_number}/

for file in "${files[@]}"
do
    python3 upload.py service_account_key.json "$file"
    gsutil mv gs://smp-airgap-bundles/"$file" gs://smp-airgap-bundles/${release_number}/
done

gsutil rm gs://smp-airgap-bundles/${release_number}/empty_file
