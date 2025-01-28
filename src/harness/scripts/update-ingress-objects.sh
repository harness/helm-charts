#!/bin/bash

read -p "Enter Namespace: " NAMESPACE
read -p "Enter Harness Upgrade version (eg: 0.22.0): " VERSION

# Extract major and minor version
MAJOR_MINOR_VERSION=$(echo $VERSION | awk -F. '{print $1"."$2}')

# Compare the extracted version
if [[ $(echo "$MAJOR_MINOR_VERSION >= 0.21" | bc) -eq 1 ]]; then
  read -p "Enter Helm Release Name (You can check release name by running 'helm ls -n $NAMESPACE'): " RELEASE_NAME
fi

# Perform actions based on the version
if [[ "$VERSION" == "0.24."* || "$VERSION" == "0.25."* ]]; then
  OLD_INGRESS_NAMES=("log-service" "pipeline-service-smp-v1-apis" "access-control" "ci-manager" "template-service" "ssca-manager" "ssca-manager-smp-v1-apis" "ng-ce-ui" "chaos-manager" "migrator-api" "next-gen-ui" "ng-dashboard-aggregator" "chaos-k8s-ifs" "verification-svc" "ssca-ui" "ng-auth-ui" "nextgen-ce" "service-discovery-manager" "${RELEASE_NAME}-gitops" "${RELEASE_NAME}-sto-manager" "cv-nextgen" "cv-nextgen-smp-v1-apis" "gateway" "${RELEASE_NAME}-policy-mgmt" "ng-custom-dashboards" "telescopes" "cloud-info" "debezium-service" "event-service-api" "queue-service" "srm-ui")
  NEW_INGRESS_NAMES=("log-service-0" "pipeline-service-v1-apis" "access-control-service" "ci-manager-0" "template-service-0" "ssca-manager-0" "ssca-manager-v1-apis" "ng-ce-ui-0" "chaos-manager-0" "migrator-0" "next-gen-ui-0" "ng-dashboard-aggregator-0" "chaos-k8s-ifs-0" "verification-svc-0" "ssca-ui-0" "ng-auth-ui-0" "nextgen-ce-0" "service-discovery-manager-0" "gitops-http" "sto-manager-0" "cv-nextgen-0" "cv-nextgen-1" "gateway-0" "policy-mgmt-0" "ng-custom-dashboards-0" "telescopes-0" "cloud-info-0" "debezium-service-0" "event-service-0" "queue-service-0" "srm-ui-ingress")

elif [[ "$VERSION" == "0.23."* ]]; then
  OLD_INGRESS_NAMES=("log-service" "pipeline-service-smp-v1-apis" "access-control" "ci-manager" "template-service" "ssca-manager" "ssca-manager-smp-v1-apis" "ng-ce-ui" "chaos-manager" "migrator-api" "next-gen-ui" "ng-dashboard-aggregator" "chaos-k8s-ifs" "verification-svc" "ssca-ui" "ng-auth-ui" "nextgen-ce" "service-discovery-manager" "${RELEASE_NAME}-gitops" "${RELEASE_NAME}-sto-manager" "cv-nextgen" "cv-nextgen-smp-v1-apis" "gateway" "${RELEASE_NAME}-policy-mgmt" "ng-custom-dashboards" "telescopes" "cloud-info" "debezium-service" "event-service-api" "queue-service")
  NEW_INGRESS_NAMES=("log-service-0" "pipeline-service-v1-apis" "access-control-service" "ci-manager-0" "template-service-0" "ssca-manager-0" "ssca-manager-v1-apis" "ng-ce-ui-0" "chaos-manager-0" "migrator-0" "next-gen-ui-0" "ng-dashboard-aggregator-0" "chaos-k8s-ifs-0" "verification-svc-0" "ssca-ui-0" "ng-auth-ui-0" "nextgen-ce-0" "service-discovery-manager-0" "gitops-http" "sto-manager-0" "cv-nextgen-0" "cv-nextgen-1" "gateway-0" "policy-mgmt-0" "ng-custom-dashboards-0" "telescopes-0" "cloud-info-0" "debezium-service-0" "event-service-0" "queue-service-0")

