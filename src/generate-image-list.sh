#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

helm template ${SCRIPT_DIR}/harness -f  ${SCRIPT_DIR}/generate-image.yaml | grep -i image | grep \/ | grep -v imagePullPolicy | grep -v "#" | awk '{$1=$1};1' | sort -u | sed 's/^[^:]*: //g' | sed -e "s/^'//" -e "s/'$//"| sed -e 's/^"//' -e 's/"$//' > src/harness/images.txt

# Add minimal images
IMAGES=("docker.io/harness/delegate:[0-9.]+" "docker.io/harness/delegate-proxy-signed:[0-9.]+")
SUFFIX=".minimal"
for search_item in "${IMAGES[@]}"
do
    MATCHES=$(grep -oE "$search_item" "src/harness/images.txt")
    if [ -n "$MATCHES" ]; then
        echo "$MATCHES" | sed "s/$/$SUFFIX/" | tee -a src/harness/images.txt
    fi
done

exit 0
