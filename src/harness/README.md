## Harness Helm Charts

This readme provides the basic instructions to deploy Harness using a Helm chart. The Helm chart deploys Harness in a production configuration.

Helm Chart for deploying Harness.

![Version: 0.13.2](https://img.shields.io/badge/Version-0.13.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.80917](https://img.shields.io/badge/AppVersion-1.0.80917-informational?style=flat-square)

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
docker.io/bitnami/clickhouse:23.9.2-debian-11-r0
docker.io/bitnami/minio:2023.10.7-debian-11-r2
docker.io/bitnami/postgresql:14.9.0-debian-11-r60
docker.io/chaosnative/argoexec:v3.4.14
docker.io/chaosnative/chaos-exporter:1.28.0
docker.io/chaosnative/chaos-go-runner-base:1.28.0
docker.io/chaosnative/chaos-go-runner-io:1.28.0
docker.io/chaosnative/chaos-go-runner-time:1.28.0
docker.io/chaosnative/chaos-go-runner:1.28.0
docker.io/chaosnative/chaos-operator:1.28.0
docker.io/chaosnative/chaos-runner:1.28.0
docker.io/chaosnative/harness-chaos-log-watcher:1.22.0
docker.io/chaosnative/harness-chaos-log-watcher:1.28.0
docker.io/chaosnative/harness-k8s-chaos-infrastructure-upgrader:1.28.0
docker.io/chaosnative/harness-smp-chaos-bg-processor:1.28.0
docker.io/chaosnative/harness-smp-chaos-subscriber:1.28.0
docker.io/chaosnative/k8s:1.28.0
docker.io/chaosnative/litmus-checker:1.28.0
docker.io/chaosnative/smp-service-discovery-server:0.8.0
docker.io/chaosnative/source-probe:ci
docker.io/chaosnative/workflow-controller:v3.4.14
docker.io/curlimages/curl:8.1.2
docker.io/haproxy:lts-alpine3.18
docker.io/harness/accesscontrol-service-signed:1.29.2
docker.io/harness/argocd:v2.9.3
docker.io/harness/batch-processing-signed:1.1.1
docker.io/harness/ccm-gcp-smp-signed:10057
docker.io/harness/cdcdata-signed:1.1.2
docker.io/harness/ce-anomaly-detection-signed:1.1.0
docker.io/harness/ce-cloud-info-signed:1.1.2
docker.io/harness/ce-nextgen-signed:81904-000
docker.io/harness/ci-manager-signed:1.6.11
docker.io/harness/ci-scm-signed:1.1.0
docker.io/harness/cv-nextgen-signed:1.11.4
docker.io/harness/dashboard-service-signed:1.55.5
docker.io/harness/debezium-service-signed:1.0.1
docker.io/harness/delegate-proxy-signed:81011_3
docker.io/harness/delegate-proxy-signed:81011_minimal
docker.io/harness/delegate:24.01.82004
docker.io/harness/delegate:24.01.82004.minimal
docker.io/harness/delegate:latest
docker.io/harness/error-tracking-signed:5.32.4
docker.io/harness/et-collector-signed:5.32.4
docker.io/harness/et-receiver-signed:5.32.4
docker.io/harness/event-service-signed:79404-000
docker.io/harness/ff-postgres-migration-signed:1.1094.0
docker.io/harness/ff-pushpin-signed:1.0.11
docker.io/harness/ff-pushpin-worker-signed:1.1094.0
docker.io/harness/ff-server-signed:1.1094.0
docker.io/harness/ff-timescale-migration-signed:1.1094.0
docker.io/harness/gateway-signed:1.19.3
docker.io/harness/gitops-agent-installer-helper:v0.0.1
docker.io/harness/gitops-agent:v0.66.0
docker.io/harness/gitops-service-signed:1.2.2
docker.io/harness/helm-init-container:latest
docker.io/harness/le-nextgen-signed:68006
docker.io/harness/learning-engine-onprem-signed:67903
docker.io/harness/log-service-signed:1.1.0
docker.io/harness/looker-signed:23.20.39
docker.io/harness/manager-signed:1.10.9
docker.io/harness/migrator-signed:1.6.1
docker.io/harness/mongo:4.4.22
docker.io/harness/nextgenui-signed:0.372.18
docker.io/harness/ng-auth-ui-signed:1.16.0
docker.io/harness/ng-ce-ui:0.58.2
docker.io/harness/ng-dashboard-aggregator-signed:1.2.0
docker.io/harness/ng-manager-signed:1.19.11
docker.io/harness/pipeline-service-signed:1.56.7
docker.io/harness/platform-service-signed:1.8.2
docker.io/harness/policy-mgmt:v1.71.1
docker.io/harness/smp-chaos-db-upgrade-agent-signed:1.28.0
docker.io/harness/smp-chaos-k8s-ifs-signed:1.28.0
docker.io/harness/smp-chaos-linux-infra-controller-signed:1.28.1
docker.io/harness/smp-chaos-linux-infra-server-signed:1.28.0
docker.io/harness/smp-chaos-manager-signed:1.28.3
docker.io/harness/smp-chaos-web-signed:1.28.2
docker.io/harness/srm-ui-signed:1.3.0
docker.io/harness/ssca-manager-signed:1.6.11
docker.io/harness/ssca-ui-signed:0.3.2
docker.io/harness/stocore-signed:1.79.3
docker.io/harness/stomanager-signed:1.2.3
docker.io/harness/telescopes-signed:10302
docker.io/harness/template-service-signed:1.21.1
docker.io/harness/ti-service-signed:release-223
docker.io/harness/ui-signed:1.1.1
docker.io/harness/upgrader:latest
docker.io/harness/verification-service-signed:1.7.2
docker.io/redis:6.2.12-alpine
docker.io/redis:6.2.14-alpine
docker.io/timescale/timescaledb-ha:pg13-ts2.9-oss-latest
docker.io/ubuntu:20.04
harness/anchore-job-runner:latest
harness/aqua-trivy-job-runner:latest
harness/aws-ecr-job-runner:latest
harness/aws-security-hub-job-runner:latest
harness/bandit-job-runner:latest
harness/blackduckhub-job-runner:latest
harness/brakeman-job-runner:latest
harness/checkmarx-job-runner:latest
harness/ci-addon:1.16.34
harness/ci-lite-engine:1.16.34
harness/drone-git:1.4.9-rootless
harness/fossa-job-runner:latest
harness/grype-job-runner:latest
harness/nikto-job-runner:latest
harness/nmap-job-runner:latest
harness/owasp-dependency-check-job-runner:latest
harness/prowler-job-runner:latest
harness/slsa-plugin:0.14.3
harness/snyk-job-runner:latest
harness/sonarqube-agent-job-runner:latest
harness/ssca-plugin:0.12.2
harness/ssca-plugin:0.14.4
harness/sto-plugin:1.21.0
harness/sto-plugin:latest
harness/twistlock-job-runner:latest
harness/veracode-agent-job-runner:latest
harness/whitesource-agent-job-runner:latest
harness/zap-job-runner:latest
plugins/artifactory:1.4.8
plugins/cache:1.6.5
plugins/gcs:1.5.1
plugins/kaniko-acr:1.8.1
plugins/kaniko-ecr:1.8.1
plugins/kaniko-gcr:1.8.1
plugins/kaniko:1.8.1
plugins/s3:1.2.9

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
| cet | object | `{"enable-receivers":false,"et-collector":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-receiver-agent":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-receiver-decompile":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-receiver-hit":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-receiver-sql":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-service":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Config for Continuous Error Tracking (CET) |
| cet.enable-receivers | bool | `false` | Flag to enable error-tracking (ET) receivers |
| cet.et-collector | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) collector |
| cet.et-receiver-agent | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) receiver agent |
| cet.et-receiver-decompile | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) receiver decompiler |
| cet.et-receiver-hit | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) receiver hit |
| cet.et-receiver-sql | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) receiver sql service |
| cet.et-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) service |
| chaos.chaos-manager.nodeSelector | object | `{}` |  |
| chaos.chaos-manager.tolerations | list | `[]` |  |
| chaos.chaos-web.nodeSelector | object | `{}` |  |
| chaos.chaos-web.tolerations | list | `[]` |  |
| ci | object | `{"ci-manager":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ti-service":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Install the Continuous Integration (CI) manager pod |
| enabled | bool | `false` |  |
| global.airgap | string | `"false"` | Airgap functionality. Disabled by default |
| global.awsServiceEndpointUrls | object | `{"cloudwatchEndPointUrl":"https://monitoring.us-east-2.amazonaws.com","ecsEndPointUrl":"https://ecs.us-east-2.amazonaws.com","enabled":false,"endPointRegion":"us-east-2","stsEndPointUrl":"https://sts.us-east-2.amazonaws.com"}` | Set global.awsServiceEndpointUrls.cloudwatchEndPointUrl to set cloud watch endpoint url |
| global.ccm | object | `{"enabled":false}` | Enable to install Cloud Cost Management (CCM) (Beta) |
| global.cd | object | `{"enabled":false}` | Enable to install Continuous Deployment (CD) |
| global.cet | object | `{"enabled":false}` | Enable to install Continuous Error Tracking (CET) |
| global.cg | object | `{"enabled":false}` | Enable to install First Generation Harness Platform (disabled by default) |
| global.chaos | object | `{"enabled":false}` | Enable to install Chaos Engineering (CE) (Beta) |
| global.ci | object | `{"enabled":false}` | Enable to install Continuous Integration (CI) |
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
| global.ff | object | `{"enabled":false}` | Enable to install Feature Flags (FF) |
| global.gitops | object | `{"enabled":false}` | Enable to install gitops |
| global.ha | bool | `true` | High availability: deploy 3 mongodb pods instead of 1. Not recommended for evaluation or POV |
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
| global.migrator.enabled | bool | `false` |  |
| global.mongoSSL | bool | `false` | Enable SSL for MongoDB service |
| global.monitoring | object | `{"enabled":false,"path":"/metrics","port":8889}` | Enable monitoring for all harness services: disabled by default |
| global.ng | object | `{"enabled":true}` | Enable to install NG (Next Generation Harness Platform) |
| global.ngcustomdashboard | object | `{"enabled":false}` | Enable to install Next Generation Custom Dashboards (Beta) |
| global.opa | object | `{"enabled":false}` | Enable to install Open Policy Agent (OPA) |
| global.overrideValidation | object | `{"restructuredValues":false}` | Enable to disable validation checks |
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
| global.useImmutableDelegate | string | `"true"` | Utilize immutable delegates (default = true) |
| global.useMinimalDelegateImage | bool | `false` | Use delegate minimal image (default = false) |
| platform | object | `{"access-control":{"affinity":{},"mongoHosts":[],"mongoSSL":{"enabled":false},"nodeSelector":{},"tolerations":[]},"bootstrap":{"database":{"clickhouse":{"enabled":false},"minio":{"affinity":{},"nodeSelector":{},"tolerations":[]},"mongodb":{"affinity":{},"arbiter":{"affinity":{},"nodeSelector":{},"tolerations":[]},"metrics":{"enabled":false},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9216","prometheus.io/scrape":"false"},"tolerations":[]},"postgresql":{"auth":{"existingSecret":"postgres"},"metrics":{"enabled":false},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9187","prometheus.io/scrape":"false"}},"redis":{"affinity":{},"metrics":{"enabled":false},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9121","prometheus.io/scrape":"false"},"tolerations":[]},"timescaledb":{"affinity":{},"nodeSelector":{},"persistentVolumes":{"data":{"enabled":true,"size":"100Gi"},"wal":{"enabled":true,"size":"1Gi"}},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9187","prometheus.io/scrape":"false"},"prometheus":{"enabled":false},"tolerations":[]}},"harness-secrets":{"enabled":true},"networking":{"defaultbackend":{"create":false,"resources":{"limits":{"memory":"20Mi"},"requests":{"cpu":"10m","memory":"20Mi"}}},"nginx":{"affinity":{},"controller":{"annotations":{}},"create":false,"healthNodePort":"","healthPort":"","httpNodePort":"","httpsNodePort":"","loadBalancerEnabled":false,"loadBalancerIP":"0.0.0.0","nodeSelector":{},"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"0.5","memory":"512Mi"}},"tolerations":[]}}},"change-data-capture":{"affinity":{},"nodeSelector":{},"tolerations":[]},"delegate-proxy":{"affinity":{},"nodeSelector":{},"tolerations":[]},"gateway":{"affinity":{},"nodeSelector":{},"tolerations":[]},"harness-manager":{"affinity":{},"featureFlags":{"ADDITIONAL":"","Base":"ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,LOG_STREAMING_INTEGRATION,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,NG_TEMPLATE_GITX,ELK_HEALTH_SOURCE,CVNG_METRIC_THRESHOLD,SRM_HOST_SAMPLING_ENABLE,SRM_ENABLE_HEALTHSOURCE_CLOUDWATCH_METRICS,CDS_SHELL_VARIABLES_EXPORT,CDS_TAS_NG,CD_TRIGGER_V2,CDS_NG_TRIGGER_MULTI_ARTIFACTS,ACCOUNT_BASIC_ROLE,PL_ENABLE_BASIC_ROLE_FOR_PROJECTS_ORGS,CD_NG_DOCKER_ARTIFACT_DIGEST,CDS_SERVICE_OVERRIDES_2_0,NG_SVC_ENV_REDESIGN,NG_EXECUTION_INPUT,CDS_SERVICENOW_REFRESH_TOKEN_AUTH,SERVICE_DASHBOARD_V2,CDS_OrgAccountLevelServiceEnvEnvGroup,CDC_SERVICE_DASHBOARD_REVAMP_NG,PL_FORCE_DELETE_CONNECTOR_SECRET,POST_PROD_ROLLBACK,PIE_STATIC_YAML_SCHEMA,SPG_SIDENAV_COLLAPSE,CI_LE_STATUS_REST_ENABLED,HOSTED_BUILDS,CIE_HOSTED_VMS,ENABLE_K8_BUILDS,CI_DISABLE_RESOURCE_OPTIMIZATION,CI_OUTPUT_VARIABLES_AS_ENV,CODE_ENABLED,CDS_GITHUB_APP_AUTHENTICATION,CDS_REMOVE_TIME_BUCKET_GAPFILL_QUERY,CDS_CONTAINER_STEP_GROUP,CDS_SUPPORT_EXPRESSION_REMOTE_TERRAFORM_VAR_FILES_NG,CDS_AWS_CDK,DISABLE_WINRM_COMMAND_ENCODING_NG,SKIP_ADDING_TRACK_LABEL_SELECTOR_IN_ROLLING,CDS_HTTP_STEP_NG_CERTIFICATE,ENABLE_CERT_VALIDATION,CDS_GET_SERVICENOW_STANDARD_TEMPLATE,CDS_ENABLE_NEW_PARAMETER_FIELD_PROCESSOR,SRM_MICRO_FRONTEND,CVNG_TEMPLATE_MONITORED_SERVICE,PIE_ASYNC_FILTER_CREATION,PL_DISCOVERY_ENABLE,PIE_GIT_BI_DIRECTIONAL_SYNC,CDS_METHOD_INVOCATION_NEW_FLOW_EXPRESSION_ENGINE,CD_NG_DYNAMIC_PROVISIONING_ENV_V2,CDS_HELM_MULTIPLE_MANIFEST_SUPPORT_NG,CDS_SERVERLESS_V2,CDP_AWS_SAM,CDS_IMPROVED_HELM_DEPLOYMENT_TRACKING,CDS_K8S_APPLY_MANIFEST_WITHOUT_SERVICE_NG,CDS_HELM_FETCH_CHART_METADATA_NG","CCM":"CENG_ENABLED,CCM_MICRO_FRONTEND,NODE_RECOMMENDATION_AGGREGATE","CD":"CDS_AUTO_APPROVAL,CDS_NG_TRIGGER_SELECTIVE_STAGE_EXECUTION","CDB":"NG_DASHBOARDS","CET":"CET_ENABLED,SRM_CODE_ERROR_NOTIFICATIONS,SRM_ET_RESOLVED_EVENTS,SRM_ET_CRITICAL_EVENTS","CHAOS":"CHAOS_ENABLED","CI":"CING_ENABLED,CI_INDIRECT_LOG_UPLOAD,CI_LE_STATUS_REST_ENABLED","FF":"CFNG_ENABLED","GitOps":"GITOPS_ONPREM_ENABLED,CUSTOM_ARTIFACT_NG,SERVICE_DASHBOARD_V2,OPTIMIZED_GIT_FETCH_FILES,MULTI_SERVICE_INFRA,ENV_GROUP,NG_SVC_ENV_REDESIGN,GITOPS_ORG_LEVEL","NG":"ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,NEXT_GEN_ENABLED,NEW_LEFT_NAVBAR_SETTINGS,SPG_SIDENAV_COLLAPSE,PL_ENABLE_JIT_USER_PROVISION","OPA":"OPA_PIPELINE_GOVERNANCE,OPA_GIT_GOVERNANCE","SAMLAutoAccept":"AUTO_ACCEPT_SAML_ACCOUNT_INVITES,PL_NO_EMAIL_FOR_SAML_ACCOUNT_INVITES","SRM":"CVNG_ENABLED","SSCA":"SSCA_ENABLED,SSCA_MANAGER_ENABLED,SSCA_SLSA_COMPLIANCE","STO":"STO_BASELINE_REGEX,STO_STEP_PALETTE_BURP_ENTERPRISE,STO_STEP_PALETTE_CODEQL,STO_STEP_PALETTE_FOSSA,STO_STEP_PALETTE_GIT_LEAKS,STO_STEP_PALETTE_SEMGREP"},"nodeSelector":{},"tolerations":[]},"log-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"looker":{"affinity":{},"nodeSelector":{},"tolerations":[]},"migrator":{"affinity":{},"nodeSelector":{},"tolerations":[]},"next-gen-ui":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ng-auth-ui":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ng-custom-dashboards":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ng-manager":{"affinity":{},"nodeSelector":{},"tolerations":[]},"pipeline-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"platform-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"scm-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"template-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ui":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Config for platform-level services (always deployed by default to support all services) |
| platform.access-control | object | `{"affinity":{},"mongoHosts":[],"mongoSSL":{"enabled":false},"nodeSelector":{},"tolerations":[]}` | Access control settings (taints, tolerations, and so on) |
| platform.access-control.mongoHosts | list | `[]` | - replica3.host.com:27017 |
| platform.access-control.mongoSSL | object | `{"enabled":false}` | enable mongoSSL for external database connections |
| platform.bootstrap.networking.defaultbackend.create | bool | `false` | Create will deploy a default backend into your cluster |
| platform.bootstrap.networking.nginx.controller.annotations | object | `{}` | annotations to be addded to ingress Controller |
| platform.bootstrap.networking.nginx.create | bool | `false` | Create Nginx Controller.  True will deploy a controller into your cluster |
| platform.change-data-capture | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | change-data-capture settings (taints, tolerations, and so on) |
| platform.delegate-proxy | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | delegate proxy settings (taints, tolerations, and so on) |
| platform.gateway | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | gateway settings (taints, tolerations, and so on) |
| platform.harness-manager | object | `{"affinity":{},"featureFlags":{"ADDITIONAL":"","Base":"ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,LOG_STREAMING_INTEGRATION,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,NG_TEMPLATE_GITX,ELK_HEALTH_SOURCE,CVNG_METRIC_THRESHOLD,SRM_HOST_SAMPLING_ENABLE,SRM_ENABLE_HEALTHSOURCE_CLOUDWATCH_METRICS,CDS_SHELL_VARIABLES_EXPORT,CDS_TAS_NG,CD_TRIGGER_V2,CDS_NG_TRIGGER_MULTI_ARTIFACTS,ACCOUNT_BASIC_ROLE,PL_ENABLE_BASIC_ROLE_FOR_PROJECTS_ORGS,CD_NG_DOCKER_ARTIFACT_DIGEST,CDS_SERVICE_OVERRIDES_2_0,NG_SVC_ENV_REDESIGN,NG_EXECUTION_INPUT,CDS_SERVICENOW_REFRESH_TOKEN_AUTH,SERVICE_DASHBOARD_V2,CDS_OrgAccountLevelServiceEnvEnvGroup,CDC_SERVICE_DASHBOARD_REVAMP_NG,PL_FORCE_DELETE_CONNECTOR_SECRET,POST_PROD_ROLLBACK,PIE_STATIC_YAML_SCHEMA,SPG_SIDENAV_COLLAPSE,CI_LE_STATUS_REST_ENABLED,HOSTED_BUILDS,CIE_HOSTED_VMS,ENABLE_K8_BUILDS,CI_DISABLE_RESOURCE_OPTIMIZATION,CI_OUTPUT_VARIABLES_AS_ENV,CODE_ENABLED,CDS_GITHUB_APP_AUTHENTICATION,CDS_REMOVE_TIME_BUCKET_GAPFILL_QUERY,CDS_CONTAINER_STEP_GROUP,CDS_SUPPORT_EXPRESSION_REMOTE_TERRAFORM_VAR_FILES_NG,CDS_AWS_CDK,DISABLE_WINRM_COMMAND_ENCODING_NG,SKIP_ADDING_TRACK_LABEL_SELECTOR_IN_ROLLING,CDS_HTTP_STEP_NG_CERTIFICATE,ENABLE_CERT_VALIDATION,CDS_GET_SERVICENOW_STANDARD_TEMPLATE,CDS_ENABLE_NEW_PARAMETER_FIELD_PROCESSOR,SRM_MICRO_FRONTEND,CVNG_TEMPLATE_MONITORED_SERVICE,PIE_ASYNC_FILTER_CREATION,PL_DISCOVERY_ENABLE,PIE_GIT_BI_DIRECTIONAL_SYNC,CDS_METHOD_INVOCATION_NEW_FLOW_EXPRESSION_ENGINE,CD_NG_DYNAMIC_PROVISIONING_ENV_V2,CDS_HELM_MULTIPLE_MANIFEST_SUPPORT_NG,CDS_SERVERLESS_V2,CDP_AWS_SAM,CDS_IMPROVED_HELM_DEPLOYMENT_TRACKING,CDS_K8S_APPLY_MANIFEST_WITHOUT_SERVICE_NG,CDS_HELM_FETCH_CHART_METADATA_NG","CCM":"CENG_ENABLED,CCM_MICRO_FRONTEND,NODE_RECOMMENDATION_AGGREGATE","CD":"CDS_AUTO_APPROVAL,CDS_NG_TRIGGER_SELECTIVE_STAGE_EXECUTION","CDB":"NG_DASHBOARDS","CET":"CET_ENABLED,SRM_CODE_ERROR_NOTIFICATIONS,SRM_ET_RESOLVED_EVENTS,SRM_ET_CRITICAL_EVENTS","CHAOS":"CHAOS_ENABLED","CI":"CING_ENABLED,CI_INDIRECT_LOG_UPLOAD,CI_LE_STATUS_REST_ENABLED","FF":"CFNG_ENABLED","GitOps":"GITOPS_ONPREM_ENABLED,CUSTOM_ARTIFACT_NG,SERVICE_DASHBOARD_V2,OPTIMIZED_GIT_FETCH_FILES,MULTI_SERVICE_INFRA,ENV_GROUP,NG_SVC_ENV_REDESIGN,GITOPS_ORG_LEVEL","NG":"ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,NEXT_GEN_ENABLED,NEW_LEFT_NAVBAR_SETTINGS,SPG_SIDENAV_COLLAPSE,PL_ENABLE_JIT_USER_PROVISION","OPA":"OPA_PIPELINE_GOVERNANCE,OPA_GIT_GOVERNANCE","SAMLAutoAccept":"AUTO_ACCEPT_SAML_ACCOUNT_INVITES,PL_NO_EMAIL_FOR_SAML_ACCOUNT_INVITES","SRM":"CVNG_ENABLED","SSCA":"SSCA_ENABLED,SSCA_MANAGER_ENABLED,SSCA_SLSA_COMPLIANCE","STO":"STO_BASELINE_REGEX,STO_STEP_PALETTE_BURP_ENTERPRISE,STO_STEP_PALETTE_CODEQL,STO_STEP_PALETTE_FOSSA,STO_STEP_PALETTE_GIT_LEAKS,STO_STEP_PALETTE_SEMGREP"},"nodeSelector":{},"tolerations":[]}` | harness-manager (taints, tolerations, and so on) |
| platform.harness-manager.featureFlags | object | `{"ADDITIONAL":"","Base":"ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,LOG_STREAMING_INTEGRATION,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,NG_TEMPLATE_GITX,ELK_HEALTH_SOURCE,CVNG_METRIC_THRESHOLD,SRM_HOST_SAMPLING_ENABLE,SRM_ENABLE_HEALTHSOURCE_CLOUDWATCH_METRICS,CDS_SHELL_VARIABLES_EXPORT,CDS_TAS_NG,CD_TRIGGER_V2,CDS_NG_TRIGGER_MULTI_ARTIFACTS,ACCOUNT_BASIC_ROLE,PL_ENABLE_BASIC_ROLE_FOR_PROJECTS_ORGS,CD_NG_DOCKER_ARTIFACT_DIGEST,CDS_SERVICE_OVERRIDES_2_0,NG_SVC_ENV_REDESIGN,NG_EXECUTION_INPUT,CDS_SERVICENOW_REFRESH_TOKEN_AUTH,SERVICE_DASHBOARD_V2,CDS_OrgAccountLevelServiceEnvEnvGroup,CDC_SERVICE_DASHBOARD_REVAMP_NG,PL_FORCE_DELETE_CONNECTOR_SECRET,POST_PROD_ROLLBACK,PIE_STATIC_YAML_SCHEMA,SPG_SIDENAV_COLLAPSE,CI_LE_STATUS_REST_ENABLED,HOSTED_BUILDS,CIE_HOSTED_VMS,ENABLE_K8_BUILDS,CI_DISABLE_RESOURCE_OPTIMIZATION,CI_OUTPUT_VARIABLES_AS_ENV,CODE_ENABLED,CDS_GITHUB_APP_AUTHENTICATION,CDS_REMOVE_TIME_BUCKET_GAPFILL_QUERY,CDS_CONTAINER_STEP_GROUP,CDS_SUPPORT_EXPRESSION_REMOTE_TERRAFORM_VAR_FILES_NG,CDS_AWS_CDK,DISABLE_WINRM_COMMAND_ENCODING_NG,SKIP_ADDING_TRACK_LABEL_SELECTOR_IN_ROLLING,CDS_HTTP_STEP_NG_CERTIFICATE,ENABLE_CERT_VALIDATION,CDS_GET_SERVICENOW_STANDARD_TEMPLATE,CDS_ENABLE_NEW_PARAMETER_FIELD_PROCESSOR,SRM_MICRO_FRONTEND,CVNG_TEMPLATE_MONITORED_SERVICE,PIE_ASYNC_FILTER_CREATION,PL_DISCOVERY_ENABLE,PIE_GIT_BI_DIRECTIONAL_SYNC,CDS_METHOD_INVOCATION_NEW_FLOW_EXPRESSION_ENGINE,CD_NG_DYNAMIC_PROVISIONING_ENV_V2,CDS_HELM_MULTIPLE_MANIFEST_SUPPORT_NG,CDS_SERVERLESS_V2,CDP_AWS_SAM,CDS_IMPROVED_HELM_DEPLOYMENT_TRACKING,CDS_K8S_APPLY_MANIFEST_WITHOUT_SERVICE_NG,CDS_HELM_FETCH_CHART_METADATA_NG","CCM":"CENG_ENABLED,CCM_MICRO_FRONTEND,NODE_RECOMMENDATION_AGGREGATE","CD":"CDS_AUTO_APPROVAL,CDS_NG_TRIGGER_SELECTIVE_STAGE_EXECUTION","CDB":"NG_DASHBOARDS","CET":"CET_ENABLED,SRM_CODE_ERROR_NOTIFICATIONS,SRM_ET_RESOLVED_EVENTS,SRM_ET_CRITICAL_EVENTS","CHAOS":"CHAOS_ENABLED","CI":"CING_ENABLED,CI_INDIRECT_LOG_UPLOAD,CI_LE_STATUS_REST_ENABLED","FF":"CFNG_ENABLED","GitOps":"GITOPS_ONPREM_ENABLED,CUSTOM_ARTIFACT_NG,SERVICE_DASHBOARD_V2,OPTIMIZED_GIT_FETCH_FILES,MULTI_SERVICE_INFRA,ENV_GROUP,NG_SVC_ENV_REDESIGN,GITOPS_ORG_LEVEL","NG":"ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,NEXT_GEN_ENABLED,NEW_LEFT_NAVBAR_SETTINGS,SPG_SIDENAV_COLLAPSE,PL_ENABLE_JIT_USER_PROVISION","OPA":"OPA_PIPELINE_GOVERNANCE,OPA_GIT_GOVERNANCE","SAMLAutoAccept":"AUTO_ACCEPT_SAML_ACCOUNT_INVITES,PL_NO_EMAIL_FOR_SAML_ACCOUNT_INVITES","SRM":"CVNG_ENABLED","SSCA":"SSCA_ENABLED,SSCA_MANAGER_ENABLED,SSCA_SLSA_COMPLIANCE","STO":"STO_BASELINE_REGEX,STO_STEP_PALETTE_BURP_ENTERPRISE,STO_STEP_PALETTE_CODEQL,STO_STEP_PALETTE_FOSSA,STO_STEP_PALETTE_GIT_LEAKS,STO_STEP_PALETTE_SEMGREP"}` | Feature Flags |
| platform.harness-manager.featureFlags.ADDITIONAL | string | `""` | Additional Feature Flag (placeholder to add any other featureFlags) |
| platform.harness-manager.featureFlags.Base | string | `"ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,LOG_STREAMING_INTEGRATION,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,NG_TEMPLATE_GITX,ELK_HEALTH_SOURCE,CVNG_METRIC_THRESHOLD,SRM_HOST_SAMPLING_ENABLE,SRM_ENABLE_HEALTHSOURCE_CLOUDWATCH_METRICS,CDS_SHELL_VARIABLES_EXPORT,CDS_TAS_NG,CD_TRIGGER_V2,CDS_NG_TRIGGER_MULTI_ARTIFACTS,ACCOUNT_BASIC_ROLE,PL_ENABLE_BASIC_ROLE_FOR_PROJECTS_ORGS,CD_NG_DOCKER_ARTIFACT_DIGEST,CDS_SERVICE_OVERRIDES_2_0,NG_SVC_ENV_REDESIGN,NG_EXECUTION_INPUT,CDS_SERVICENOW_REFRESH_TOKEN_AUTH,SERVICE_DASHBOARD_V2,CDS_OrgAccountLevelServiceEnvEnvGroup,CDC_SERVICE_DASHBOARD_REVAMP_NG,PL_FORCE_DELETE_CONNECTOR_SECRET,POST_PROD_ROLLBACK,PIE_STATIC_YAML_SCHEMA,SPG_SIDENAV_COLLAPSE,CI_LE_STATUS_REST_ENABLED,HOSTED_BUILDS,CIE_HOSTED_VMS,ENABLE_K8_BUILDS,CI_DISABLE_RESOURCE_OPTIMIZATION,CI_OUTPUT_VARIABLES_AS_ENV,CODE_ENABLED,CDS_GITHUB_APP_AUTHENTICATION,CDS_REMOVE_TIME_BUCKET_GAPFILL_QUERY,CDS_CONTAINER_STEP_GROUP,CDS_SUPPORT_EXPRESSION_REMOTE_TERRAFORM_VAR_FILES_NG,CDS_AWS_CDK,DISABLE_WINRM_COMMAND_ENCODING_NG,SKIP_ADDING_TRACK_LABEL_SELECTOR_IN_ROLLING,CDS_HTTP_STEP_NG_CERTIFICATE,ENABLE_CERT_VALIDATION,CDS_GET_SERVICENOW_STANDARD_TEMPLATE,CDS_ENABLE_NEW_PARAMETER_FIELD_PROCESSOR,SRM_MICRO_FRONTEND,CVNG_TEMPLATE_MONITORED_SERVICE,PIE_ASYNC_FILTER_CREATION,PL_DISCOVERY_ENABLE,PIE_GIT_BI_DIRECTIONAL_SYNC,CDS_METHOD_INVOCATION_NEW_FLOW_EXPRESSION_ENGINE,CD_NG_DYNAMIC_PROVISIONING_ENV_V2,CDS_HELM_MULTIPLE_MANIFEST_SUPPORT_NG,CDS_SERVERLESS_V2,CDP_AWS_SAM,CDS_IMPROVED_HELM_DEPLOYMENT_TRACKING,CDS_K8S_APPLY_MANIFEST_WITHOUT_SERVICE_NG,CDS_HELM_FETCH_CHART_METADATA_NG"` | Base flags for all modules(enabled by Default) |
| platform.harness-manager.featureFlags.CCM | string | `"CENG_ENABLED,CCM_MICRO_FRONTEND,NODE_RECOMMENDATION_AGGREGATE"` | CCM Feature Flags (activated when global.ccm is enabled) |
| platform.harness-manager.featureFlags.CD | string | `"CDS_AUTO_APPROVAL,CDS_NG_TRIGGER_SELECTIVE_STAGE_EXECUTION"` | CD Feature Flags (activated when global.cd is enabled) |
| platform.harness-manager.featureFlags.CDB | string | `"NG_DASHBOARDS"` | Custom Dashboard Flags (activated when global.dashboards is enabled) |
| platform.harness-manager.featureFlags.CET | string | `"CET_ENABLED,SRM_CODE_ERROR_NOTIFICATIONS,SRM_ET_RESOLVED_EVENTS,SRM_ET_CRITICAL_EVENTS"` | CET Feature Flags (activated when global.cet is enabled) |
| platform.harness-manager.featureFlags.CHAOS | string | `"CHAOS_ENABLED"` | CHAOS Feature Flags (activated when global.chaos is enabled) |
| platform.harness-manager.featureFlags.CI | string | `"CING_ENABLED,CI_INDIRECT_LOG_UPLOAD,CI_LE_STATUS_REST_ENABLED"` | CI Feature Flags (activated when global.ci is enabled) |
| platform.harness-manager.featureFlags.FF | string | `"CFNG_ENABLED"` | FF Feature Flags (activated when global.ff is enabled) |
| platform.harness-manager.featureFlags.GitOps | string | `"GITOPS_ONPREM_ENABLED,CUSTOM_ARTIFACT_NG,SERVICE_DASHBOARD_V2,OPTIMIZED_GIT_FETCH_FILES,MULTI_SERVICE_INFRA,ENV_GROUP,NG_SVC_ENV_REDESIGN,GITOPS_ORG_LEVEL"` | GitOps Feature Flags (activated when global.gitops is enabled) |
| platform.harness-manager.featureFlags.NG | string | `"ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,NEXT_GEN_ENABLED,NEW_LEFT_NAVBAR_SETTINGS,SPG_SIDENAV_COLLAPSE,PL_ENABLE_JIT_USER_PROVISION"` | NG Specific Feature Flags(activated when global.ng is enabled) |
| platform.harness-manager.featureFlags.OPA | string | `"OPA_PIPELINE_GOVERNANCE,OPA_GIT_GOVERNANCE"` | OPA (activated when global.opa is enabled) |
| platform.harness-manager.featureFlags.SAMLAutoAccept | string | `"AUTO_ACCEPT_SAML_ACCOUNT_INVITES,PL_NO_EMAIL_FOR_SAML_ACCOUNT_INVITES"` | AutoAccept Feature Flags |
| platform.harness-manager.featureFlags.SRM | string | `"CVNG_ENABLED"` | SRM Flags (activated when global.srm is enabled) |
| platform.harness-manager.featureFlags.SSCA | string | `"SSCA_ENABLED,SSCA_MANAGER_ENABLED,SSCA_SLSA_COMPLIANCE"` | SSCA Feature Flags (activated when global.ssca is enabled) |
| platform.harness-manager.featureFlags.STO | string | `"STO_BASELINE_REGEX,STO_STEP_PALETTE_BURP_ENTERPRISE,STO_STEP_PALETTE_CODEQL,STO_STEP_PALETTE_FOSSA,STO_STEP_PALETTE_GIT_LEAKS,STO_STEP_PALETTE_SEMGREP"` | STO Feature Flags (activated when global.sto is enabled) |
| platform.log-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | log-service (taints, tolerations, and so on) |
| platform.migrator | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | migrator (taints, tolerations, and so on) |
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
| srm.learning-engine.affinity | object | `{}` |  |
| srm.learning-engine.nodeSelector | object | `{}` |  |
| srm.learning-engine.tolerations | list | `[]` |  |
| srm.verification-svc.affinity | object | `{}` |  |
| srm.verification-svc.nodeSelector | object | `{}` |  |
| srm.verification-svc.tolerations | list | `[]` |  |
| sto | object | `{"sto-core":{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]},"sto-manager":{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]}}` | Config for Security Test Orchestration (STO) |
| sto.sto-core | object | `{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]}` | Install the STO core |
| sto.sto-manager | object | `{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]}` | Install the STO manager |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.12.0](https://github.com/norwoodj/helm-docs/releases/v1.12.0)