elif [[ "$VERSION" == "0.22."* ]]; then
  OLD_INGRESS_NAMES=("log-service" "pipeline-service-smp-v1-apis" "access-control" "ci-manager" "template-service" "ssca-manager" "ssca-manager-smp-v1-apis" "ng-ce-ui" "chaos-manager" "migrator-api" "next-gen-ui" "ng-dashboard-aggregator" "chaos-k8s-ifs" "verification-svc" "ssca-ui" "ng-auth-ui" "nextgen-ce" "service-discovery-manager" "${RELEASE_NAME}-gitops" "${RELEASE_NAME}-sto-manager" "cv-nextgen" "cv-nextgen-smp-v1-apis" "gateway" "${RELEASE_NAME}-policy-mgmt" "ng-custom-dashboards" "telescopes")
  NEW_INGRESS_NAMES=("log-service-0" "pipeline-service-v1-apis" "access-control-service" "ci-manager-0" "template-service-0" "ssca-manager-0" "ssca-manager-v1-apis" "ng-ce-ui-0" "chaos-manager-0" "migrator-0" "next-gen-ui-0" "ng-dashboard-aggregator-0" "chaos-k8s-ifs-0" "verification-svc-0" "ssca-ui-0" "ng-auth-ui-0" "nextgen-ce-0" "service-discovery-manager-0" "gitops-http" "sto-manager-0" "cv-nextgen-0" "cv-nextgen-1" "gateway-0" "policy-mgmt-0" "ng-custom-dashboards-0" "telescopes-0")

elif [[ "$VERSION" == "0.21."* ]]; then
  OLD_INGRESS_NAMES=("log-service" "pipeline-service-smp-v1-apis" "access-control" "ci-manager" "template-service" "ssca-manager" "ssca-manager-smp-v1-apis" "ng-ce-ui" "chaos-manager" "migrator-api" "next-gen-ui" "ng-dashboard-aggregator" "chaos-k8s-ifs" "verification-svc" "ssca-ui" "ng-auth-ui" "nextgen-ce" "service-discovery-manager" "${RELEASE_NAME}-gitops" "${RELEASE_NAME}-sto-manager")
  NEW_INGRESS_NAMES=("log-service-0" "pipeline-service-v1-apis" "access-control-service" "ci-manager-0" "template-service-0" "ssca-manager-0" "ssca-manager-v1-apis" "ng-ce-ui-0" "chaos-manager-0" "migrator-0" "next-gen-ui-0" "ng-dashboard-aggregator-0" "chaos-k8s-ifs-0" "verification-svc-0" "ssca-ui-0" "ng-auth-ui-0" "nextgen-ce-0" "service-discovery-manager-0" "gitops-http" "sto-manager-0")

elif [[ "$VERSION" == "0.20."* ]]; then
  OLD_INGRESS_NAMES=("log-service" "pipeline-service-smp-v1-apis" "access-control" "ci-manager" "template-service" "ssca-manager" "ssca-manager-smp-v1-apis")
  NEW_INGRESS_NAMES=("log-service-0" "pipeline-service-v1-apis" "access-control-service" "ci-manager-0" "template-service-0" "ssca-manager-0" "ssca-manager-v1-apis")

elif [[ "$VERSION" == "0.19."* ]]; then
  OLD_INGRESS_NAMES=("pipeline-service-smp-v1-apis" "access-control" "ci-manager" "template-service" "ssca-manager" "ssca-manager-smp-v1-apis")
  NEW_INGRESS_NAMES=("pipeline-service-v1-apis" "access-control-service" "ci-manager-0" "template-service-0" "ssca-manager-0" "ssca-manager-v1-apis")

elif [[ "$VERSION" == "0.18."* ]]; then
  OLD_INGRESS_NAMES=("pipeline-service-smp-v1-apis" "template-service" "ssca-manager" "ssca-manager-smp-v1-apis")
  NEW_INGRESS_NAMES=("pipeline-service-v1-apis" "template-service-0" "ssca-manager-0" "ssca-manager-v1-apis")

elif [[ "$VERSION" == "0.17."* ]]; then
  OLD_INGRESS_NAMES=("pipeline-service-smp-v1-apis" "template-service" "ssca-manager" "ssca-manager-smp-v1-apis")
  NEW_INGRESS_NAMES=("pipeline-service-v1-apis" "template-service-0" "ssca-manager-0" "ssca-manager-v1-apis")

else
  echo "Not required to run for version $VERSION"
  exit 1
fi

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
