#!/bin/bash
images="harness-airgapped-images.tar.gz"
list="images.txt"

function usage {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -r, --registry registry.com:5000  Specify the private registry url"
    echo "  -f, --image-bundle image_bundle Specify the tar.gz file which contains docker images"
    echo "  -i, --file FILENAME    Specify the docker images txt file"
    echo "  -h, --help             Show this help message"
    echo ""
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -r|--registry)
            registry="$2"
            shift 2
            ;;
        -f|--image-bundle)
            images="$2"
            shift 2
            ;;
        -i|--image-list)
            list="$2"
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

if [[ -z $registry ]]; then
    echo "Input file not specified."
    usage
    exit 1
fi


set -e

docker load --input ${images}

while IFS= read -r i; do 
    [ -z "${i}" ] && continue
    echo "Tagging ${registry}/${i}"

    if docker tag "${i}" "${registry}/${i}"; then
    echo "Image tagging success: ${registry}/${i}"
    else
    echo "Image tagging failed: ${registry}/${i}"
    fi

    if docker push --quiet "${registry}/${i}"; then
    echo "Image push success: ${registry}/${i}"
    else
    echo "Image push failed: ${registry}/${i}"
    fi

done < "${list}"
