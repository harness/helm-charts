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

MANIFEST="$HELM_CHARTS_DIR/src/bundle-manifest.yaml"
if command -v python3 &>/dev/null && [ -f "$MANIFEST" ]; then
    export BUNDLE_SECTIONS=$(python3 -c "
import sys
try:
    import yaml
except ImportError:
    sys.exit(0)
with open('$MANIFEST') as f:
    m = yaml.safe_load(f)
sections = []
for name, mod in m.get('modules', {}).items():
    sections.append(name)
    for child_name in mod.get('children', {}):
        sections.append(f'{name}/{child_name}')
print(' '.join(sections))
" 2>/dev/null || true)
    if [ -n "$BUNDLE_SECTIONS" ]; then
        echo "Bundle sections: $BUNDLE_SECTIONS"
    fi
fi
