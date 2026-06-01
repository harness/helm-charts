#!/bin/bash

if [[ -z "$HELM_CHARTS_DIR" ]]; then
    echo "Error: HELM_CHARTS_DIR environment variable is not set"
    exit 1
fi

if [[ ! -f "$HELM_CHARTS_DIR/src/harness/Chart.yaml" ]]; then
    echo "Error: Chart.yaml not found at $HELM_CHARTS_DIR/src/harness/Chart.yaml"
    exit 1
fi

MODULES=()
MODULE_IMAGE_FILES=()
MODULE_IMAGE_ZIP_FILES=()

while read -r value; do
    value=$(echo "$value" | xargs)
    module=""
    if [[ $value == "harness" || $value == "harness-common" ]]; then
        continue
    elif [[ $value == "chaos" ]]; then
        module="ce"
    elif [[ $value == "db-devops" ]]; then
        module="dbdevops"
    elif [[ $value == "cd" ]]; then
        module="cdng"
    elif [[ $value == "srm" ]]; then
        module="platform"
    else
        module="$value"
    fi

    if [[ -n "$module" ]]; then
        MODULES+=("$module")
        MODULE_IMAGE_FILES+=("${module}_images.txt")
        MODULE_IMAGE_ZIP_FILES+=("${module}_images.tgz")
    fi
done < <(grep "name:" "$HELM_CHARTS_DIR/src/harness/Chart.yaml" | awk -F 'name:' '{print $2}')

get_unique() { printf "%s\n" "$@" | /usr/bin/sort -ur | tr '\n' ' ' | sed 's/ $//'; }

export MODULES=$(get_unique "${MODULES[@]}")
export MODULE_IMAGE_FILES=$(get_unique "${MODULE_IMAGE_FILES[@]}")
export MODULE_IMAGE_ZIP_FILES=$(get_unique "${MODULE_IMAGE_ZIP_FILES[@]}")

echo "Modules: $MODULES"
echo "Image files: $MODULE_IMAGE_FILES"
echo "Image zip files: $MODULE_IMAGE_ZIP_FILES"

INTERNAL_FILE="$HELM_CHARTS_DIR/src/harness/images_internal.txt"
if [ -f "$INTERNAL_FILE" ]; then
    export BUNDLE_SECTIONS=$(grep '# @module=' "$INTERNAL_FILE" | sed 's/.*@module=\([^ ]*\).*/\1/' | tr '\n' ' ' | sed 's/ $//')
    if [ -n "$BUNDLE_SECTIONS" ]; then
        echo "Bundle sections: $BUNDLE_SECTIONS"
    fi
fi
