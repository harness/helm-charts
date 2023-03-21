#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

helm template ${SCRIPT_DIR}/harness -f  ${SCRIPT_DIR}/generate-image.yaml | grep -i image | grep \/ | grep -v imagePullPolicy | grep -v "#" | awk '{$1=$1};1' | sort -u | sed 's/^[^:]*: //g' | sed -e "s/^'//" -e "s/'$//"| sed -e 's/^"//' -e 's/"$//' > src/harness/images.txt

exit 0