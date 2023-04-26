#!/bin/sh
images="harness-airgapped-images.tgz"

usage () {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -r, --registry registry.com:5000  Specify the private registry url"
    echo "  -f, --image-bundle image_bundle Specify the tgz file which contains docker images"
    echo "  -h, --help             Show this help message"
    echo ""
}

while [ $# -gt 0 ]; do
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

if [ -z "$registry" ]; then
    echo "Registry is not specified."
    usage
    exit 1
fi

set -e

docker load --input "$images" | awk '/Loaded image:/ { print $3 }' | while read -r image_id; do
    image_name=$(docker inspect --format '{{index .RepoTags 0}}' "$image_id" | sed -E 's/(\[|\]|")//g')
    tagged_image="${registry}/${image_name}"
    if docker tag "$image_id" "$tagged_image" >/dev/null; then
        echo "Image tagging success: $tagged_image"
    else
        echo "Image tagging failed: $tagged_image"
    fi
    if docker push "$tagged_image" >/dev/null; then
        echo "Image push success: $tagged_image"
    else
        echo "Image push failed: $tagged_image"
    fi
done
