#!/bin/bash

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)

helm template ${SCRIPT_DIR}/harness | grep docker.io | sort -u  | sed 's/^[^:]*: //g' | sed -e 's/^[ \t]*//' > src/harness/images.txt

exit 0