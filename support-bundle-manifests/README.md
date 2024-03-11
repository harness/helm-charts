
# Support Bundle Manifests

These example manifests provide a one file solution to collect relevant data for the modules having issues. It contains a manifest file for each module which can be passed to the support bundle utility. For information on how to run the utility, [refer here](https://developer.harness.io/docs/self-managed-enterprise-edition/support-bundle-utility)

## Which support bundle to use?

- If you are not sure which module is having issues or have issues with multiple modules, you can use the `support-bundle-all.yaml` manifest which contains all the services. This should be the go to manifest for most of the cases.

- If you are having issues with a specific module, you can use the manifest for that module, which is present inside `module-wise` directory.

## How to use

### Pre-requisites

- yq (v4 or above) (For installation instructions, refer [here](https://github.com/mikefarah/yq?tab=readme-ov-file#install))

### Usage

After you have followed the installation instructions, run the following command to prepare the support bundle manifest. This script downloads the required manifest from the repository and prepares it for use. Change <your-namespace> with the namespace in which Harness is installed and <your-release-name> with the name of the helm release for Harness.

***Note: Please select the script based on your Operating System***

For Linux:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests/scripts/linux.sh) <your-namespace> <your-release-name>
```

For MacOS:

```bash
bash <(curl -sSL https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests/scripts/macos.sh) <your-namespace> <your-release-name>
```

For Windows:

***Pre-requisite***: powershell-yaml module is required. Install using `Install-Module -Name powershell-yaml` command

```powershell
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests/scripts/windows.ps1" -OutFile "windows.ps1"

./windows.ps1 <your-namespace> <your-release-name>
```


This will create a file named `support-bundle.yaml` in the current directory. You can use this file to collect the support bundle.

***Note: Please select the script based on your Operating System***

### Command Flags

#### Module-wise Manifest

If you want to download a module specific manifest, you can use the following command.

```bash
bash <(curl -sSL https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests/scripts/linux.sh) <your-namespace> <your-release-name> --module <module-name>
```

#### Time Since

You can provide time since for the logs to be collected.

```bash
bash <(curl -sSL https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests/scripts/linux.sh) <your-namespace> <your-release-name> --last 1 hours
```

Support values are

- x minutes
- x hours
- x days

#### Time Range

You can provide time range for the logs to be collected.

```bash
bash <(curl -sSL https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests/scripts/linux.sh) <your-namespace> <your-release-name> --between 2021-01-01 2021-01-02
```

Provide the start and end date in the format `YYYY-MM-DD`

#### Number of Files

You can provide the number of files to be collected for the logs. The default value is 2

```bash
bash <(curl -sSL https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests/scripts/linux.sh) <your-namespace> <your-release-name> --num-files 10
```

#### Filepath

If you are using a different filepath for the logs, you can provide the path using the following command

```bash
bash <(curl -sSL https://raw.githubusercontent.com/harness/helm-charts/main/support-bundle-manifests/scripts/linux.sh) <your-namespace> <your-release-name> --filepath /path/to/logs*.log
```

## Manifest Categories

The manifests are divided into categories based on modules and are present inside the `module-wise` directory. The following list provides what services are included in each manifest. Based on what module you are having issue with select the appropriate manifest

### Cloud Cost Management

#### Manifest Name: `support-bundle-ccm.yaml`

#### Services List (excluding platform services)

- nextgen-ce
- anomaly-detection
- batch-processing
- cloud-info
- event-service
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
