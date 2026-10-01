## Harness Helm Charts

This readme provides the basic instructions to deploy Harness using a Helm chart. The Helm chart deploys Harness in a production configuration.

Helm Chart for deploying Harness.

![Version: 0.47.0](https://img.shields.io/badge/Version-0.47.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.80917](https://img.shields.io/badge/AppVersion-1.0.80917-informational?style=flat-square)

For full release notes, go to [Self-Managed Enterprise Edition release notes](https://developer.harness.io/release-notes/self-managed-enterprise-edition).

## Usage

Harness Helm charts require the installation of [Helm](https://helm.sh). To download and get started with Helm, go to the [Helm documentation](https://helm.sh/docs/).

Use the following command to add the Harness chart repository to your Helm installation:

```console
$ helm repo add harness https://harness.github.io/helm-charts
```
## Requirements
* [Istio](https://isio/io). This Helm chart includes Istio service mesh as an optional dependency and requires its installation. For information about how to download and install Istio into your Kubernetes clusters, go to [Getting Started](https://istio.io/latest/docs/setup/getting-started/) in the Istio documentation.

## Install the chart
Use the following process to install the Helm chart.
1. Create a namespace for your installation.
```
$ kubectl create namespace <namespace>
```

2. Create the override.yaml file using your environment settings:

Install the Helm chart:
```
$  helm install my-release harness/harness-prod -n <namespace> -f override.yaml
```

### Access the application
Verify your installation by accessing the Harness application and creating your Harness account. For basic instructions, go to [Install using Helm](https://developer.harness.io/docs/self-managed-enterprise-edition/self-managed-helm-based-install/install-harness-self-managed-enterprise-edition-using-helm-ga/).

## Upgrade the chart
Use the following instructions to upgrade Harness Helm chart to a later version.

1. Obtain the `release-name` that identifies the installed release:
```
$ helm ls -n <namespace>
```
2. Retrieve configuration information for the installed release from the old-values.yaml file:
```
$ helm get values my-release > old_values.yaml
```
3. Modify the values of the old_values.yaml file as your configuration requires.

4. Use the `helm upgrade` command to update the chart:

Helm Upgrade

Use the `helm upgrade` command to update the chart for your `override-demo.yaml` file or `override-prod.yaml` file.

```
$ helm upgrade my-release harness/harness -n <namespace> -f override-demo.yaml -f old_values.yaml
```

```
$ helm upgrade my-release harness/harness -n <namespace> -f override-prod.yaml -f old_values.yaml
```

## Uninstall the chart

The following process uninstalls the Helm chart and removes your Harness deployment.

Uninstall and delete the `my-release` deployment:

```console
$ helm uninstall my-release -n <namespace>
```

This command removes the Kubernetes components that are associated with the chart and deletes the release.

## Images for disconnected networks

If your cluster is in an air-gapped environment, your deployment requires the following images:

```
## Core Platform Services (Required for all installations)
docker.io/envoyproxy/gateway:v1.8.0
docker.io/envoyproxy/ratelimit:ff287602
docker.io/envoyproxy/envoy:distroless-v1.38.0
docker.io/harnesssecure/deploy-crds-job:1.12.0
docker.io/busybox:1.37.0
registry.access.redhat.com/ubi8/ubi-minimal:8.9-1029
docker.io/harnesssecure/ci-scm-signed:1.66.1
docker.io/harnesssecure/template-service-signed:1.168.0
docker.io/harnesssecure/platform-service-signed:1.149.1
docker.io/harnesssecure/pipeline-service-signed:1.206.4
docker.io/harnesssecure/ng-manager-signed:1.167.5
docker.io/harnesssecure/nextgenui-signed:1.154.1
docker.io/harnesssecure/minio:RELEASE.2025-10-15T17-29-55Z-jammy
docker.io/harnesssecure/log-service-signed:1.52.3
docker.io/harnesssecure/cdcdata-signed:1.66.0
docker.io/harnesssecure/accesscontrol-service-signed:1.342.0
docker.io/harnesssecure/delegate-proxy-signed:1.9.0
docker.io/harnesssecure/gateway-signed:1.72.2
docker.io/harnesssecure/helm-init-container:1.9.0
docker.io/harnesssecure/harness-db-migrator-signed:2.66.0
docker.io/harnesssecure/manager-signed:1.166.8
docker.io/harnesssecure/mongo:8.0.26-jammy
docker.io/harnesssecure/ng-auth-ui-signed:1.39.0
docker.io/harnesssecure/redis:7.4.9-jammy
docker.io/bitnamilegacy/postgresql:14.11.0-debian-11-r17
docker.io/harnesssecure/postgresql:14.20-debian
docker.io/harnesssecure/postgresql:16.14-bookworm
docker.io/harnesssecure/policy-mgmt:1.68.0
docker.io/harnesssecure/smp-service-discovery-server-signed:0.82.0
docker.io/harnesssecure/debezium-service-signed:1.28.0
docker.io/harnesssecure/audit-event-streaming-signed:1.114.0
docker.io/harnesssecure/queue-service-signed:1.16.0
docker.io/harnesssecure/service-discovery-collector:0.82.0
docker.io/harnesssecure/ng-dashboard-aggregator-signed:1.133.0
docker.io/harnesssecure/redis_exporter:1.83.0-jammy
docker.io/prometheuscommunity/postgres-exporter:v0.20.1
docker.io/harnesssecure/mongodb-exporter:0.51.0-jammy
harnesssecure/vault-secret-loader:1.0.10
docker.io/harnesssecure/ui-signed:1.36.3
docker.io/harnesssecure/pg-upgrader:14-to-16
docker.io/harnesssecure/delegate:26.08.89806.minimal
docker.io/harnesssecure/delegate:26.08.89806.minimal-fips

### Platform Agents
docker.io/harnesssecure/delegate:26.08.89806
docker.io/harnesssecure/delegate:26.08.89806.minimal
docker.io/harnesssecure/delegate:26.08.89806.minimal-fips
docker.io/harnesssecure/delegate:26.08.89806-fips
docker.io/harnesssecure/upgrader:1.12.0
docker.io/harnesssecure/upgrader:1.12.0-fips

### Dashboard
docker.io/harnesssecure/looker-signed:1.28.5
docker.io/harnesssecure/dashboard-service-signed:1.130.0
docker.io/harnesssecure/statsd-exporter:5.0-prometheus-busybox-2

## Continuous Deployment
docker.io/harnesssecure/gitops-service-signed:1.66.5
docker.io/harnesssecure/cv-nextgen-signed:1.74.0
docker.io/harnesssecure/le-nextgen-signed:1.23.1
docker.io/harnesssecure/srm-ui-signed:1.16.2

### CD Deployment Plugins
harnesssecure/drone-git:1.4.1-rootless
harnesssecure/drone-git:1.7.16-rootless
harnesssecure/drone-git:1.7.25-rootless
harnesssecure/download-aws-s3:1.3.0-rootless-linux
harnesssecure/download-google-cloud-storage:0.0.4-linux-amd64
harnesssecure/download-harness-store:1.0.0-rootless-linux
harnesssecure/aws-sam-plugin:nodejs20.x-1.162.1-1.4.0-beta-linux-amd64

### CD Agents
docker.io/harnesssecure/argocd:v3.5.1
docker.io/harnesssecure/gitops-agent:v0.126.1
docker.io/harnesssecure/haproxy:3.4.1-alpine3.24
docker.io/harnesssecure/shellcheck:v0.11.0
docker.io/harnesssecure/gitops-agent-installer-helper:v0.2.0

## Continuous Integration
docker.io/harnesssecure/ci-manager-signed:1.157.1
docker.io/harnesssecure/ti-service-signed:1.79.5
harnesssecure/ci-addon:1.18.30
harnesssecure/ci-addon:1.18.34
harnesssecure/ci-addon:rootless-1.18.30
harnesssecure/ci-addon:rootless-1.18.34
harnesssecure/ci-lite-engine:1.18.30
harnesssecure/ci-lite-engine:1.18.34
harnesssecure/ci-lite-engine:rootless-1.18.30
harnesssecure/ci-lite-engine:rootless-1.18.34

### CI Build Plugins
harnesssecure/drone-git:1.4.1-rootless
harnesssecure/drone-git:1.7.16-rootless
harnesssecure/drone-git:1.7.25-rootless
harnesssecure/harness-cache-server:1.7.29
harnesssecure/kaniko:1.13.10
harnesssecure/kaniko-acr:1.13.10
harnesssecure/kaniko-ecr:1.13.10
harnesssecure/kaniko-gcr:1.13.10
harnesssecure/artifactory:1.9.3
harnesssecure/gcs:1.6.12
harnesssecure/cache:1.10.12
harnesssecure/s3:1.8.2
harnesssecure/buildx:1.3.26
harnesssecure/buildx-acr:1.5.7
harnesssecure/buildx-ecr:1.5.7
harnesssecure/buildx-gar:1.5.7
harnesssecure/buildx-gcr:1.5.5
harnesssecure/docker:21.3.3
harnesssecure/ecr:21.3.3
harnesssecure/gar:21.3.3
harnesssecure/gcr:21.3.3
harnesssecure/acr:21.3.3
harnesssecure/har-plugin:1.0.0
harnesssecure/har-plugin:1.0.6

## Security Testing Orchestration
docker.io/harnesssecure/stocore-signed:1.210.3
docker.io/harnesssecure/ticket-service-signed:1.16.0
docker.io/harnesssecure/refid-cache:latest
harnesssecure/refid-cache:latest
harnesssecure/sto-plugin:latest
harnesssecure/sto-plugin:latest-fips

### STO Security Scanners
harnesssecure/anchore-job-runner:latest
harnesssecure/aqua-security-job-runner:latest
harnesssecure/aqua-trivy-job-runner:latest
harnesssecure/aqua-trivy-job-runner:latest-fips
harnesssecure/aws-ecr-job-runner:latest
harnesssecure/aws-security-hub-job-runner:latest
harnesssecure/bandit-job-runner:latest
harnesssecure/bandit-job-runner:latest-fips
harnesssecure/blackduckhub-job-runner:latest
harnesssecure/brakeman-job-runner:latest
harnesssecure/burp-job-runner:latest
harnesssecure/checkmarx-job-runner:latest
harnesssecure/checkov-job-runner:latest
harnesssecure/fossa-job-runner:latest
harnesssecure/github-advanced-security-job-runner:latest
harnesssecure/gitleaks-job-runner:latest
harnesssecure/grype-job-runner:latest
harnesssecure/grype-job-runner:latest-fips
harnesssecure/modelscan-job-runner:latest
harnesssecure/nexusiq-job-runner:latest
harnesssecure/nexusiq-job-runner:latest-fips
harnesssecure/nikto-job-runner:latest
harnesssecure/nmap-job-runner:latest
harnesssecure/osv-job-runner:latest
harnesssecure/osv-job-runner:latest-fips
harnesssecure/owasp-dependency-check-job-runner:latest
harnesssecure/prowler-job-runner:latest
harnesssecure/semgrep-job-runner:latest
harnesssecure/semgrep-job-runner:latest-fips
harnesssecure/shiftleft-job-runner:latest
harnesssecure/snyk-job-runner:latest
harnesssecure/sonarqube-agent-job-runner:latest
harnesssecure/sonarqube-agent-job-runner:latest-fips
harnesssecure/sysdig-job-runner:latest
harnesssecure/traceable-job-runner:latest
harnesssecure/twistlock-job-runner:latest
harnesssecure/twistlock-job-runner:latest-fips
harnesssecure/veracode-agent-job-runner:latest
harnesssecure/whitesource-agent-job-runner:latest
harnesssecure/wiz-job-runner:latest
harnesssecure/zap-job-runner:latest

## Feature Flags
docker.io/harnesssecure/ff-cron-signed:1.1237.0
docker.io/harnesssecure/ff-server-analytics-db-migration-signed:1.1237.0
docker.io/harnesssecure/ff-server-primary-db-migration-signed:1.1237.0
docker.io/harnesssecure/ff-service-signed:1.1237.0
docker.io/harnesssecure/ff-pushpin-signed:1.1148.0
docker.io/harnesssecure/ff-pushpin-worker-signed:1.1148.0

## Cloud Cost Management
docker.io/harnesssecure/batch-processing-signed:1.102.9
docker.io/harnesssecure/ce-anomaly-detection-signed:1.33.0
docker.io/harnesssecure/ce-cloud-info-signed:1.19.0
docker.io/harnesssecure/ce-nextgen-signed:1.104.8
docker.io/harnesssecure/event-service-signed:1.21.0
docker.io/harnesssecure/ng-ce-ui:1.99.3
docker.io/harnesssecure/telescopes-signed:1.10.0
docker.io/harnesssecure/clickhouse:25.12.5-jammy
docker.io/harnesssecure/ccm-gcp-smp-signed:1000103

## Chaos Engineering
docker.io/harnesssecure/smp-chaos-k8s-ifs-signed:1.101.1
docker.io/harnesssecure/smp-chaos-linux-infra-controller-signed:1.101.0
docker.io/harnesssecure/smp-chaos-linux-infra-server-signed:1.101.0
docker.io/harnesssecure/smp-chaos-manager-signed:1.101.6
docker.io/harnesssecure/smp-chaos-web-signed:1.101.3
docker.io/harnesssecure/source-probe:main-latest
docker.io/harnesssecure/smp-chaos-bg-processor-signed:1.101.6
docker.io/harnesssecure/chaos-machine-ifc-signed:1.101.0
docker.io/harnesssecure/chaos-machine-ifs-signed:1.101.0
docker.io/harnesssecure/enterprise-chaos-hub-signed:1.101.6
docker.io/harnesssecure/load-test-manager-signed:1.24.3
docker.io/harnesssecure/rt-agent-signed:1.6.1

### Chaos Engineering Plugins
docker.io/harnesssecure/chaos-log-watcher:1.101.0
docker.io/harnesssecure/chaos-ddcr:1.101.1
docker.io/harnesssecure/chaos-ddcr-faults:1.101.0
docker.io/harnesssecure/chaos-event-watcher:1.101.0
docker.io/harnesssecure/load-test-runner:0.4.0

## Supply Chain Security
docker.io/harnesssecure/ssca-manager-signed:1.72.7
docker.io/harnesssecure/ssca-ui-signed:0.58.2
docker.io/harnesssecure/component-service-signed:1.21.2
docker.io/harnesssecure/component-analysis-service-signed:1.19.2

### SCS Plugins
harnesssecure/ssca-plugin:0.67.0
harnesssecure/slsa-plugin:0.67.0
harnesssecure/ssca-cdxgen-plugin:0.67.0
harnesssecure/ssca-compliance-plugin:0.67.0
harnesssecure/ssca-artifact-signing-plugin:0.67.0
harnesssecure/ssca-ai-bom-plugin:0.67.0

## Database DevOps
docker.io/harnesssecure/db-devops-service-signed:1.115.1

## Code Repository
docker.io/harnesssecure/code-api-signed:1.103.3
docker.io/harnesssecure/code-githa-signed:1.103.0
docker.io/harnesssecure/code-gitrpc-signed:1.103.0
docker.io/harnesssecure/code-search-signed:1.103.0
docker.io/harnesssecure/code-ui-signed:1.55.0

## Infrastructure as Code Management
docker.io/harnesssecure/iac-server-signed:1.494.0
docker.io/harnesssecure/iacm-manager-signed:1.202.0

### IACM Plugins
harnesssecure/ci-addon:1.18.30
harnesssecure/ci-addon:1.18.34
harnesssecure/ci-addon:rootless-1.18.30
harnesssecure/ci-addon:rootless-1.18.34
harnesssecure/ci-lite-engine:1.18.30
harnesssecure/ci-lite-engine:1.18.34
harnesssecure/ci-lite-engine:rootless-1.18.30
harnesssecure/ci-lite-engine:rootless-1.18.34
harnesssecure/drone-git:1.4.1-rootless
harnesssecure/drone-git:1.7.16-rootless
harnesssecure/drone-git:1.7.25-rootless
harnesssecure/harness_terraform:latest
harnesssecure/harness_terraform_vm:latest

## Unified Data Platform (UDP) Services
docker.io/harnesssecure/config-service-signed:0.1.166
docker.io/harnesssecure/schema-service-signed:0.23.0
docker.io/harnesssecure/onboarding-service-signed:0.12.11
docker.io/harnesssecure/query-service-signed:0.65.0
docker.io/harnesssecure/dashboard-ui-signed:1.80.0

## Data Infrastructure
docker.io/harnesssecure/kafka-operator-signed:1.15.4
docker.io/harnesssecure/kafka-operator-crd-updater-signed:1.15.4
docker.io/harnesssecure/strimzi-kafka-signed:1.15.1-kafka-4.2.0
docker.io/harnesssecure/strimzi-kafka-signed:1.15.4-kafka-4.1.1
docker.io/harnesssecure/strimzi-kafka-signed:1.15.4-kafka-4.2.0
docker.io/harnesssecure/strimzi-kafka-connect-signed:1.15.4-kafka-4.1.1
docker.io/harnesssecure/strimzi-kafka-connect-signed:1.15.4-kafka-4.2.0
docker.io/harnesssecure/schema-registry-signed:1.12.2
docker.io/harnesssecure/schema-compatibility-signed:1.12.2
docker.io/harnesssecure/schema-registry-prometheus-jmx-exporter-signed:1.12.2
docker.io/harnesssecure/schema-registry-backup-signed:1.12.2

## Artifact Registry
docker.io/harnesssecure/registry-api-signed:1.99.2
docker.io/harnesssecure/registry-async-service-signed:1.56.2
docker.io/harnesssecure/registry-processor-signed:1.71.1
docker.io/harnesssecure/ipqs-service-signed:1.9.0
docker.io/harnesssecure/ip-data-bundle-ipqs-signed:0.1.41-ipqs.78

```
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ar.ipqs-service.affinity | object | `{}` |  |
| ar.ipqs-service.autoscaling.enabled | bool | `false` |  |
| ar.ipqs-service.nodeSelector | object | `{}` |  |
| ar.ipqs-service.tolerations | list | `[]` |  |
| ar.registry-api.affinity | object | `{}` |  |
| ar.registry-api.autoscaling.enabled | bool | `false` |  |
| ar.registry-api.config.HARNESS_REGISTRY_EVENTS_ARTIFACT_QUARANTINE_STREAM | string | `"ssca_ar_artifact_quarantine"` |  |
| ar.registry-api.config.HARNESS_REGISTRY_EVENTS_ENABLED | string | `"true"` |  |
| ar.registry-api.config.REGISTRY_ENABLE_ES | string | `"false"` |  |
| ar.registry-api.ingress.objects[0].annotations."nginx.ingress.kubernetes.io/configuration-snippet" | string | `"set $do_redirect \"\";\nif ($host = \"{{ index .Values.global.ingress.hosts 0 }}\") { set $do_redirect \"${do_redirect}H\"; }\nif ($request_uri ~ \"^/har/api/\") { set $do_redirect \"${do_redirect}U\"; }\nif ($do_redirect = \"HU\") { return 308 {{ .Values.global.loadbalancerURL }}/gateway$request_uri; }\n"` |  |
| ar.registry-api.ingress.objects[0].annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"$1$2"` |  |
| ar.registry-api.ingress.objects[0].annotations."nginx.ingress.kubernetes.io/upstream-vhost" | string | `"registry-api"` |  |
| ar.registry-api.ingress.objects[0].annotations."nginx.ingress.kubernetes.io/use-regex" | string | `"true"` |  |
| ar.registry-api.ingress.objects[0].paths[0].path | string | `"{{ .Values.global.ingress.pathPrefix }}/har(/|$)(.*)"` |  |
| ar.registry-api.ingress.objects[1].annotations."nginx.ingress.kubernetes.io/proxy-body-size" | string | `"0"` |  |
| ar.registry-api.ingress.objects[1].annotations."nginx.ingress.kubernetes.io/proxy-read-timeout" | string | `"900"` |  |
| ar.registry-api.ingress.objects[1].annotations."nginx.ingress.kubernetes.io/proxy-send-timeout" | string | `"900"` |  |
| ar.registry-api.ingress.objects[1].annotations."nginx.ingress.kubernetes.io/use-regex" | string | `"true"` |  |
| ar.registry-api.ingress.objects[1].paths[0].path | string | `"/v2(/|$).*"` |  |
| ar.registry-api.ingress.objects[1].paths[1].path | string | `"/pkg(/|$).*"` |  |
| ar.registry-api.ingress.objects[1].paths[2].path | string | `"/generic(/|$).*"` |  |
| ar.registry-api.ingress.objects[1].paths[3].path | string | `"/maven(/|$).*"` |  |
| ar.registry-api.initializeDatabase.enabled | bool | `true` |  |
| ar.registry-api.multiStorage.enabled | bool | `true` |  |
| ar.registry-api.nodeSelector | object | `{}` |  |
| ar.registry-api.tolerations | list | `[]` |  |
| ar.registry-async-service.affinity | object | `{}` |  |
| ar.registry-async-service.autoscaling.enabled | bool | `false` |  |
| ar.registry-async-service.config.KAFKA_CONFLUENT_BOOTSTRAP_SERVER_URLS | string | `"kafka-platform-kafka-bootstrap:9093"` |  |
| ar.registry-async-service.config.KAFKA_CONFLUENT_SECURITY_PROTOCOL | string | `"SSL"` |  |
| ar.registry-async-service.config.KAFKA_CONFLUENT_SSL_ENDPOINT_IDENTIFICATION_ALGORITHM | string | `"https"` |  |
| ar.registry-async-service.config.KAFKA_PRODUCER_TLS_CA_FILE | string | `"/etc/kafka/cluster-ca/ca.crt"` |  |
| ar.registry-async-service.config.KAFKA_PRODUCER_TLS_CERT_FILE | string | `"/etc/kafka/certs/user.crt"` |  |
| ar.registry-async-service.config.KAFKA_PRODUCER_TLS_KEY_FILE | string | `"/etc/kafka/certs/user.key"` |  |
| ar.registry-async-service.config.REGISTRY_ENABLE_ES | string | `"false"` |  |
| ar.registry-async-service.extraVolumeMounts[0].mountPath | string | `"/etc/kafka/certs"` |  |
| ar.registry-async-service.extraVolumeMounts[0].name | string | `"kafka-certs"` |  |
| ar.registry-async-service.extraVolumeMounts[0].readOnly | bool | `true` |  |
| ar.registry-async-service.extraVolumeMounts[1].mountPath | string | `"/etc/kafka/cluster-ca"` |  |
| ar.registry-async-service.extraVolumeMounts[1].name | string | `"kafka-cluster-ca"` |  |
| ar.registry-async-service.extraVolumeMounts[1].readOnly | bool | `true` |  |
| ar.registry-async-service.extraVolumes[0].name | string | `"kafka-certs"` |  |
| ar.registry-async-service.extraVolumes[0].secret.defaultMode | int | `292` |  |
| ar.registry-async-service.extraVolumes[0].secret.secretName | string | `"kafka-platform-registry-async-service"` |  |
| ar.registry-async-service.extraVolumes[1].name | string | `"kafka-cluster-ca"` |  |
| ar.registry-async-service.extraVolumes[1].secret.defaultMode | int | `292` |  |
| ar.registry-async-service.extraVolumes[1].secret.secretName | string | `"kafka-platform-cluster-ca-cert"` |  |
| ar.registry-async-service.initializeDatabase.enabled | bool | `true` |  |
| ar.registry-async-service.multiStorage.enabled | bool | `true` |  |
| ar.registry-async-service.nodeSelector | object | `{}` |  |
| ar.registry-async-service.tolerations | list | `[]` |  |
| ar.registry-processor.affinity | object | `{}` |  |
| ar.registry-processor.autoscaling.enabled | bool | `false` |  |
| ar.registry-processor.config.GITNESS_REGISTRY_POST_PROCESSING_CONCURRENCY | string | `"10"` |  |
| ar.registry-processor.config.HARNESS_SERVICES_COMPONENT_SERVICE_IGNORE | string | `"true"` |  |
| ar.registry-processor.ingress.objects[0].annotations."nginx.ingress.kubernetes.io/rewrite-target" | string | `"$1$2"` |  |
| ar.registry-processor.ingress.objects[0].annotations."nginx.ingress.kubernetes.io/use-regex" | string | `"true"` |  |
| ar.registry-processor.ingress.objects[0].paths[0].path | string | `"{{ .Values.global.ingress.pathPrefix }}/har-processor(/|$)(.*)"` |  |
| ar.registry-processor.initializeDatabase.enabled | bool | `true` |  |
| ar.registry-processor.multiStorage.enabled | bool | `true` |  |
| ar.registry-processor.nodeSelector | object | `{}` |  |
| ar.registry-processor.tolerations | list | `[]` |  |
| ccm.batch-processing | object | `{"awsAccountTagsCollectionJobConfig":{"enabled":true},"cliProxy":{"enabled":false,"host":"localhost","password":"","port":80,"protocol":"http","username":""},"cloudProviderConfig":{"CLUSTER_DATA_GCS_BACKUP_BUCKET":"placeHolder","CLUSTER_DATA_GCS_BUCKET":"placeHolder","DATA_PIPELINE_CONFIG_GCS_BASE_PATH":"placeHolder","GCP_PROJECT_ID":"placeHolder","S3_SYNC_CONFIG_BUCKET_NAME":"placeHolder","S3_SYNC_CONFIG_REGION":"placeHolder"},"postgres":{"image":{"repository":"harnesssecure/postgresql","tag":"14.20-debian"}},"stackDriverLoggingEnabled":false}` | Set ccm.batch-processing.clickhouse.enabled to true for AWS infrastructure |
| ccm.batch-processing.awsAccountTagsCollectionJobConfig | object | `{"enabled":true}` | Set ccm.batch-processing.awsAccountTagsCollectionJobConfig.enabled to false for AWS infrastructure |
| ccm.batch-processing.cliProxy | object | `{"enabled":false,"host":"localhost","password":"","port":80,"protocol":"http","username":""}` | Set ccm.batch-processing.cliProxy.protocol to http or https depending on the proxy configuration |
| ccm.batch-processing.stackDriverLoggingEnabled | bool | `false` | Set ccm.batch-processing.stackDriverLoggingEnabled to true for GCP infrastructure |
| ccm.ce-nextgen.cloudProviderConfig.GCP_PROJECT_ID | string | `"placeHolder"` |  |
| ccm.ce-nextgen.stackDriverLoggingEnabled | bool | `false` | Set ccm.nextgen-ce.stackDriverLoggingEnabled to true for GCP infrastructure |
| ccm.cloud-info.proxy | object | `{"httpsProxyEnabled":false,"httpsProxyUrl":"http://localhost"}` | Set ccm.cloud-info.proxy.httpsProxyUrl to proxy url(ex: http://localhost:8080, if http proxy is running on localhost port 8080) |
| ccm.event-service | object | `{"stackDriverLoggingEnabled":false}` | Set ccm.event-service.stackDriverLoggingEnabled to true for GCP infrastructure |
| cd.gitops.agentRedisImage.image.repository | string | `"harnesssecure/redis"` |  |
| cd.gitops.agentRedisImage.image.tag | string | `"7.4.9-jammy"` |  |
| chaos.chaos-common.installLinuxCRDs | bool | `false` |  |
| chaos.chaos-k8s-ifs.nodeSelector | object | `{}` |  |
| chaos.chaos-k8s-ifs.tolerations | list | `[]` |  |
| chaos.chaos-linux-ifc.nodeSelector | object | `{}` |  |
| chaos.chaos-linux-ifc.tolerations | list | `[]` |  |
| chaos.chaos-linux-ifs.nodeSelector | object | `{}` |  |
| chaos.chaos-linux-ifs.tolerations | list | `[]` |  |
| chaos.chaos-machine-ifc.nodeSelector | object | `{}` |  |
| chaos.chaos-machine-ifc.tolerations | list | `[]` |  |
| chaos.chaos-machine-ifs.nodeSelector | object | `{}` |  |
| chaos.chaos-machine-ifs.tolerations | list | `[]` |  |
| chaos.chaos-manager.nodeSelector | object | `{}` |  |
| chaos.chaos-manager.tolerations | list | `[]` |  |
| chaos.chaos-web.nodeSelector | object | `{}` |  |
| chaos.chaos-web.tolerations | list | `[]` |  |
| chaos.load-test-manager.nodeSelector | object | `{}` |  |
| chaos.load-test-manager.tolerations | list | `[]` |  |
| chaos.rt-agent.nodeSelector | object | `{}` |  |
| chaos.rt-agent.tolerations | list | `[]` |  |
| ci | object | `{"ci-manager":{"affinity":{},"config":{"ENV":"SMP","HARNESS_IMAGE_REPOSITORY":"harnesssecure","REFID_CACHE_IMAGE":"harnesssecure/refid-cache:latest"},"nodeSelector":{},"tolerations":[]},"ti-service":{"affinity":{},"config":{"ENV":"SMP"},"ingress":{"objects":[{"annotations":{"nginx.ingress.kubernetes.io/proxy-read-timeout":"1800","nginx.ingress.kubernetes.io/rewrite-target":"/$2"},"name":"ti-service","paths":[{"path":"{{ .Values.global.ingress.pathPrefix }}/ti-service(/|$)(.*)"}]}]},"nodeSelector":{},"tolerations":[]}}` | Install the Continuous Integration (CI) manager pod |
| code.code-api.autoai.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code.code-api.autoai.postgres.image.tag | string | `"14.20-debian"` |  |
| code.code-api.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code.code-api.postgres.image.tag | string | `"14.20-debian"` |  |
| code.code-githa.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code.code-githa.postgres.image.tag | string | `"14.20-debian"` |  |
| code.code-gitrpc.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code.code-gitrpc.postgres.image.tag | string | `"14.20-debian"` |  |
| code.code-search.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code.code-search.postgres.image.tag | string | `"14.20-debian"` |  |
| code.code-ui.affinity | object | `{}` |  |
| code.code-ui.autoscaling.enabled | bool | `false` |  |
| code.code-ui.nodeSelector | object | `{}` |  |
| code.code-ui.tolerations | list | `[]` |  |
| data-infra.kafka-connect-strimzi.connectorConfigEnv.MONGO_COMPONENT_DB_NAME | string | `"component-harness"` |  |
| data-infra.kafka-connect-strimzi.connectorConfigEnv.MONGO_SSCA_NG_HARNESS_DB_NAME | string | `"harness-cdng"` |  |
| data-infra.kafka-connect-strimzi.connectors.debezium-mongo-component-cdc.enabled | bool | `true` |  |
| data-infra.kafka-connect-strimzi.connectors.debezium-mongo-instance-ng-cdc.enabled | bool | `true` |  |
| data-infra.kafka-connect-strimzi.connectors.postgres-registry-async-service.enabled | bool | `true` |  |
| data-infra.kafka-connect-strimzi.database.mongo.componentharness.database | string | `"component-harness"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.componentharness.enabled | bool | `true` |  |
| data-infra.kafka-connect-strimzi.database.mongo.componentharness.extraArgs | string | `"replicaSet=rs0&authSource=admin"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.componentharness.hosts[0] | string | `"mongodb-replicaset-chart-0.mongodb-replicaset-chart:27017"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.componentharness.protocol | string | `"mongodb"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.componentharness.secrets.kubernetesSecrets[0].keys.MONGO_USER | string | `"mongodbUsername"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.componentharness.secrets.kubernetesSecrets[0].secretName | string | `"harness-secrets"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.componentharness.secrets.kubernetesSecrets[1].keys.MONGO_PASSWORD | string | `"mongodb-root-password"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.componentharness.secrets.kubernetesSecrets[1].secretName | string | `"mongodb-replicaset-chart"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.sscangharness.database | string | `"harness-cdng"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.sscangharness.enabled | bool | `true` |  |
| data-infra.kafka-connect-strimzi.database.mongo.sscangharness.extraArgs | string | `"replicaSet=rs0&authSource=admin"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.sscangharness.hosts[0] | string | `"mongodb-replicaset-chart-0.mongodb-replicaset-chart:27017"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.sscangharness.protocol | string | `"mongodb"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.sscangharness.secrets.kubernetesSecrets[0].keys.MONGO_USER | string | `"mongodbUsername"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.sscangharness.secrets.kubernetesSecrets[0].secretName | string | `"harness-secrets"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.sscangharness.secrets.kubernetesSecrets[1].keys.MONGO_PASSWORD | string | `"mongodb-root-password"` |  |
| data-infra.kafka-connect-strimzi.database.mongo.sscangharness.secrets.kubernetesSecrets[1].secretName | string | `"mongodb-replicaset-chart"` |  |
| data-infra.kafka-connect-strimzi.database.postgres.registry.database | string | `"registry_db"` |  |
| data-infra.kafka-connect-strimzi.database.postgres.registry.enabled | bool | `true` |  |
| data-infra.kafka-connect-strimzi.database.postgres.registry.hosts[0] | string | `"postgres"` |  |
| data-infra.kafka-connect-strimzi.database.postgres.registry.secrets.kubernetesSecrets[0].keys.POSTGRES_PASSWORD | string | `"postgres-password"` |  |
| data-infra.kafka-connect-strimzi.database.postgres.registry.secrets.kubernetesSecrets[0].keys.POSTGRES_USER | string | `""` |  |
| data-infra.kafka-connect-strimzi.database.postgres.registry.secrets.kubernetesSecrets[0].secretName | string | `"postgres"` |  |
| data-infra.kafka-operator.strimziOperator.cruiseControl.image.repository | string | `"harnesssecure/strimzi-kafka-signed"` |  |
| data-infra.kafka-operator.strimziOperator.kafka.image.repository | string | `"harnesssecure/strimzi-kafka-signed"` |  |
| data-infra.kafka-operator.strimziOperator.kafkaConnect.image.repository | string | `"harnesssecure/strimzi-kafka-connect-signed"` |  |
| data-infra.kafka-operator.strimziOperator.kafkaExporter.image.repository | string | `"harnesssecure/strimzi-kafka-signed"` |  |
| data-infra.kafka-operator.strimziOperator.kafkaInit.image.repository | string | `"harnesssecure/kafka-operator-signed"` |  |
| data-infra.kafka-operator.strimziOperator.kafkaMirrorMaker2.image.repository | string | `"harnesssecure/strimzi-kafka-signed"` |  |
| data-infra.kafka-operator.strimziOperator.topicOperator.image.repository | string | `"harnesssecure/kafka-operator-signed"` |  |
| data-infra.kafka-operator.strimziOperator.userOperator.image.repository | string | `"harnesssecure/kafka-operator-signed"` |  |
| data-infra.kafka-platform.kafkaDebugPod.image.registry | string | `"docker.io"` |  |
| data-infra.kafka-platform.kafkaDebugPod.image.repository | string | `"harnesssecure/strimzi-kafka-signed"` |  |
| data-infra.kafka-platform.nodePools.brokers.storage.type | string | `"jbod"` |  |
| data-infra.kafka-platform.nodePools.brokers.storage.volumes[0].class | string | `""` |  |
| data-infra.kafka-platform.nodePools.brokers.storage.volumes[0].deleteClaim | bool | `false` |  |
| data-infra.kafka-platform.nodePools.brokers.storage.volumes[0].id | int | `0` |  |
| data-infra.kafka-platform.nodePools.brokers.storage.volumes[0].kraftMetadata | string | `"shared"` |  |
| data-infra.kafka-platform.nodePools.brokers.storage.volumes[0].size | string | `"100Gi"` |  |
| data-infra.kafka-platform.nodePools.brokers.storage.volumes[0].type | string | `"persistent-claim"` |  |
| data-infra.kafka-platform.nodePools.controllers.storage.type | string | `"jbod"` |  |
| data-infra.kafka-platform.nodePools.controllers.storage.volumes[0].class | string | `""` |  |
| data-infra.kafka-platform.nodePools.controllers.storage.volumes[0].deleteClaim | bool | `false` |  |
| data-infra.kafka-platform.nodePools.controllers.storage.volumes[0].id | int | `0` |  |
| data-infra.kafka-platform.nodePools.controllers.storage.volumes[0].kraftMetadata | string | `"shared"` |  |
| data-infra.kafka-platform.nodePools.controllers.storage.volumes[0].size | string | `"10Gi"` |  |
| data-infra.kafka-platform.nodePools.controllers.storage.volumes[0].type | string | `"persistent-claim"` |  |
| data-infra.schema-registry.backup.enabled | bool | `false` |  |
| data-infra.schema-registry.fullnameOverride | string | `"schema-registry"` |  |
| db-devops.db-devops-service.config.DBOPS_MIGRATIONS_ENABLED | string | `"true"` |  |
| db-devops.db-devops-service.config.INDEX_MANAGER_ENABLED | string | `"false"` |  |
| enabled | bool | `false` |  |
| ff.ff-psql-migrations.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| ff.ff-psql-migrations.postgres.image.tag | string | `"14.20-debian"` |  |
| ff.ff-pushpin-service.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| ff.ff-pushpin-service.postgres.image.tag | string | `"14.20-debian"` |  |
| ff.ff-pushpin-service.waitForInitContainer.image.tag | string | `"1.2.0"` |  |
| ff.ff-service.ff-admin-server.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| ff.ff-service.ff-admin-server.postgres.image.tag | string | `"14.20-debian"` |  |
| ff.ff-service.ff-admin-server.secrets.default.PLATFORM_AUTH_KEY | string | `"secret"` |  |
| ff.ff-service.ff-client-server.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| ff.ff-service.ff-client-server.postgres.image.tag | string | `"14.20-debian"` |  |
| ff.ff-service.ff-client-server.secrets.default.PLATFORM_AUTH_KEY | string | `"secret"` |  |
| ff.ff-service.ff-metrics-server.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| ff.ff-service.ff-metrics-server.postgres.image.tag | string | `"14.20-debian"` |  |
| ff.ff-service.ff-metrics-server.secrets.default.PLATFORM_AUTH_KEY | string | `"secret"` |  |
| ff.ff-timescale-migrations.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| ff.ff-timescale-migrations.postgres.image.tag | string | `"14.20-debian"` |  |
| global.airgap | string | `"false"` | Airgap functionality. Disabled by default |
| global.ar | object | `{"enabled":false}` | Enable to install Artifact Repository (AR) |
| global.autoscaling | object | `{"enabled":true}` | Enable to set auto-scaling globally |
| global.awsServiceEndpointUrls | object | `{"cloudwatchEndPointUrl":"https://monitoring.us-east-2.amazonaws.com","ecsEndPointUrl":"https://ecs.us-east-2.amazonaws.com","enabled":false,"endPointRegion":"us-east-2","stsEndPointUrl":"https://sts.us-east-2.amazonaws.com"}` | Set global.awsServiceEndpointUrls.cloudwatchEndPointUrl to set cloud watch endpoint url |
| global.ccm.enabled | bool | `false` |  |
| global.cd | object | `{"enabled":false}` | Enable to install Continuous Deployment (CD) |
| global.cdc.enabled | bool | `true` | Enable to install Change data capture |
| global.cg | object | `{"enabled":false}` | Enable to install First Generation Harness Platform (disabled by default) |
| global.chaos | object | `{"enabled":false}` | Enable to install Chaos Engineering (CE) (Beta) |
| global.ci | object | `{"enabled":false}` | Enable to install Continuous Integration (CI) |
| global.code | object | `{"enabled":false}` | Enable to install Harness Code services (CODE) |
| global.commonAnnotations | object | `{}` | Add common annotations to all objects |
| global.commonLabels | object | `{}` | Add common labels to all objects |
| global.data-infra.enabled | bool | `false` |  |
| global.database | object | `{"clickhouse":{"enabled":false},"mongo":{"extraArgs":"","hosts":[],"installed":true,"passwordKey":"","protocol":"mongodb","secretName":"","userKey":""},"postgres":{"extraArgs":"","hosts":["postgres:5432"],"installed":true,"passwordKey":"password","protocol":"postgres","secretName":"postgres-secret","userKey":"user"},"redis":{"hosts":["<internal-endpoint-with-port>"],"installed":true,"passwordKey":"password","secretName":"redis-user-pass","userKey":"username"},"timescaledb":{"certKey":"cert","certName":"tsdb-cert","hosts":["hostname.timescale.com:5432"],"installed":true,"passwordKey":"password","secretName":"tsdb-secret","sslEnabled":false,"userKey":"username"}}` | provide overrides to use in-cluster database or configure to use external databases |
| global.database.mongo | object | `{"extraArgs":"","hosts":[],"installed":true,"passwordKey":"","protocol":"mongodb","secretName":"","userKey":""}` | settings to deploy mongo in-cluster or configure to use external mongo source |
| global.database.mongo.extraArgs | string | `""` | set additional arguments to mongo uri |
| global.database.mongo.hosts | list | `[]` | set the mongo hosts if mongo.installed is set to false |
| global.database.mongo.installed | bool | `true` | set false to configure external mongo and generate mongo uri protocol://hosts?extraArgs |
| global.database.mongo.passwordKey | string | `""` | provide the passwordKey to reference mongo password |
| global.database.mongo.protocol | string | `"mongodb"` | set the protocol for mongo uri |
| global.database.mongo.secretName | string | `""` | provide the secretname to reference mongo username and password |
| global.database.mongo.userKey | string | `""` | provide the userKey to reference mongo username |
| global.database.redis.hosts | list | `["<internal-endpoint-with-port>"]` | provide host name for redis |
| global.database.timescaledb.hosts | list | `["hostname.timescale.com:5432"]` | provide host name for timescaledb |
| global.dbops | object | `{"enabled":false}` | Enable to install Database Devops (DB Devops) |
| global.dbopsHelmMigration | object | `{"enabled":true}` | Enable DB DevOps managed migrations (harness-db-migrator) |
| global.externalSecretsLoader.databases.mongo.databaseRole | string | `""` |  |
| global.externalSecretsLoader.databases.mongo.engine | string | `""` |  |
| global.externalSecretsLoader.databases.mongo.overridePath | string | `""` |  |
| global.externalSecretsLoader.databases.mongo.useDatabaseSecretsEngine | bool | `false` |  |
| global.externalSecretsLoader.databases.postgres.basePath | string | `""` |  |
| global.externalSecretsLoader.databases.postgres.databaseRole | string | `""` |  |
| global.externalSecretsLoader.databases.postgres.engine | string | `""` |  |
| global.externalSecretsLoader.databases.postgres.useDatabaseSecretsEngine | bool | `false` |  |
| global.externalSecretsLoader.databases.redis.databaseRole | string | `""` |  |
| global.externalSecretsLoader.databases.redis.engine | string | `""` |  |
| global.externalSecretsLoader.databases.redis.overridePath | string | `""` |  |
| global.externalSecretsLoader.databases.redis.useDatabaseSecretsEngine | bool | `false` |  |
| global.externalSecretsLoader.databases.timescaledb.basePath | string | `""` |  |
| global.externalSecretsLoader.databases.timescaledb.databaseRole | string | `""` |  |
| global.externalSecretsLoader.databases.timescaledb.engine | string | `""` |  |
| global.externalSecretsLoader.databases.timescaledb.useDatabaseSecretsEngine | bool | `false` |  |
| global.externalSecretsLoader.enabled | bool | `false` |  |
| global.externalSecretsLoader.image.pullPolicy | string | `"IfNotPresent"` |  |
| global.externalSecretsLoader.image.repository | string | `"harnesssecure/vault-secret-loader"` |  |
| global.externalSecretsLoader.image.tag | string | `"1.0.10"` |  |
| global.externalSecretsLoader.provider | string | `"vault"` |  |
| global.externalSecretsLoader.vault.address | string | `""` |  |
| global.externalSecretsLoader.vault.auth.method | string | `"token"` |  |
| global.externalSecretsLoader.vault.auth.path | string | `""` |  |
| global.externalSecretsLoader.vault.auth.role | string | `""` |  |
| global.externalSecretsLoader.vault.auth.roleId | string | `""` |  |
| global.externalSecretsLoader.vault.auth.secretId | string | `""` |  |
| global.externalSecretsLoader.vault.auth.token | string | `"vault-token"` |  |
| global.externalSecretsLoader.vault.basePath | string | `""` |  |
| global.externalSecretsLoader.vault.engine | string | `""` |  |
| global.ff | object | `{"enabled":false}` | Enable to install Feature Flags (FF) |
| global.fileLogging.enabled | bool | `true` |  |
| global.fileLogging.maxBackupFileCount | int | `10` |  |
| global.fileLogging.maxFileSize | string | `"50MB"` |  |
| global.fileLogging.path | string | `"/opt/harness/logs/service.log"` |  |
| global.fileLogging.totalFileSizeCap | string | `"600MB"` |  |
| global.gatewayAPI | object | `{"create":false,"enabled":false,"fallbackRoute":{"enabled":false},"parentRef":{"name":"envoy-gateway"},"proxyServiceName":"envoy-gateway-proxy-envoy-gateway"}` | Gateway API configuration (consumed by envoy-gateway subchart condition and harness-common HTTPRoute helpers at global.gatewayAPI.*) |
| global.ha | bool | `true` | High availability: deploy 3 mongodb pods instead of 1. Not recommended for evaluation or POV |
| global.iacm.enabled | bool | `false` |  |
| global.imagePullSecrets | list | `[]` | Image Pull Secrets List for Harness SMP Images |
| global.imageRegistry | string | `""` | This private Docker image registry will override any registries that are defined in subcharts. |
| global.ingress | object | `{"className":"harness","enabled":false,"hosts":["myhost.example.com"],"ingressGatewayServiceUrl":"","objects":{"annotations":{},"grpcRoutes":[],"ingress":[]},"tls":{"enabled":true,"secretName":"harness-cert"}}` | - Set `ingress.enabled` to `true` to create Kubernetes *Ingress* objects for Nginx. |
| global.ingress.hosts | list | `["myhost.example.com"]` | add global.ingress.ingressGatewayServiceUrl in hosts if global.ingress.ingressGatewayServiceUrl is not empty. |
| global.ingress.ingressGatewayServiceUrl | string | `""` | set to ingress controller's k8s service FQDN for internal routing. eg "internal-nginx.default.svc.cluster.local" If not set, internal request routing would happen via global.loadbalancerUrl |
| global.ingress.objects.annotations | object | `{}` | annotations to be added to ingress Objects |
| global.istio | object | `{"additionalResponseHeaders":[],"enabled":false,"gateway":{"create":true,"name":"","namespace":"","port":443,"protocol":"HTTPS","selector":{"istio":"ingressgateway"}},"hosts":["*"],"istioGatewayServiceUrl":"","strict":false,"tls":{"credentialName":"harness-cert","minProtocolVersion":"TLSV1_2","mode":"SIMPLE"},"virtualService":{"gateways":[],"hosts":["myhostname.example.com"]}}` | Istio Ingress Settings |
| global.istio.additionalResponseHeaders | list | `[]` | Additional response headers injected via EnvoyFilter on the Istio gateway. Example: additionalResponseHeaders:   - name: Strict-Transport-Security     value: "max-age=31536000; includeSubDomains"   - name: X-Content-Type-Options     value: nosniff |
| global.istio.gateway.name | string | `""` | override the name of gateway |
| global.istio.gateway.namespace | string | `""` | override the name of namespace to deploy gateway |
| global.istio.gateway.selector | object | `{"istio":"ingressgateway"}` | adds a gateway selector |
| global.istio.hosts | list | `["*"]` | add global.istio.istioGatewayServiceUrl in hosts if global.istio.istioGatewayServiceUrl is not empty. |
| global.istio.istioGatewayServiceUrl | string | `""` | set to istio gateway's k8s service FQDN for internal use case. eg "internal-istio-gateway.istio-system.svc.cluster.local" If not set, internal request routing would happen via global.loadbalancerUrl |
| global.istio.virtualService.hosts | list | `["myhostname.example.com"]` | add global.istio.istioGatewayServiceUrl in hosts if global.istio.istioGatewayServiceUrl is not empty. |
| global.jfr.enabled | bool | `false` |  |
| global.kafka.bootstrapServers | string | `"kafka-platform-kafka-bootstrap:9093"` |  |
| global.kafka.enabled | bool | `false` |  |
| global.kafka.schemaRegistryUrl | string | `"http://schema-registry-service:8081"` |  |
| global.kubeVersion | string | `""` | set kubernetes version override, unrequired if installing using Helm. |
| global.license | object | `{"cg":"","ng":""}` | Place the license key, Harness support team will provide these |
| global.loadbalancerURL | string | `"https://myhostname.example.com"` | Provide your URL for your intended load balancer |
| global.lwd.autocud.enabled | bool | `false` |  |
| global.lwd.enabled | bool | `false` |  |
| global.mongoSSL | bool | `false` | Enable SSL for MongoDB service |
| global.monitoring | object | `{"enabled":false,"path":"/metrics","port":8889}` | Enable monitoring for all harness services: disabled by default |
| global.ng | object | `{"enabled":true}` | Enable to install NG (Next Generation Harness Platform) |
| global.ngcustomdashboard | object | `{"enabled":false}` | Enable to install Next Generation Custom Dashboards (Beta) |
| global.onprem | bool | `true` | If this value is set to false, it can result in database connectivity issues for postgres. |
| global.opa | object | `{"enabled":true}` | Default Enabled, As required by multiple services now (OPA) |
| global.overrideValidation | object | `{"restructuredValues":false}` | Enable to disable validation checks |
| global.pdb.create | bool | `false` |  |
| global.proxy | object | `{"enabled":false,"host":"localhost","password":"","port":80,"protocol":"http","username":""}` | Set global.proxy.protocol to http or https depending on the proxy configuration |
| global.saml | object | `{"autoaccept":false}` | SAML auto acceptance. Enabled will not send invites to email and autoaccepts |
| global.servicediscoverymanager.enabled | bool | `false` | Enable to install Service Discovery Manager (Beta) |
| global.smtpCreateSecret | object | `{"enabled":false}` | Method to create a secret for your SMTP server |
| global.srm | object | `{"enabled":false}` | Enable to install Site Reliability Management (SRM) |
| global.ssca | object | `{"enabled":false}` | Enable to install Software Supply Chain Assurance (SSCA) |
| global.stackDriverLoggingEnabled | bool | `false` | Enable stack driver logging |
| global.sto | object | `{"enabled":false}` | Enable to install Security Test Orchestration (STO) |
| global.storageClass | string | `""` | Configure storage class for Mongo,Timescale,Redis |
| global.storageClassName | string | `""` | Configure storage class for Harness |
| global.ti | object | `{"enabled":true}` | Enable to install Cloud Cost Management (CCM) (Beta) |
| global.ti.enabled | bool | `true` | Enable to install ti service |
| global.unified-data-platform | object | `{"enabled":false}` | Enable to install Harness Unified Data Platform (UDP) |
| global.useImmutableDelegate | string | `"true"` | Utilize immutable delegates (default = true) |
| global.useMinimalDelegateImage | bool | `false` | Use delegate minimal image (default = false) |
| global.waitForInitContainer.enabled | bool | `true` |  |
| global.waitForInitContainer.image.digest | string | `""` |  |
| global.waitForInitContainer.image.pullPolicy | string | `"Always"` |  |
| global.waitForInitContainer.image.registry | string | `"docker.io"` |  |
| global.waitForInitContainer.image.repository | string | `"harnesssecure/helm-init-container"` |  |
| global.waitForInitContainer.image.tag | string | `"1.9.0"` |  |
| iacm.iac-server.affinity | object | `{}` |  |
| iacm.iac-server.autoscaling.enabled | bool | `false` |  |
| iacm.iac-server.createDb.image.repository | string | `"harnesssecure/postgresql"` |  |
| iacm.iac-server.createDb.image.tag | string | `"14.20-debian"` |  |
| iacm.iac-server.nodeSelector | object | `{}` |  |
| iacm.iac-server.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| iacm.iac-server.postgres.image.tag | string | `"14.20-debian"` |  |
| iacm.iac-server.tolerations | list | `[]` |  |
| iacm.iacm-manager.affinity | object | `{}` |  |
| iacm.iacm-manager.autoscaling.enabled | bool | `false` |  |
| iacm.iacm-manager.config.HARNESS_IMAGE_REPOSITORY | string | `"harnesssecure"` |  |
| iacm.iacm-manager.nodeSelector | object | `{}` |  |
| iacm.iacm-manager.tolerations | list | `[]` |  |
| pg-upgrade.post-upgrade.image.registry | string | `"docker.io"` |  |
| pg-upgrade.post-upgrade.image.repository | string | `"harnesssecure/postgresql"` |  |
| pg-upgrade.post-upgrade.image.tag | string | `"16.14-bookworm"` |  |
| pg-upgrade.upgrade.image.registry | string | `"docker.io"` |  |
| pg-upgrade.upgrade.image.repository | string | `"harnesssecure/pg-upgrader"` |  |
| pg-upgrade.upgrade.image.tag | string | `"14-to-16"` |  |
| platform.access-control | object | `{"affinity":{},"config":{"ENV":"SMP"},"mongoHosts":[],"mongoSSL":{"enabled":false},"nodeSelector":{},"postgresql":{"image":{"repository":"harnesssecure/postgresql","tag":"14.20-debian"}},"tolerations":[]}` | Access control settings (taints, tolerations, and so on) |
| platform.access-control.mongoHosts | list | `[]` | - replica3.host.com:27017 |
| platform.access-control.mongoSSL | object | `{"enabled":false}` | enable mongoSSL for external database connections |
| platform.bootstrap.database.clickhouse.enabled | bool | `false` |  |
| platform.bootstrap.database.minio.affinity | object | `{}` |  |
| platform.bootstrap.database.minio.nodeSelector | object | `{}` |  |
| platform.bootstrap.database.minio.tolerations | list | `[]` |  |
| platform.bootstrap.database.mongodb.affinity | object | `{}` |  |
| platform.bootstrap.database.mongodb.arbiter.affinity | object | `{}` |  |
| platform.bootstrap.database.mongodb.arbiter.nodeSelector | object | `{}` |  |
| platform.bootstrap.database.mongodb.arbiter.tolerations | list | `[]` |  |
| platform.bootstrap.database.mongodb.metrics.enabled | bool | `false` |  |
| platform.bootstrap.database.mongodb.nodeSelector | object | `{}` |  |
| platform.bootstrap.database.mongodb.podAnnotations."prometheus.io/path" | string | `"/metrics"` |  |
| platform.bootstrap.database.mongodb.podAnnotations."prometheus.io/port" | string | `"9216"` |  |
| platform.bootstrap.database.mongodb.podAnnotations."prometheus.io/scrape" | string | `"false"` |  |
| platform.bootstrap.database.mongodb.tolerations | list | `[]` |  |
| platform.bootstrap.database.mongodbupgrades.mongoFCVUpgrade.affinity | object | `{}` |  |
| platform.bootstrap.database.mongodbupgrades.mongoFCVUpgrade.enabled | bool | `true` |  |
| platform.bootstrap.database.mongodbupgrades.mongoFCVUpgrade.ignoreFailure | bool | `false` |  |
| platform.bootstrap.database.mongodbupgrades.mongoFCVUpgrade.nodeSelector | object | `{}` |  |
| platform.bootstrap.database.mongodbupgrades.mongoFCVUpgrade.resources | object | `{}` |  |
| platform.bootstrap.database.mongodbupgrades.mongoFCVUpgrade.tolerations | list | `[]` |  |
| platform.bootstrap.database.mongodbupgrades.mongoFCVUpgrade.ttlSecondsAfterFinished | int | `900` |  |
| platform.bootstrap.database.postgresql.image.repository | string | `"harnesssecure/postgresql"` |  |
| platform.bootstrap.database.postgresql.image.tag | string | `"14.20-debian"` |  |
| platform.bootstrap.database.postgresql.metrics.enabled | bool | `false` |  |
| platform.bootstrap.database.postgresql.podAnnotations."prometheus.io/path" | string | `"/metrics"` |  |
| platform.bootstrap.database.postgresql.podAnnotations."prometheus.io/port" | string | `"9187"` |  |
| platform.bootstrap.database.postgresql.podAnnotations."prometheus.io/scrape" | string | `"false"` |  |
| platform.bootstrap.database.redis.affinity | object | `{}` |  |
| platform.bootstrap.database.redis.metrics.enabled | bool | `false` |  |
| platform.bootstrap.database.redis.nodeSelector | object | `{}` |  |
| platform.bootstrap.database.redis.podAnnotations."prometheus.io/path" | string | `"/metrics"` |  |
| platform.bootstrap.database.redis.podAnnotations."prometheus.io/port" | string | `"9121"` |  |
| platform.bootstrap.database.redis.podAnnotations."prometheus.io/scrape" | string | `"false"` |  |
| platform.bootstrap.database.redis.tolerations | list | `[]` |  |
| platform.bootstrap.database.timescaledb.affinity | object | `{}` |  |
| platform.bootstrap.database.timescaledb.curlImage.tag | string | `"8.17.0"` |  |
| platform.bootstrap.database.timescaledb.nodeSelector | object | `{}` |  |
| platform.bootstrap.database.timescaledb.persistentVolumes.data.enabled | bool | `true` |  |
| platform.bootstrap.database.timescaledb.persistentVolumes.data.size | string | `"100Gi"` |  |
| platform.bootstrap.database.timescaledb.persistentVolumes.wal.enabled | bool | `true` |  |
| platform.bootstrap.database.timescaledb.persistentVolumes.wal.size | string | `"1Gi"` |  |
| platform.bootstrap.database.timescaledb.podAnnotations."prometheus.io/path" | string | `"/metrics"` |  |
| platform.bootstrap.database.timescaledb.podAnnotations."prometheus.io/port" | string | `"9187"` |  |
| platform.bootstrap.database.timescaledb.podAnnotations."prometheus.io/scrape" | string | `"false"` |  |
| platform.bootstrap.database.timescaledb.prometheus.enabled | bool | `false` |  |
| platform.bootstrap.database.timescaledb.tolerations | list | `[]` |  |
| platform.bootstrap.harness-secrets.enabled | bool | `true` |  |
| platform.bootstrap.networking.defaultbackend.create | bool | `false` | Create will deploy a default backend into your cluster |
| platform.bootstrap.networking.defaultbackend.resources.limits.memory | string | `"20Mi"` |  |
| platform.bootstrap.networking.defaultbackend.resources.requests.cpu | string | `"10m"` |  |
| platform.bootstrap.networking.defaultbackend.resources.requests.memory | string | `"20Mi"` |  |
| platform.bootstrap.networking.nginx.affinity | object | `{}` |  |
| platform.bootstrap.networking.nginx.controller.annotations | object | `{}` | annotations to be addded to ingress Controller |
| platform.bootstrap.networking.nginx.controller.config.use-forwarded-headers | string | `"true"` | Trust X-Forwarded-Proto from envoy-gateway so nginx does not force-ssl-redirect HTTP traffic forwarded from the gateway. |
| platform.bootstrap.networking.nginx.create | bool | `false` | Create Nginx Controller.  True will deploy a controller into your cluster |
| platform.bootstrap.networking.nginx.healthNodePort | string | `""` |  |
| platform.bootstrap.networking.nginx.healthPort | string | `""` |  |
| platform.bootstrap.networking.nginx.httpNodePort | string | `""` |  |
| platform.bootstrap.networking.nginx.httpsNodePort | string | `""` |  |
| platform.bootstrap.networking.nginx.loadBalancerEnabled | bool | `false` |  |
| platform.bootstrap.networking.nginx.loadBalancerIP | string | `""` |  |
| platform.bootstrap.networking.nginx.nodeSelector | object | `{}` |  |
| platform.bootstrap.networking.nginx.resources.limits.memory | string | `"512Mi"` |  |
| platform.bootstrap.networking.nginx.resources.requests.cpu | string | `"0.5"` |  |
| platform.bootstrap.networking.nginx.resources.requests.memory | string | `"512Mi"` |  |
| platform.bootstrap.networking.nginx.tolerations | list | `[]` |  |
| platform.change-data-capture | object | `{"affinity":{},"config":{"ENV":"SMP"},"nodeSelector":{},"tolerations":[]}` | change-data-capture settings (taints, tolerations, and so on) |
| platform.delegate-proxy | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | delegate proxy settings (taints, tolerations, and so on) |
| platform.envoy-gateway | object | `{"deployCRDsJob":{"enabled":false},"enabled":false,"envoyConfiguration":{"deployment":{"envoyGateway":{"resources":{"limits":{"memory":"1024Mi"},"requests":{"cpu":"100m","memory":"256Mi"}}},"pod":{"affinity":{"podAntiAffinity":{"preferredDuringSchedulingIgnoredDuringExecution":[{"podAffinityTerm":{"labelSelector":{"matchLabels":{"control-plane":"envoy-gateway"}},"topologyKey":"kubernetes.io/hostname"},"weight":100}]}}},"replicas":2},"podDisruptionBudget":{"minAvailable":1}}}` | gateway settings (taints, tolerations, and so on) |
| platform.gateway.affinity | object | `{}` |  |
| platform.gateway.config.ENV | string | `"SMP"` |  |
| platform.gateway.nodeSelector | object | `{}` |  |
| platform.gateway.tolerations | list | `[]` |  |
| platform.harness-manager | object | `{"affinity":{},"config":{"ENV":"SMP"},"featureFlags":{"ADDITIONAL":""},"immutable_delegate_docker_image":{"image":{"digest":"","registry":"docker.io","repository":"harnesssecure/delegate","tag":"26.08.89806"}},"nodeSelector":{},"shutdownHooksEnabled":true,"tolerations":{},"upgrader_docker_image":{"image":{"tag":"1.12.0"}}}` | harness-manager (taints, tolerations, and so on) |
| platform.harness-manager.featureFlags | object | `{"ADDITIONAL":""}` | Feature Flags |
| platform.harness-manager.featureFlags.ADDITIONAL | string | `""` | Additional Feature Flag (placeholder to add any other featureFlags) |
| platform.log-service | object | `{"affinity":{},"config":{"ENV":"SMP"},"nodeSelector":{},"tolerations":[]}` | log-service (taints, tolerations, and so on) |
| platform.looker.affinity | object | `{}` |  |
| platform.looker.nodeSelector | object | `{}` |  |
| platform.looker.tolerations | list | `[]` |  |
| platform.next-gen-ui | object | `{"affinity":{},"config":{"ENV":"SMP"},"nodeSelector":{},"tolerations":[]}` | next-gen-ui (Next Generation User Interface) (taints, tolerations, and so on) |
| platform.ng-auth-ui | object | `{"affinity":{},"config":{"ENV":"SMP"},"nodeSelector":{},"tolerations":[]}` | ng-auth-ui (Next Generation Authorization User Interface) (taints, tolerations, and so on) |
| platform.ng-custom-dashboards.affinity | object | `{}` |  |
| platform.ng-custom-dashboards.nodeSelector | object | `{}` |  |
| platform.ng-custom-dashboards.tolerations | list | `[]` |  |
| platform.ng-manager | object | `{"affinity":{},"config":{"ENV":"SMP"},"nodeSelector":{},"shutdownHooksEnabled":true,"tolerations":[]}` | ng-manager (Next Generation Manager) (taints, tolerations, and so on) |
| platform.pipeline-service | object | `{"affinity":{},"config":{"ENV":"SMP","PUBLISH_ADVISER_EVENT_FOR_CUSTOM_ADVISERS":"true"},"nodeSelector":{},"shutdownHooksEnabled":true,"tolerations":[]}` | pipeline-service (Harness pipeline-related services) (taints, tolerations, and so on) |
| platform.platform-service | object | `{"affinity":{},"config":{"ENV":"SMP"},"nodeSelector":{},"tolerations":[]}` | platform-service (Harness platform-related services) (taints, tolerations, and so on) |
| platform.scm-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | scm-service (taints, tolerations, and so on) |
| platform.template-service | object | `{"affinity":{},"config":{"ENV":"SMP"},"nodeSelector":{},"tolerations":[]}` | template-service (Harness template-related services) (taints, tolerations, and so on) |
| platform.ui | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | ui (Harness First CG Ui component) (taints, tolerations, and so on) |
| postmigrationCheck.affinity | object | `{}` |  |
| postmigrationCheck.enabled | bool | `true` |  |
| postmigrationCheck.image.pullPolicy | string | `"IfNotPresent"` |  |
| postmigrationCheck.image.registry | string | `"docker.io"` |  |
| postmigrationCheck.image.repository | string | `"busybox"` |  |
| postmigrationCheck.image.tag | string | `"1.37.0"` |  |
| postmigrationCheck.nodeSelector | object | `{}` |  |
| postmigrationCheck.resources.limits.cpu | string | `"100m"` |  |
| postmigrationCheck.resources.limits.memory | string | `"128Mi"` |  |
| postmigrationCheck.resources.requests.cpu | string | `"50m"` |  |
| postmigrationCheck.resources.requests.memory | string | `"64Mi"` |  |
| postmigrationCheck.serviceAccount.name | string | `"default"` |  |
| postmigrationCheck.tolerations | list | `[]` |  |
| srm.cv-nextgen.affinity | object | `{}` |  |
| srm.cv-nextgen.config.ENV | string | `"SMP"` |  |
| srm.cv-nextgen.config.PIPELINE_SERVICE_CLIENT_BASEURL | string | `"http://pipeline-service:12001/api/"` |  |
| srm.cv-nextgen.nodeSelector | object | `{}` |  |
| srm.cv-nextgen.tolerations | list | `[]` |  |
| srm.le-nextgen.affinity | object | `{}` |  |
| srm.le-nextgen.ingress | object | `{}` |  |
| srm.le-nextgen.keda.enabled | bool | `false` |  |
| srm.le-nextgen.nodeSelector | object | `{}` |  |
| srm.le-nextgen.tolerations | list | `[]` |  |
| ssca.component-service.config.EOL_DISABLE_MAVEN_EOL | string | `"true"` |  |
| sto | object | `{"sto-core":{"affinity":{},"autoscaling":{"enabled":false},"migrationPostgres":{"image":{"repository":"harnesssecure/postgresql","tag":"14.20-debian"}},"nodeSelector":{},"postgres":{"image":{"repository":"harnesssecure/postgresql","tag":"14.20-debian"}},"tolerations":[]},"ticket-service":{"postgres":{"image":{"repository":"harnesssecure/postgresql","tag":"14.20-debian"}}}}` | Config for Security Test Orchestration (STO) |
| sto.ticket-service | object | `{"postgres":{"image":{"repository":"harnesssecure/postgresql","tag":"14.20-debian"}}}` | Install the STO core |
| upgrades.versionLookups.enabled | bool | `true` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
