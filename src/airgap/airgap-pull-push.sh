#!/bin/sh

usage () {
    echo "Usage: $0 [options]"
    echo ""
    echo "Options:"
    echo "  -r, --registry registry.com:5000  Specify the private registry url"
    echo "  -f, --image-file images.txt       Specify the txt file which contains docker image names"
    echo "  -h, --help                        Show this help message"
    echo ""
}

while [ $# -gt 0 ]; do
    key="$1"
    case $key in
        -r|--registry)
            registry="$2"
            shift 2
            ;;
        -f|--image-file)
            imagefile="$2"
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

if [ -z "$imagefile" ]; then
    echo "Image file is not specified."
    usage
    exit 1
fi

if [ ! -f "$imagefile" ]; then
    echo "Specified image file does not exist: $imagefile"
    exit 1
fi

set -e

while read -r image_name; do
    if docker pull "$image_name" >/dev/null; then
        echo "Image pull success: $image_name"
        tagged_image="${registry}/${image_name}"
        if docker tag "$image_name" "$tagged_image" >/dev/null; then
            echo "Image tagging success: $tagged_image"
            if docker push "$tagged_image" >/dev/null; then
                echo "Image push success: $tagged_image"
            else
                echo "Image push failed: $tagged_image"
            fi
        else
            echo "Image tagging failed: $tagged_image"
        fi
    else
        echo "Image pull failed: $image_name"
    fi
done < "$imagefile"
