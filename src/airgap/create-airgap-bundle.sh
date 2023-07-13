#!/bin/sh

export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Provide lists of image names
lists=("platform_images.txt" "ccm_images.txt" "cdng_images.txt" "ci_images.txt" 
"ce_images.txt" "sto_images.txt" "srm_images.txt" "ff_images.txt")

pull_image() {
    i="$1"
    if docker pull --quiet "${i}"; then
        echo "Image pull success: ${i}"
        echo "${i}" >> "${pulled_file}"
    else
        echo "Image pull failed: ${i}"
    fi
}

# Loop through each list
for list in ${lists[*]}; do

  # Generate image file name from list name
  base_name=$(basename "$list" .txt)
  images_file="${base_name}.tgz"

  # Create a temporary file to store the list of successfully pulled images
  pulled_file="$(mktemp)"

  # Download images in parallel
  while IFS= read -r i; do
      [ -z "${i}" ] && continue
      pull_image "${i}" &
  done < "${list}"

  # Wait for all background tasks to finish
  wait

  # Get the list of successfully pulled images
  pulled=$(cat "${pulled_file}")

  # Save pulled images to a tarball
  echo "Creating ${images_file} with $(echo ${pulled} | wc -w | tr -d '[:space:]') images"
  docker save $(echo ${pulled}) | gzip --stdout > ${images_file}

  # Remove temporary file
  rm "${pulled_file}"
done
