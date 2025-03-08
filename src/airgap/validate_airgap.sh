#!/bin/bash

MODULE_NAMES=("${MODULES[@]}")

abort() {
    echo "Error: $1"
    exit 1
}

for module_name in "${MODULE_NAMES[@]}"; do
    echo "Validating ${module_name}..."
    TGZ_FILE="${module_name}_images.tgz"
    TXT_FILE="${module_name}_images.txt"

    [[ ! -f "${TGZ_FILE}" ]] && abort "${TGZ_FILE} not found!"

    # Extract the image tags and format them
    IMAGES_LIST=$(tar -xzOf "${TGZ_FILE}" manifest.json | jq -r '.[].RepoTags | join("\n")')

    [[ ! -f "${TXT_FILE}" ]] && abort "${TXT_FILE} not found!"
    
    echo "Matching images for ${TGZ_FILE} and ${TXT_FILE}:"
    
    mismatched=false
    
    # Count the number of images in .tgz and .txt
    num_images_tgz=$(echo "$IMAGES_LIST" | wc -l)
    num_images_txt=$(wc -l < "${TXT_FILE}")
    
    if [ "$num_images_tgz" -ne "$num_images_txt" ]; then
       abort "Number of images in ${TGZ_FILE} does not match ${TXT_FILE}"
    fi
    
    while IFS= read -r line; do
       line_without_prefix="${line#docker.io/}"
    
       if [[ "$IMAGES_LIST" =~ "$line" || "$IMAGES_LIST" =~ "$line_without_prefix" ]]; then
           echo "$line"
       else
           mismatched=true
           echo "Mismatch found: $line"
       fi
    done < "${TXT_FILE}"
    
    if $mismatched; then
       abort "Images in ${TGZ_FILE} and ${TXT_FILE} do not match"
    fi

    echo "--------------------------------"
done
