#!/bin/bash

# Function to print usage information
usage() {
  echo "Usage: $0 <namespace>"
  exit 1
}

# Check if correct number of arguments is provided
if [ $# -ne 1 ]; then
  usage
fi

# Assign input argument to variable
NAMESPACE=$1

# Arrays for old and new Ingress names
OLD_INGRESS_NAMES=("log-service" "pipeline-service-smp-v1-apis" "access-control" "ci-manager" "template-service" "ssca-manager" "ssca-manager-smp-v1-apis")
NEW_INGRESS_NAMES=("log-service-0" "pipeline-service-v1-apis" "access-control-service" "ci-manager-0" "template-service-0" "ssca-manager-0" "ssca-manager-v1-apis")

# Loop through the arrays and process each Ingress
for i in "${!OLD_INGRESS_NAMES[@]}"; do
  OLD_INGRESS_NAME=${OLD_INGRESS_NAMES[$i]}
  NEW_INGRESS_NAME=${NEW_INGRESS_NAMES[$i]}

  # Check if the Ingress object exists in the specified namespace
  if kubectl get ingress "$OLD_INGRESS_NAME" -n "$NAMESPACE" > /dev/null 2>&1; then
    echo "Updating $OLD_INGRESS_NAME."

    # Download the Ingress manifest
    kubectl get ingress "$OLD_INGRESS_NAME" -n "$NAMESPACE" -o yaml > ingress-manifest.yaml

    # Update the name in the manifest
    yq -i ".metadata.name = \"$NEW_INGRESS_NAME\"" ingress-manifest.yaml

    # Delete the old Ingress object
    kubectl delete ingress "$OLD_INGRESS_NAME" -n "$NAMESPACE"

    # Apply the updated Ingress manifest
    kubectl apply -f ingress-manifest.yaml -n "$NAMESPACE"

    # Clean up
    rm ingress-manifest.yaml

    echo "Updated $OLD_INGRESS_NAME to $NEW_INGRESS_NAME."

  fi
done