
# Support Bundle Manifests

These example manifests provide a one file solution to collect relevant data for the modules having issues. It contains a manifest file for each module which can be passed to the support bundle utility. For information on how to run the utility, refer here[TODO]

## How to use

After you have followed the installation instructions, do the following steps to ready the support bundle manifest for use

#### Step 1:

- Replace `YOUR-RELEASE-NAMESPACE-HERE` with the namespace in which Harness is installed. Make this change at all places in the manifest.

#### Step 2

- Replace `YOUR-RELEASE-NAME-HERE` with the name of the helm release for Harness. Make this change at all places in the manifest.

Now you can provide this manifest to the support bundle utility to collect relevant data.

## Manifest Categories

The manifests are divided into categories based on modules. The following list provides what services are included in each manifest. Based on what module you are having issue with select the appropriate manifest

### Cloud Cost Management

#### Manifest Name: `support-bundle-ccm.yaml`

#### Services List (excluding platform services)

- nextgen-ce
- anomaly-detection
- batch-processing
- cloud-info
- dkron
- event-service
- lwd
- lwd-autocud
- lwd-faktory
- lwd-worker
- ng-ce-ui
- telescopes
- ng-ce-ui
- looker

### Continous Deployment

#### Manifest Name: `support-bundle-cd.yaml`

#### Services List (excluding platform services)

- gitops

### Continous Error Tracking

#### Manifest Name: `support-bundle-cet.yaml`

#### Services List (excluding platform services)

- et-service
- et-collector

### Chaos

#### Manifest Name: `support-bundle-chaos.yaml`

#### Services List (excluding platform services)

- chaos-web
- chaos-manager
- chaos-linux-ifs
- chaos-linux-ifc
- chaos-k8s-ifs

### Continous Integration

#### Manifest Name: `support-bundle-ci.yaml`

#### Services List (excluding platform services)

- ci-manager
- ti-service

### Feature Flags

#### Manifest Name: `support-bundle-ff.yaml`

#### Services List (excluding platform services)

- ff-service
- ff-pushpin-service

### Service Reliability Management

#### Manifest Name: `support-bundle-srm.yaml`

#### Services List (excluding platform services)

- cv-nextgen
- le-nextgen
- learning-engine
- srm-ui
- verification-svc

### SSCA

#### Manifest Name: `support-bundle-ssca.yaml`

#### Services List (excluding platform services)

- ssca-manager
- ssca-ui

### STO

#### Manifest Name: `support-bundle-sto.yaml`

#### Services List (excluding platform services)

- sto-manager
- sto-core

#### Note: All the charts contains the platform services as well (independent of the module)

### Platform

#### Manifest Name: `support-bundle-platform.yaml`

#### Services List

- access-control
- change-data-capture
- debezium-service
- gateway
- manager
- log-service
- migrator
- ng-custom-dashboards
- ng-dashboard-aggregator
- ng-manager
- pipeline-service
- platform-service
- policy-mgmt
- scm
- service-discovery-manager
- template-service
## What data is collected

The following data is collected through these manifests

### Configmaps

- The configmaps for all the services provided in the manifest is collected. The data collected is redacted for commonly used terms like `password`. Please validate if you have any values that needs to be redacted from the configmap.
- On how to find the collected configmap details, refer here (to manually redact data)
- On how to redact using redactors, refer here.

### Logs

- Logs all are collected for all the provided services

### Helm Release

- Harness helm release data and helm values are collected. If you have provided any plain-text credentials in the override file, please redact them.
- On how to find the collected helm release details, refer here (to manually redact data)
- On how to redact using redactors, refer here.
