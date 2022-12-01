#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

helm template ${SCRIPT_DIR}/harness -f ${SCRIPT_DIR}/generate-image.yaml | grep docker.io | sort -u  | sed 's/^[^:]*: //g' | sed -e 's/^[ \t]*//' | sed -e 's/^"//' -e 's/"$//' > harness/images.txt

exit 0