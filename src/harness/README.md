## Harness Helm Charts

This readme provides the basic instructions to deploy Harness using a Helm chart. The Helm chart deploys Harness in a production configuration.

Helm Chart for deploying Harness.

![Version: 0.28.1](https://img.shields.io/badge/Version-0.28.1-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.80917](https://img.shields.io/badge/AppVersion-1.0.80917-informational?style=flat-square)

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
bewithaman/s3:latest
docker.io/amazon/aws-cli:latest
docker.io/bitnami/clickhouse:23.9.2-debian-11-r0
docker.io/bitnami/minio:2024.9.22-debian-12-r1
docker.io/bitnami/mongodb-exporter:0.40.0-debian-12-r40
docker.io/bitnami/mongodb:6.0.13
docker.io/bitnami/postgres-exporter:0.16.0-debian-12-r8
docker.io/bitnami/postgresql:14.11.0-debian-11-r17
docker.io/busybox:1.37.0
docker.io/curlimages/curl:8.7.1
docker.io/haproxy:lts-alpine3.18
docker.io/harness/accesscontrol-service-signed:1.82.2
docker.io/harness/argocd:v2.13.5
docker.io/harness/audit-event-streaming-signed:1.29.0
docker.io/harness/batch-processing-signed:1.44.4
docker.io/harness/ccm-gcp-smp-signed:100039
docker.io/harness/cdcdata-signed:1.41.3
docker.io/harness/ce-anomaly-detection-signed:1.8.0
docker.io/harness/ce-cloud-info-signed:1.9.0
docker.io/harness/ce-nextgen-signed:1.47.2
docker.io/harness/chaos-argoexec:v3.4.16
docker.io/harness/chaos-ddcr-faults:1.57.0
docker.io/harness/chaos-ddcr-faults:1.57.1
docker.io/harness/chaos-ddcr:1.57.0
docker.io/harness/chaos-ddcr:1.57.1
docker.io/harness/chaos-exporter:1.57.0
docker.io/harness/chaos-go-runner-base:1.57.0
docker.io/harness/chaos-go-runner-io:1.57.0
docker.io/harness/chaos-go-runner-time:1.57.0
docker.io/harness/chaos-go-runner:1.57.0
docker.io/harness/chaos-log-watcher:1.57.0
docker.io/harness/chaos-machine-ifc-signed:1.57.0
docker.io/harness/chaos-machine-ifs-signed:1.57.0
docker.io/harness/chaos-operator:1.57.0
docker.io/harness/chaos-runner:1.57.0
docker.io/harness/chaos-subscriber:1.57.0
docker.io/harness/chaos-workflow-controller:v3.4.16
docker.io/harness/ci-manager-signed:1.74.4
docker.io/harness/ci-scm-signed:1.20.1
docker.io/harness/code-api-signed:1.34.1
docker.io/harness/code-githa-signed:1.34.0
docker.io/harness/code-gitrpc-signed:1.34.0
docker.io/harness/code-search-signed:1.34.0
docker.io/harness/cv-nextgen-signed:1.37.1
docker.io/harness/dashboard-service-signed:1.80.15
docker.io/harness/db-devops-service-signed:1.35.0
docker.io/harness/debezium-service-signed:1.21.0
docker.io/harness/delegate-proxy-signed:1.1.1
docker.io/harness/delegate:25.04.85602
docker.io/harness/delegate:25.04.85602.minimal
docker.io/harness/enterprise-chaos-hub-signed:1.57.4
docker.io/harness/event-service-signed:1.12.4
docker.io/harness/ff-postgres-migration-signed:1.1094.0
docker.io/harness/ff-pushpin-signed:1.0.11
docker.io/harness/ff-pushpin-worker-signed:1.1079.1
docker.io/harness/ff-server-signed:1.1094.0
docker.io/harness/ff-timescale-migration-signed:1.1094.0
docker.io/harness/gateway-signed:1.42.7
docker.io/harness/gitops-agent-installer-helper:v0.0.3
docker.io/harness/gitops-agent:v0.91.1
docker.io/harness/gitops-service-signed:1.30.2
docker.io/harness/helm-init-container:1.2.0
docker.io/harness/helm-init-container:1.3.0
docker.io/harness/helm-init-container:latest
docker.io/harness/iac-server-signed:1.137.1
docker.io/harness/iacm-manager-signed:1.72.0
docker.io/harness/k8s-chaos-infrastructure-upgrader:1.57.0
docker.io/harness/le-nextgen-signed:1.8.0
docker.io/harness/log-service-signed:1.19.1
docker.io/harness/looker-signed:1.7.11
docker.io/harness/manager-signed:1.81.5
docker.io/harness/nextgenui-signed:1.70.3
docker.io/harness/ng-auth-ui-signed:1.34.0
docker.io/harness/ng-ce-ui:1.43.5
docker.io/harness/ng-dashboard-aggregator-signed:1.47.0
docker.io/harness/ng-manager-signed:1.84.4
docker.io/harness/pipeline-service-signed:1.123.2
docker.io/harness/platform-service-signed:1.61.0
docker.io/harness/policy-mgmt:1.16.1
docker.io/harness/queue-service-signed:1.7.1
docker.io/harness/service-discovery-collector:0.37.3
docker.io/harness/smp-chaos-bg-processor-signed:1.57.4
docker.io/harness/smp-chaos-k8s-ifs-signed:1.57.3
docker.io/harness/smp-chaos-linux-infra-controller-signed:1.57.0
docker.io/harness/smp-chaos-linux-infra-server-signed:1.57.0
docker.io/harness/smp-chaos-manager-signed:1.57.4
docker.io/harness/smp-chaos-web-signed:1.57.1
docker.io/harness/smp-service-discovery-server-signed:0.37.6
docker.io/harness/source-probe:main-latest
docker.io/harness/srm-ui-signed:1.12.0
docker.io/harness/ssca-manager-signed:1.29.2
docker.io/harness/ssca-ui-signed:0.23.1
docker.io/harness/stocore-signed:1.135.0
docker.io/harness/stomanager-signed:1.62.1
docker.io/harness/telescopes-signed:1.4.0
docker.io/harness/template-service-signed:1.85.0
docker.io/harness/ti-service-signed:1.44.0
docker.io/harness/ui-signed:1.22.0
docker.io/harness/upgrader:latest
docker.io/koalaman/shellcheck:v0.5.0
docker.io/oliver006/redis_exporter:latest
docker.io/prom/statsd-exporter:latest
docker.io/redis:6.2.14-alpine
docker.io/redis:7.4.1-alpine
docker.io/timescale/timescaledb-ha:pg13.16-ts2.15.3
harness/anchore-job-runner:latest
harness/aqua-security-job-runner:latest
harness/aqua-trivy-job-runner:latest
harness/aws-ecr-job-runner:latest
harness/aws-security-hub-job-runner:latest
harness/bandit-job-runner:latest
harness/blackduckhub-job-runner:latest
harness/brakeman-job-runner:latest
harness/checkmarx-job-runner:latest
harness/ci-addon:1.16.67
harness/ci-addon:1.16.73
harness/ci-addon:1.16.80
harness/ci-addon:rootless-1.16.73
harness/ci-addon:rootless-1.16.80
harness/ci-lite-engine:1.16.67
harness/ci-lite-engine:1.16.73
harness/ci-lite-engine:1.16.80
harness/ci-lite-engine:rootless-1.16.73
harness/ci-lite-engine:rootless-1.16.80
harness/drone-git:1.6.6-rootless
harness/drone-git:1.6.7-rootless
harness/fossa-job-runner:latest
harness/grype-job-runner:latest
harness/harness-cache-server:1.6.0
harness/nikto-job-runner:latest
harness/nmap-job-runner:latest
harness/osv-job-runner:latest
harness/owasp-dependency-check-job-runner:latest
harness/prowler-job-runner:latest
harness/slsa-plugin:0.34.0
harness/snyk-job-runner:latest
harness/sonarqube-agent-job-runner:latest
harness/ssca-artifact-signing-plugin:0.34.4
harness/ssca-cdxgen-plugin:0.34.1
harness/ssca-compliance-plugin:0.34.0
harness/ssca-plugin:0.34.0
harness/sto-plugin:latest
harness/traceable-job-runner:latest
harness/twistlock-job-runner:latest
harness/veracode-agent-job-runner:latest
harness/whitesource-agent-job-runner:latest
harness/wiz-job-runner:latest
harness/zap-job-runner:latest
plugins/acr:20.18.8
plugins/artifactory:1.7.3
plugins/buildx-acr:1.2.14
plugins/buildx-ecr:1.2.14
plugins/buildx-gar:1.2.14
plugins/buildx-gcr:1.2.11
plugins/buildx:1.2.2
plugins/cache:1.9.6
plugins/docker:20.18.6
plugins/ecr:20.18.7
plugins/gar:20.18.6
plugins/gcr:20.18.6
plugins/gcs:1.6.3
plugins/harness_terraform:latest
plugins/harness_terraform_vm:latest
plugins/kaniko-acr:1.10.7
plugins/kaniko-ecr:1.10.8
plugins/kaniko-gcr:1.10.1
plugins/kaniko:1.10.6
plugins/s3:1.2.7
plugins/s3:1.5.2
quay.io/prometheuscommunity/postgres-exporter:v0.16.0
registry.k8s.io/defaultbackend-amd64:1.5
registry.k8s.io/ingress-nginx/controller:v1.11.2

```
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ccm.batch-processing | object | `{"awsAccountTagsCollectionJobConfig":{"enabled":true},"cliProxy":{"enabled":false,"host":"localhost","password":"","port":80,"protocol":"http","username":""},"cloudProviderConfig":{"CLUSTER_DATA_GCS_BACKUP_BUCKET":"placeHolder","CLUSTER_DATA_GCS_BUCKET":"placeHolder","DATA_PIPELINE_CONFIG_GCS_BASE_PATH":"placeHolder","GCP_PROJECT_ID":"placeHolder","S3_SYNC_CONFIG_BUCKET_NAME":"placeHolder","S3_SYNC_CONFIG_REGION":"placeHolder"},"stackDriverLoggingEnabled":false}` | Set ccm.batch-processing.clickhouse.enabled to true for AWS infrastructure |
| ccm.batch-processing.awsAccountTagsCollectionJobConfig | object | `{"enabled":true}` | Set ccm.batch-processing.awsAccountTagsCollectionJobConfig.enabled to false for AWS infrastructure |
| ccm.batch-processing.cliProxy | object | `{"enabled":false,"host":"localhost","password":"","port":80,"protocol":"http","username":""}` | Set ccm.batch-processing.cliProxy.protocol to http or https depending on the proxy configuration |
| ccm.batch-processing.stackDriverLoggingEnabled | bool | `false` | Set ccm.batch-processing.stackDriverLoggingEnabled to true for GCP infrastructure |
| ccm.ce-nextgen.cloudProviderConfig.GCP_PROJECT_ID | string | `"placeHolder"` |  |
| ccm.ce-nextgen.stackDriverLoggingEnabled | bool | `false` | Set ccm.nextgen-ce.stackDriverLoggingEnabled to true for GCP infrastructure |
| ccm.cloud-info.proxy | object | `{"httpsProxyEnabled":false,"httpsProxyUrl":"http://localhost"}` | Set ccm.cloud-info.proxy.httpsProxyUrl to proxy url(ex: http://localhost:8080, if http proxy is running on localhost port 8080) |
| ccm.event-service | object | `{"stackDriverLoggingEnabled":false}` | Set ccm.event-service.stackDriverLoggingEnabled to true for GCP infrastructure |
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
| ci | object | `{"ci-manager":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ti-service":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Install the Continuous Integration (CI) manager pod |
| enabled | bool | `false` |  |
| ff.ff-pushpin-service.waitForInitContainer.image.tag | string | `"1.2.0"` |  |
| global.airgap | string | `"false"` | Airgap functionality. Disabled by default |
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
| global.database | object | `{"clickhouse":{"enabled":false},"mongo":{"extraArgs":"","hosts":[],"installed":true,"passwordKey":"","protocol":"mongodb","secretName":"","userKey":""},"postgres":{"extraArgs":"","hosts":["<postgres ip>:5432"],"installed":true,"passwordKey":"password","protocol":"postgres","secretName":"postgres-secret","userKey":"user"},"redis":{"hosts":["<internal-endpoint-with-port>"],"installed":true,"passwordKey":"password","secretName":"redis-user-pass","userKey":"username"},"timescaledb":{"certKey":"cert","certName":"tsdb-cert","hosts":["hostname.timescale.com:5432"],"installed":true,"passwordKey":"password","secretName":"tsdb-secret","sslEnabled":false,"userKey":"username"}}` | provide overrides to use in-cluster database or configure to use external databases |
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
| global.ff | object | `{"enabled":false}` | Enable to install Feature Flags (FF) |
| global.fileLogging.enabled | bool | `true` |  |
| global.fileLogging.maxBackupFileCount | int | `10` |  |
| global.fileLogging.maxFileSize | string | `"50MB"` |  |
| global.fileLogging.path | string | `"/opt/harness/logs/service.log"` |  |
| global.fileLogging.totalFileSizeCap | string | `"600MB"` |  |
| global.ha | bool | `true` | High availability: deploy 3 mongodb pods instead of 1. Not recommended for evaluation or POV |
| global.iacm.enabled | bool | `false` |  |
| global.imageRegistry | string | `""` | This private Docker image registry will override any registries that are defined in subcharts. |
| global.ingress | object | `{"className":"harness","enabled":false,"hosts":["myhost.example.com"],"ingressGatewayServiceUrl":"","objects":{"annotations":{}},"tls":{"enabled":true,"secretName":"harness-cert"}}` | - Set `ingress.enabled` to `true` to create Kubernetes *Ingress* objects for Nginx. |
| global.ingress.hosts | list | `["myhost.example.com"]` | add global.ingress.ingressGatewayServiceUrl in hosts if global.ingress.ingressGatewayServiceUrl is not empty. |
| global.ingress.ingressGatewayServiceUrl | string | `""` | set to ingress controller's k8s service FQDN for internal routing. eg "internal-nginx.default.svc.cluster.local" If not set, internal request routing would happen via global.loadbalancerUrl |
| global.ingress.objects.annotations | object | `{}` | annotations to be added to ingress Objects |
| global.istio | object | `{"enabled":false,"gateway":{"create":true,"name":"","namespace":"","port":443,"protocol":"HTTPS","selector":{"istio":"ingressgateway"}},"hosts":["*"],"istioGatewayServiceUrl":"","strict":false,"tls":{"credentialName":"harness-cert","minProtocolVersion":"TLSV1_2","mode":"SIMPLE"},"virtualService":{"gateways":[],"hosts":["myhostname.example.com"]}}` | Istio Ingress Settings |
| global.istio.gateway.name | string | `""` | override the name of gateway |
| global.istio.gateway.namespace | string | `""` | override the name of namespace to deploy gateway |
| global.istio.gateway.selector | object | `{"istio":"ingressgateway"}` | adds a gateway selector |
| global.istio.hosts | list | `["*"]` | add global.istio.istioGatewayServiceUrl in hosts if global.istio.istioGatewayServiceUrl is not empty. |
| global.istio.istioGatewayServiceUrl | string | `""` | set to istio gateway's k8s service FQDN for internal use case. eg "internal-istio-gateway.istio-system.svc.cluster.local" If not set, internal request routing would happen via global.loadbalancerUrl |
| global.istio.virtualService.hosts | list | `["myhostname.example.com"]` | add global.istio.istioGatewayServiceUrl in hosts if global.istio.istioGatewayServiceUrl is not empty. |
| global.kubeVersion | string | `""` | set kubernetes version override, unrequired if installing using Helm. |
| global.license | object | `{"cg":"","ng":""}` | Place the license key, Harness support team will provide these |
| global.loadbalancerURL | string | `"https://myhostname.example.com"` | Provide your URL for your intended load balancer |
| global.lwd.autocud.enabled | bool | `false` |  |
| global.lwd.enabled | bool | `false` |  |
| global.mongoSSL | bool | `false` | Enable SSL for MongoDB service |
| global.monitoring | object | `{"enabled":false,"path":"/metrics","port":8889}` | Enable monitoring for all harness services: disabled by default |
| global.ng | object | `{"enabled":true}` | Enable to install NG (Next Generation Harness Platform) |
| global.ngcustomdashboard | object | `{"enabled":false}` | Enable to install Next Generation Custom Dashboards (Beta) |
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
| global.useImmutableDelegate | string | `"true"` | Utilize immutable delegates (default = true) |
| global.useMinimalDelegateImage | bool | `false` | Use delegate minimal image (default = false) |
| global.waitForInitContainer.enabled | bool | `true` |  |
| global.waitForInitContainer.image.digest | string | `""` |  |
| global.waitForInitContainer.image.imagePullSecrets | list | `[]` |  |
| global.waitForInitContainer.image.pullPolicy | string | `"Always"` |  |
| global.waitForInitContainer.image.registry | string | `"docker.io"` |  |
| global.waitForInitContainer.image.repository | string | `"harness/helm-init-container"` |  |
| global.waitForInitContainer.image.tag | string | `"1.3.0"` |  |
| iacm.iac-server.affinity | object | `{}` |  |
| iacm.iac-server.autoscaling.enabled | bool | `false` |  |
| iacm.iac-server.nodeSelector | object | `{}` |  |
| iacm.iac-server.tolerations | list | `[]` |  |
| iacm.iacm-manager.affinity | object | `{}` |  |
| iacm.iacm-manager.autoscaling.enabled | bool | `false` |  |
| iacm.iacm-manager.nodeSelector | object | `{}` |  |
| iacm.iacm-manager.tolerations | list | `[]` |  |
| platform | object | `{"access-control":{"affinity":{},"mongoHosts":[],"mongoSSL":{"enabled":false},"nodeSelector":{},"tolerations":[]},"bootstrap":{"database":{"clickhouse":{"enabled":false},"minio":{"affinity":{},"nodeSelector":{},"tolerations":[]},"mongodb":{"affinity":{},"arbiter":{"affinity":{},"nodeSelector":{},"tolerations":[]},"metrics":{"enabled":false,"image":{"tag":"0.40.0-debian-12-r40"}},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9216","prometheus.io/scrape":"false"},"tolerations":[]},"postgresql":{"metrics":{"enabled":false},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9187","prometheus.io/scrape":"false"}},"redis":{"affinity":{},"metrics":{"enabled":false},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9121","prometheus.io/scrape":"false"},"tolerations":[]},"timescaledb":{"affinity":{},"nodeSelector":{},"persistentVolumes":{"data":{"enabled":true,"size":"100Gi"},"wal":{"enabled":true,"size":"1Gi"}},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9187","prometheus.io/scrape":"false"},"prometheus":{"enabled":false},"tolerations":[]}},"harness-secrets":{"enabled":true},"networking":{"defaultbackend":{"create":false,"resources":{"limits":{"memory":"20Mi"},"requests":{"cpu":"10m","memory":"20Mi"}}},"nginx":{"affinity":{},"controller":{"annotations":{}},"create":false,"healthNodePort":"","healthPort":"","httpNodePort":"","httpsNodePort":"","loadBalancerEnabled":false,"loadBalancerIP":"0.0.0.0","nodeSelector":{},"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"0.5","memory":"512Mi"}},"tolerations":[]}}},"change-data-capture":{"affinity":{},"nodeSelector":{},"tolerations":[]},"delegate-proxy":{"affinity":{},"nodeSelector":{},"tolerations":[]},"gateway":{"affinity":{},"nodeSelector":{},"tolerations":[]},"harness-manager":{"affinity":{},"featureFlags":{"ADDITIONAL":""},"immutable_delegate_docker_image":{"image":{"digest":"","registry":"docker.io","repository":"harness/delegate","tag":"25.04.85602"}},"nodeSelector":{},"tolerations":{}},"log-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"looker":{"affinity":{},"nodeSelector":{},"tolerations":[]},"next-gen-ui":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ng-auth-ui":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ng-custom-dashboards":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ng-manager":{"affinity":{},"nodeSelector":{},"tolerations":[]},"pipeline-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"platform-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"scm-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"template-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ui":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Config for platform-level services (always deployed by default to support all services) |
| platform.access-control | object | `{"affinity":{},"mongoHosts":[],"mongoSSL":{"enabled":false},"nodeSelector":{},"tolerations":[]}` | Access control settings (taints, tolerations, and so on) |
| platform.access-control.mongoHosts | list | `[]` | - replica3.host.com:27017 |
| platform.access-control.mongoSSL | object | `{"enabled":false}` | enable mongoSSL for external database connections |
| platform.bootstrap.networking.defaultbackend.create | bool | `false` | Create will deploy a default backend into your cluster |
| platform.bootstrap.networking.nginx.controller.annotations | object | `{}` | annotations to be addded to ingress Controller |
| platform.bootstrap.networking.nginx.create | bool | `false` | Create Nginx Controller.  True will deploy a controller into your cluster |
| platform.change-data-capture | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | change-data-capture settings (taints, tolerations, and so on) |
| platform.delegate-proxy | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | delegate proxy settings (taints, tolerations, and so on) |
| platform.gateway | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | gateway settings (taints, tolerations, and so on) |
| platform.harness-manager | object | `{"affinity":{},"featureFlags":{"ADDITIONAL":""},"immutable_delegate_docker_image":{"image":{"digest":"","registry":"docker.io","repository":"harness/delegate","tag":"25.04.85602"}},"nodeSelector":{},"tolerations":{}}` | harness-manager (taints, tolerations, and so on) |
| platform.harness-manager.featureFlags | object | `{"ADDITIONAL":""}` | Feature Flags |
| platform.harness-manager.featureFlags.ADDITIONAL | string | `""` | Additional Feature Flag (placeholder to add any other featureFlags) |
| platform.log-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | log-service (taints, tolerations, and so on) |
| platform.next-gen-ui | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | next-gen-ui (Next Generation User Interface) (taints, tolerations, and so on) |
| platform.ng-auth-ui | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | ng-auth-ui (Next Generation Authorization User Interface) (taints, tolerations, and so on) |
| platform.ng-manager | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | ng-manager (Next Generation Manager) (taints, tolerations, and so on) |
| platform.pipeline-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | pipeline-service (Harness pipeline-related services) (taints, tolerations, and so on) |
| platform.platform-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | platform-service (Harness platform-related services) (taints, tolerations, and so on) |
| platform.scm-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | scm-service (taints, tolerations, and so on) |
| platform.template-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | template-service (Harness template-related services) (taints, tolerations, and so on) |
| platform.ui | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | ui (Harness First CG Ui component) (taints, tolerations, and so on) |
| srm.cv-nextgen.affinity | object | `{}` |  |
| srm.cv-nextgen.nodeSelector | object | `{}` |  |
| srm.cv-nextgen.tolerations | list | `[]` |  |
| srm.le-nextgen.affinity | object | `{}` |  |
| srm.le-nextgen.nodeSelector | object | `{}` |  |
| srm.le-nextgen.tolerations | list | `[]` |  |
| sto | object | `{"sto-core":{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]},"sto-manager":{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]}}` | Config for Security Test Orchestration (STO) |
| sto.sto-core | object | `{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]}` | Install the STO core |
| sto.sto-manager | object | `{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]}` | Install the STO manager |
| upgrades.mongoFCVUpgrade.affinity | object | `{}` |  |
| upgrades.mongoFCVUpgrade.enabled | bool | `true` |  |
| upgrades.mongoFCVUpgrade.image.registry | string | `"docker.io"` |  |
| upgrades.mongoFCVUpgrade.image.repository | string | `"bitnami/mongodb"` |  |
| upgrades.mongoFCVUpgrade.image.tag | string | `"6.0.13"` |  |
| upgrades.mongoFCVUpgrade.nodeSelector | object | `{}` |  |
| upgrades.mongoFCVUpgrade.tolerations | list | `[]` |  |
| upgrades.versionLookups.enabled | bool | `true` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
