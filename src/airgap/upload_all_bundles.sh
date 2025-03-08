#!/bin/bash


# Array of files to upload
files=("${MODULE_IMAGE_ZIP_FILES[@]}")

# Iterate over the files and upload each one
for file in "${files[@]}"; do
    echo "Uploading $file"
done
