#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

helm template ${SCRIPT_DIR}/harness -f  ${SCRIPT_DIR}/generate-image.yaml | grep -i image | grep \/ | grep -v imagePullPolicy | grep -v "#" | awk '{$1=$1};1' | sort -u | sed 's/^[^:]*: //g' | sed -e "s/^'//" -e "s/'$//"| sed -e 's/^"//' -e 's/"$//' > ${SCRIPT_DIR}/harness/images_tmp.txt

# Remove duplicates based on image name and tag
awk -F: '{ print $1 ":" $2 }' ${SCRIPT_DIR}/harness/images_tmp.txt | sort -u > ${SCRIPT_DIR}/harness/images.txt

rm ${SCRIPT_DIR}/harness/images_tmp.txt

# Add minimal images
IMAGES=("docker.io/harness/delegate:[0-9.]+" "docker.io/harness/delegate-proxy-signed:[0-9.]+")
SUFFIX=(".minimal" "_minimal")
for i in "${!IMAGES[@]}"
do
    MATCHES=$(grep -oE "${IMAGES[i]}" "src/harness/images.txt")
    if [ -n "$MATCHES" ]; then
        echo "$MATCHES" | sed "s/$/${SUFFIX[i]}/" | tee -a src/harness/images.txt
    fi
done

# Remove duplicates one more time in case minimal images have added any
awk -F: '{ print $1 ":" $2 }' ${SCRIPT_DIR}/harness/images.txt | sort -u > ${SCRIPT_DIR}/harness/images_tmp.txt
mv ${SCRIPT_DIR}/harness/images_tmp.txt ${SCRIPT_DIR}/harness/images.txt

exit 0
