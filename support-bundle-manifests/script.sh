#!/bin/bash

# Check if all required arguments are provided
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <namespace> <release_name> <module>"
  exit 1
fi

# Assign arguments to variables
export NAMESPACE="$1"
export RELEASE_NAME="$2"
MODULE="${3:-all}"  # Use 'all' if module is not provided

BASE_URL="https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests"

case "$MODULE" in
  "all")
    DOWNLOAD_URL="$BASE_URL/support-bundle-all.yaml"
    ;;
  *)
    DOWNLOAD_URL="$BASE_URL/module-wise/support-bundle-$MODULE.yaml"
    ;;
esac


# Download file
curl -o support-bundle.yaml "$DOWNLOAD_URL"

yq -i '(.. | select(has("namespace")) | .namespace) = env(NAMESPACE)' support-bundle.yaml
yq -i '(.. | select(has("releaseName")) | .releaseName) = env(RELEASE_NAME)' support-bundle.yaml