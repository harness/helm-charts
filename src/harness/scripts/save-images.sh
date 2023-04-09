#!/bin/bash

images="harness-airgapped-images.tar.gz"
list="images.txt"

while IFS= read -r i; do 
    [ -z "${i}" ] && continue
    if [ $(docker pull --quiet "${i}") ]; then
        echo "Image pull success: ${i}"
        pulled="${pulled} ${i}"
    else
        echo "Image pull failed: ${i}"
    fi
done < "${list}"

echo "Creating ${images} with $(echo ${pulled} | wc -w | tr -d '[:space:]') images"
docker save $(echo ${pulled}) | gzip --stdout > ${images}