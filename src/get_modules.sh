#!/bin/bash

# Check if HELM_CHARTS_DIR is set
if [[ -z "$HELM_CHARTS_DIR" ]]; then
    echo "Error: HELM_CHARTS_DIR environment variable is not set"
    exit 1
fi

# Check if Chart.yaml exists
if [[ ! -f "$HELM_CHARTS_DIR/src/harness/Chart.yaml" ]]; then
    echo "Error: Chart.yaml not found at $HELM_CHARTS_DIR/src/harness/Chart.yaml"
    exit 1
fi

# Initialize empty arrays and flags
MODULES=()
MODULE_IMAGE_FILES=()
MODULE_IMAGE_ZIP_FILES=()
platform_added=false

while read -r value; do
    # Remove leading/trailing whitespace from value
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

# Get unique entries
get_unique() { echo "$@" | tr ' ' '\n' | /usr/bin/sort -u | tr '\n' ' '; }

# Get unique arrays
MODULES=($(get_unique "${MODULES[*]}"))
MODULE_IMAGE_FILES=($(get_unique "${MODULE_IMAGE_FILES[*]}"))
MODULE_IMAGE_ZIP_FILES=($(get_unique "${MODULE_IMAGE_ZIP_FILES[*]}"))

# Export the arrays (must source the script to access these)
export MODULES
export MODULE_IMAGE_FILES
export MODULE_IMAGE_ZIP_FILES

# Print the arrays (optional, for verification)
echo "Modules: ${MODULES[*]}"
echo "Image files: ${MODULE_IMAGE_FILES[*]}"
echo "Image zip files: ${MODULE_IMAGE_ZIP_FILES[*]}"
