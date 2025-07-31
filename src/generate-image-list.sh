#!/bin/bash

usage () {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -i, --image-gen-input ${SCRIPT_DIR}/generate-image.yaml  Path to generate-image.yaml file"
    echo "  -o, --output-dir ${SCRIPT_DIR}/harness Path to directory in which images.txt is to be generated"
    echo "  -d, --harness-dir ${SCRIPT_DIR}/harness Path to harness directory"
    echo "  -h, --help             Show this help message"
    echo ""
}

SCRIPT_DIR=$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)
HARNESS_DIR=${SCRIPT_DIR}/harness
IMAGE_GEN_INPUT_FILE=${SCRIPT_DIR}/generate-image.yaml
OUTPUT_DIR=${SCRIPT_DIR}/harness


while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -i|--image-gen-input)
            IMAGE_GEN_INPUT_FILE="$2"
            shift 2
            ;;
        -o|--output-dir)
            OUTPUT_DIR="$2"
            shift 2
            ;;
        -d|--harness-dir)
            HARNESS_DIR="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit
            ;;
        *)
            echo "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done



helm template ${HARNESS_DIR} -f  ${IMAGE_GEN_INPUT_FILE} | grep -i image | grep \/ | grep -v imagePullPolicy | grep -v "#" | awk '{$1=$1};1' | sort -u | sed 's/^[^:]*: //g' | sed -e "s/^'//" -e "s/'$//"| sed -e 's/^"//' -e 's/"$//' > ${OUTPUT_DIR}/images_tmp.txt

# Remove duplicates based on image name and tag
awk -F: '{ print $1 ":" $2 }' ${OUTPUT_DIR}/images_tmp.txt | sort -u > ${OUTPUT_DIR}/images.txt

rm ${OUTPUT_DIR}/images_tmp.txt

# Add minimal images
IMAGES=("docker.io/harness/delegate:[0-9.]+")
SUFFIX=(".minimal" ".minimal-fips" "-fips")
for i in "${!IMAGES[@]}"
do
    MATCHES=$(grep -oE "${IMAGES[i]}" "${OUTPUT_DIR}/images.txt")
    if [ -n "$MATCHES" ]; then
        for j in "${!SUFFIX[@]}"
        do
          echo "$MATCHES" | sed "s/$/${SUFFIX[j]}/" | tee -a ${OUTPUT_DIR}/images.txt
        done
    fi
done

# Remove duplicates one more time in case minimal images have added any
awk -F: '{ print $1 ":" $2 }' ${OUTPUT_DIR}/images.txt | sort -u > ${OUTPUT_DIR}/images_tmp.txt
mv ${OUTPUT_DIR}/images_tmp.txt ${OUTPUT_DIR}/images.txt
sed -i '' -e '/index\.docker\.io\/chaosnative:/d' -e '/^$/d' ${OUTPUT_DIR}/images.txt
exit 0
