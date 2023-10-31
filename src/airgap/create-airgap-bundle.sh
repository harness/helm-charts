#!/bin/bash

set -e

handle_error() {
    echo "Error $1" >&2
    exit 1
}

export DOCKER_DEFAULT_PLATFORM=linux/amd64

# Provide lists of image names
lists=("cdng_images.txt" "ci_images.txt" "platform_images.txt" "ccm_images.txt" 
"ce_images.txt" "sto_images.txt" "cet_images.txt" "ff_images.txt")

pull_image() {
    i="$1"
    if docker pull --quiet "${i}"; then
        echo "Image pull success: ${i}"
        echo "${i}" >> "${pulled_file}"
    else
        handle_error "Image pull failed: ${i}"
    fi
}

# Check if an image name parameter is provided
if [ $# -eq 1 ]; then
    image_list_file="$1"
    if [[ ! -f $image_list_file ]]; then
        echo "Error: File $image_list_file not found."
        exit 1
    fi

    # Generate image file name from the list name
    base_name=$(basename "$image_list_file" .txt)
    images_file="${base_name}.tgz"
    
    # Create a temporary file to store the list of successfully pulled images
    pulled_file="$(mktemp)"

    pids=()

    # Download images in parallel
    while IFS= read -r i; do
        [ -z "${i}" ] && continue
        pull_image "${i}" &
        pids+=($!)
    done < "${image_list_file}"

    for pid in ${pids[*]}; do
        wait $pid || handle_error "Failed background task with PID: $pid"
    done
    # Wait for all background tasks to finish
    wait

    # Get the list of successfully pulled images
    pulled=$(cat "${pulled_file}")

    # Save pulled images to a tarball
    echo "Creating ${images_file} with $(echo ${pulled} | wc -w | tr -d '[:space:]') images"
    docker save $(echo ${pulled}) | gzip --stdout > ${images_file} || handle_error "Failed to create tarball: ${images_file}"

    # Remove temporary file
    rm "${pulled_file}" || handle_error "Failed to remove temporary file: ${pulled_file}"

    # Cleanup: Remove the pulled images
    #for image in ${pulled}; do
    #    docker rmi -f ${image}
    #done
else
    # Loop through each list
    for list in ${lists[*]}; do
        if [[ ! -f $list ]]; then
            echo "Error: File $list not found."
            exit 1
        fi

        # Generate image file name from list name
        base_name=$(basename "$list" .txt)
        images_file="${base_name}.tgz"
        list_file="${list}"

        # Create a temporary file to store the list of successfully pulled images
        pulled_file="$(mktemp)"

        pids=()

        # Download images in parallel
        while IFS= read -r i; do
            [ -z "${i}" ] && continue
            pull_image "${i}" &
            pids+=($!)
        done < "${list}"

        for pid in ${pids[*]}; do
            wait $pid || handle_error "Failed background task with PID: $pid"
        done
        # Wait for all background tasks to finish
        wait

        # Get the list of successfully pulled images
        pulled=$(cat "${pulled_file}")

        # Save pulled images to a tarball
        echo "Creating ${images_file} with $(echo ${pulled} | wc -w | tr -d '[:space:]') images"
        docker save $(echo ${pulled}) | gzip --stdout > ${images_file} || handle_error "Failed to create tarball: ${images_file}"

        # Remove temporary file
        rm "${pulled_file}" || handle_error "Failed to remove temporary file: ${pulled_file}"

        # Cleanup: Remove the pulled images
        #for image in ${pulled}; do
        #    docker rmi -f ${image}
        #done
    done
fi
