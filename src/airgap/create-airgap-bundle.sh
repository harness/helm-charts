#!/bin/sh

export DOCKER_DEFAULT_PLATFORM=linux/amd64

images="harness-airgapped-images.tgz"
list="airgapped-images.txt"

pull_image() {
    i="$1"
    if docker pull --quiet "${i}"; then
        echo "Image pull success: ${i}"
        echo "${i}" >> "${pulled_file}"
    else
        echo "Image pull failed: ${i}"
    fi
}

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
echo "Creating ${images} with $(echo ${pulled} | wc -w | tr -d '[:space:]') images"
docker save $(echo ${pulled}) | gzip --stdout > ${images}

# Remove temporary file
rm "${pulled_file}"
