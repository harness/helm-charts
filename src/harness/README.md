## Harness Helm Charts

This readme provides the basic instructions you need to deploy Harness using a Helm chart. The Helm chart deploys Harness in a production configuration.

Helm Chart for deploying Harness.

![Version: 0.8.0](https://img.shields.io/badge/Version-0.8.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.79422](https://img.shields.io/badge/AppVersion-1.0.79422-informational?style=flat-square)

For full release notes, go to [Self-Managed Enterprise Edition release notes](https://developer.harness.io/release-notes/self-managed-enterprise-edition).

## Usage

Harness Helm charts require the installation of [Helm](https://helm.sh). To download and get started with Helm, see the [Helm documentation](https://helm.sh/docs/).

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
```
$ helm upgrade my-release harness/harness-demo -n <namespace> -f old_values.yaml
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
docker.io/harness/gitops-service-signed:v0.54.5
docker.io/bitnami/minio:2022.8.22-debian-11-r0
docker.io/bitnami/mongodb:4.2.19
docker.io/bitnami/postgresql:14.4.0-debian-11-r9
docker.io/harness/accesscontrol-service-signed:77002
docker.io/harness/cdcdata-signed:77125
docker.io/harness/ci-manager-signed:906
docker.io/harness/ci-scm-signed:release-87-ubi
docker.io/harness/cv-nextgen-signed:77125
docker.io/harness/dashboard-service-signed:v1.52.24
docker.io/harness/delegate-proxy-signed:77036
docker.io/harness/error-tracking-signed:5.7.4
docker.io/harness/et-collector-signed:5.7.2
docker.io/harness/ff-pushpin-signed:1.0.3
docker.io/harness/ff-pushpin-worker-signed:1.666.0
docker.io/harness/ff-server-signed:1.666.0
docker.io/harness/gateway-signed:200091
docker.io/harness/helm-init-container:latest
docker.io/harness/le-nextgen-signed:67101
docker.io/harness/looker-signed:22.18.18.0
docker.io/harness/manager-signed:77125
docker.io/harness/policy-mgmt:v1.49.0
docker.io/harness/stocore-signed:v1.13.3
docker.io/harness/stomanager-signed:77800-000
docker.io/harness/ti-service-signed:release-87
docker.io/harness/template-service-signed:77125
docker.io/harness/ff-postgres-migration-signed:1.666.0
docker.io/harness/ff-timescale-migration-signed:1.666.0
docker.io/harness/helm-init-container:latest
docker.io/harness/log-service-signed:release-18
docker.io/harness/nextgenui-signed:0.323.11
docker.io/harness/ng-auth-ui-signed:0.42.2
docker.io/harness/ng-manager-signed:77125
docker.io/harness/pipeline-service-signed:1.11.1
docker.io/harness/platform-service-signed:77201
docker.io/harness/redis:6.2.7-alpine
docker.io/harness/ti-service-signed:release-87
docker.io/timescale/timescaledb-ha:pg13-ts2.6-oss-latest
docker.io/harness/ci-addon:1.14.19
docker.io/harness/ci-addon:1.14.21
docker.io/harness/gitops-agent
docker.io/haproxy:2.0.25-alpine
docker.io/redis:6.2.6-alpine
docker.io/plugins/artifactory:1.2.0
docker.io/harness/delegate:latest
docker.io/plugins/kaniko:1.6.6
docker.io/plugins/kaniko-ecr:1.6.6
docker.io/plugins/kaniko-gcr:1.6.6
docker.io/plugins/cache:1.4.2
docker.io/plugins/gcs:1.3.0
docker.io/harness/upgrader:latest
docker.io/harness/drone-git:1.2.4-rootless
docker.io/harness/delegate:22.10.77221
docker.io/harness/ci-lite-engine:1.14.22
docker.io/harness/ci-lite-engine:1.14.21
docker.io/plugins/cache:1.4.2
docker.io/bewithaman/s3:latest
docker.io/plugins/s3:1.1.0
docker.io/harness/sto-plugin:latest
docker.io/harness/sto-plugin:latest
docker.io/harness/upgrader:latest
docker.io/curlimages/curl:latest

```
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ccm | object | `{"batch-processing":{"awsAccountTagsCollectionJobConfig":{"enabled":true},"clickhouse":{"enabled":false},"cloudProviderConfig":{"CLUSTER_DATA_GCS_BACKUP_BUCKET":"placeHolder","CLUSTER_DATA_GCS_BUCKET":"placeHolder","DATA_PIPELINE_CONFIG_GCS_BASE_PATH":"placeHolder","GCP_PROJECT_ID":"placeHolder","S3_SYNC_CONFIG_BUCKET_NAME":"placeHolder","S3_SYNC_CONFIG_REGION":"placeHolder"},"stackDriverLoggingEnabled":false},"clickhouse":{"enabled":false},"event-service":{"stackDriverLoggingEnabled":false},"nextgen-ce":{"clickhouse":{"enabled":false},"cloudProviderConfig":{"GCP_PROJECT_ID":"placeHolder"},"stackDriverLoggingEnabled":false}}` | Enable the Cloud Cost Management (CCM) service |
| ccm.batch-processing | object | `{"awsAccountTagsCollectionJobConfig":{"enabled":true},"clickhouse":{"enabled":false},"cloudProviderConfig":{"CLUSTER_DATA_GCS_BACKUP_BUCKET":"placeHolder","CLUSTER_DATA_GCS_BUCKET":"placeHolder","DATA_PIPELINE_CONFIG_GCS_BASE_PATH":"placeHolder","GCP_PROJECT_ID":"placeHolder","S3_SYNC_CONFIG_BUCKET_NAME":"placeHolder","S3_SYNC_CONFIG_REGION":"placeHolder"},"stackDriverLoggingEnabled":false}` | Set ccm.batch-processing.clickhouse.enabled to true for AWS infrastructure |
| ccm.batch-processing.awsAccountTagsCollectionJobConfig | object | `{"enabled":true}` | Set ccm.batch-processing.awsAccountTagsCollectionJobConfig.enabled to false for AWS infrastructure |
| ccm.batch-processing.clickhouse | object | `{"enabled":false}` | Set ccm.clickhouse.enabled to true for AWS infrastructure |
| ccm.batch-processing.stackDriverLoggingEnabled | bool | `false` | Set ccm.batch-processing.stackDriverLoggingEnabled to true for GCP infrastructure |
| ccm.clickhouse | object | `{"enabled":false}` | Set ccm.clickhouse.enabled to true for AWS infrastructure |
| ccm.event-service | object | `{"stackDriverLoggingEnabled":false}` | Set ccm.event-service.stackDriverLoggingEnabled to true for GCP infrastructure |
| ccm.nextgen-ce | object | `{"clickhouse":{"enabled":false},"cloudProviderConfig":{"GCP_PROJECT_ID":"placeHolder"},"stackDriverLoggingEnabled":false}` | Set ccm.nextgen-ce.clickhouse.enabled to true for AWS infrastructure |
| ccm.nextgen-ce.clickhouse | object | `{"enabled":false}` | Set ccm.clickhouse.enabled to true for AWS infrastructure |
| ccm.nextgen-ce.stackDriverLoggingEnabled | bool | `false` | Set ccm.nextgen-ce.stackDriverLoggingEnabled to true for GCP infrastructure |
| cet | object | `{"enable-receivers":false,"et-collector":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-receiver-agent":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-receiver-decompile":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-receiver-hit":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-receiver-sql":{"affinity":{},"nodeSelector":{},"tolerations":[]},"et-service":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Config for Continuous Error Tracking (CET) |
| cet.enable-receivers | bool | `false` | Flag to enable error-tracking (ET) receivers |
| cet.et-collector | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) collector |
| cet.et-receiver-agent | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) receiver agent |
| cet.et-receiver-decompile | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) receiver decompiler |
| cet.et-receiver-hit | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) receiver hit |
| cet.et-receiver-sql | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) receiver sql service |
| cet.et-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the error-tracking (ET) service |
| chaos.chaos-driver.nodeSelector | object | `{}` |  |
| chaos.chaos-driver.tolerations | list | `[]` |  |
| chaos.chaos-manager.nodeSelector | object | `{}` |  |
| chaos.chaos-manager.tolerations | list | `[]` |  |
| chaos.chaos-web.nodeSelector | object | `{}` |  |
| chaos.chaos-web.tolerations | list | `[]` |  |
| ci | object | `{"ci-manager":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Install the Continuous Integration (CI) manager pod |
| global.airgap | string | `"false"` | Airgap functionality. Disabled by default |
| global.ccm | object | `{"enabled":false}` | Enable to install Cloud Cost Management (CCM) (Beta) |
| global.cd | object | `{"enabled":false}` | Enable to install Continuous Deployment (CD) |
| global.cet | object | `{"enabled":false}` | Enable to install Continuous Error Tracking (CET) |
| global.cg | object | `{"enabled":false}` | Enable to install First Generation Harness Platform (disabled by default) |
| global.chaos | object | `{"enabled":false}` | Enable to install Chaos Engineering (CE) (Beta) |
| global.ci | object | `{"enabled":false}` | Enable to install Continuous Integration (CI) |
| global.database | object | `{"mongo":{"extraArgs":"","hosts":[],"installed":true,"passwordKey":"","protocol":"mongodb","secretName":"","userKey":""}}` | provide overrides to use in-cluster database or configure to use external databases |
| global.database.mongo | object | `{"extraArgs":"","hosts":[],"installed":true,"passwordKey":"","protocol":"mongodb","secretName":"","userKey":""}` | settings to deploy mongo in-cluster or configure to use external mongo source |
| global.database.mongo.extraArgs | string | `""` | set additional arguments to mongo uri |
| global.database.mongo.hosts | list | `[]` | set the mongo hosts if mongo.installed is set to false |
| global.database.mongo.installed | bool | `true` | set false to configure external mongo and generate mongo uri protocol://hosts?extraArgs |
| global.database.mongo.passwordKey | string | `""` | provide the passwordKey to reference mongo password |
| global.database.mongo.protocol | string | `"mongodb"` | set the protocol for mongo uri |
| global.database.mongo.secretName | string | `""` | provide the secretname to reference mongo username and password |
| global.database.mongo.userKey | string | `""` | provide the userKey to reference mongo username |
| global.ff | object | `{"enabled":false}` | Enable to install Feature Flags (FF) |
| global.gitops | object | `{"enabled":false}` | Enable to install gitops |
| global.ha | bool | `true` | High availability: deploy 3 mongodb pods instead of 1. Not recommended for evaluation or POV |
| global.imageRegistry | string | `""` | This private Docker image registry will override any registries that are defined in subcharts. |
| global.ingress | object | `{"className":"harness","defaultbackend":{"create":false,"image":{"digest":"","pullPolicy":"IfNotPresent","registry":"registry.k8s.io","repository":"defaultbackend-amd64","tag":"1.5"},"resources":{"limits":{"memory":"20Mi"},"requests":{"cpu":"10m","memory":"20Mi"}}},"enabled":false,"hosts":["myhost.example.com"],"ingressGatewayServiceUrl":"","loadBalancerEnabled":false,"loadBalancerIP":"0.0.0.0","nginx":{"affinity":{},"controller":{"annotations":{}},"create":false,"healthNodePort":"","healthPort":"","httpNodePort":"","httpsNodePort":"","image":{"digest":"","pullPolicy":"IfNotPresent","registry":"us.gcr.io","repository":"k8s-artifacts-prod/ingress-nginx/controller","tag":"v1.0.0-alpha.2"},"nodeSelector":{},"objects":{"annotations":{}},"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"0.5","memory":"512Mi"}},"tolerations":[]},"tls":{"enabled":true,"secretName":"harness-cert"}}` | - Set `ingress.enabled` to `true` to create Kubernetes *Ingress* objects for Nginx. |
| global.ingress.defaultbackend.create | bool | `false` | Create will deploy a default backend into your cluster |
| global.ingress.hosts | list | `["myhost.example.com"]` | add global.ingress.ingressGatewayServiceUrl in hosts if global.ingress.ingressGatewayServiceUrl is not empty. |
| global.ingress.ingressGatewayServiceUrl | string | `""` | set to ingress controller's k8s service FQDN for internal routing. eg "internal-nginx.default.svc.cluster.local" If not set, internal request routing would happen via global.loadbalancerUrl |
| global.ingress.nginx | object | `{"affinity":{},"controller":{"annotations":{}},"create":false,"healthNodePort":"","healthPort":"","httpNodePort":"","httpsNodePort":"","image":{"digest":"","pullPolicy":"IfNotPresent","registry":"us.gcr.io","repository":"k8s-artifacts-prod/ingress-nginx/controller","tag":"v1.0.0-alpha.2"},"nodeSelector":{},"objects":{"annotations":{}},"resources":{"limits":{"memory":"512Mi"},"requests":{"cpu":"0.5","memory":"512Mi"}},"tolerations":[]}` | Section to provide configuration on an NGINX ingress controller. |
| global.ingress.nginx.controller.annotations | object | `{}` | annotations to be addded to ingress Controller |
| global.ingress.nginx.create | bool | `false` | Create Nginx Controller.  True will deploy a controller into your cluster |
| global.ingress.nginx.objects.annotations | object | `{}` | annotations to be added to ingress Objects |
| global.istio | object | `{"enabled":false,"gateway":{"create":true,"name":"","namespace":"","port":443,"protocol":"HTTPS","selector":{"istio":"ingressgateway"}},"hosts":["*"],"istioGatewayServiceUrl":"","strict":false,"tls":{"credentialName":"harness-cert","minProtocolVersion":"TLSV1_2","mode":"SIMPLE"},"virtualService":{"hosts":["myhostname.example.com"]}}` | Istio Ingress Settings |
| global.istio.gateway.name | string | `""` | override the name of gateway |
| global.istio.gateway.namespace | string | `""` | override the name of namespace to deploy gateway |
| global.istio.gateway.selector | object | `{"istio":"ingressgateway"}` | adds a gateway selector |
| global.istio.hosts | list | `["*"]` | add global.istio.istioGatewayServiceUrl in hosts if global.istio.istioGatewayServiceUrl is not empty. |
| global.istio.istioGatewayServiceUrl | string | `""` | set to istio gateway's k8s service FQDN for internal use case. eg "internal-istio-gateway.istio-system.svc.cluster.local" If not set, internal request routing would happen via global.loadbalancerUrl |
| global.istio.virtualService.hosts | list | `["myhostname.example.com"]` | add global.istio.istioGatewayServiceUrl in hosts if global.istio.istioGatewayServiceUrl is not empty. |
| global.kubeVersion | string | `""` | set kubernetes version override, unrequired if installing using Helm. |
| global.license | object | `{"cg":"","ng":""}` | Place the license key, Harness support team will provide these |
| global.loadbalancerURL | string | `"https://myhostname.example.com"` | Provide your URL for your intended load balancer |
| global.migrator.enabled | bool | `false` |  |
| global.mongoSSL | bool | `false` | Enable SSL for MongoDB service |
| global.monitoring | object | `{"enabled":false,"path":"/metrics","port":8889}` | Enable monitoring for all harness services: disabled by default |
| global.ng | object | `{"enabled":true}` | Enable to install NG (Next Generation Harness Platform) |
| global.ngcustomdashboard | object | `{"enabled":false}` | Enable to install Next Generation Custom Dashboards (Beta) |
| global.opa | object | `{"enabled":false}` | Enable to install Open Policy Agent (OPA) |
| global.postgres | object | `{"enabled":true}` | Enable to deploy postgres(needed for NG components) |
| global.saml | object | `{"autoaccept":false}` | SAML auto acceptance. Enabled will not send invites to email and autoaccepts |
| global.smtpCreateSecret | object | `{"enabled":false}` | Method to create a secret for your SMTP server |
| global.srm | object | `{"enabled":false}` | Enable to install Site Reliability Management (SRM) |
| global.stackDriverLoggingEnabled | bool | `false` | Enable stack driver logging |
| global.sto | object | `{"enabled":false}` | Enable to install Security Test Orchestration (STO) |
| global.storageClass | string | `""` | Configure storage class for Mongo,Timescale,Redis |
| global.storageClassName | string | `""` | Configure storage class for Harness |
| global.useImmutableDelegate | string | `"true"` | Utilize immutable delegates (default = true) |
| global.useMinimalDelegateImage | bool | `false` | Use delegate minimal image (default = false) |
| infra | object | `{"postgresql":{"auth":{"existingSecret":"postgres"},"metrics":{"enabled":false},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9187","prometheus.io/scrape":"false"}}}` | overrides for Postgresql |
| ng-manager | object | `{"ceGcpSetupConfigGcpProjectId":"placeHolder"}` | Enable the Cloud Cost Management (CCM) service for the Next Generation Manager |
| ngcustomdashboard | object | `{"looker":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ng-custom-dashboards":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Install the Next Generation customer dashboard |
| ngcustomdashboard.looker | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the looker service |
| ngcustomdashboard.ng-custom-dashboards | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Install the Next Generation customer dashboards service |
| platform | object | `{"access-control":{"affinity":{},"mongoHosts":[],"mongoSSL":{"enabled":false},"nodeSelector":{},"tolerations":[]},"change-data-capture":{"affinity":{},"nodeSelector":{},"tolerations":[]},"cv-nextgen":{"affinity":{},"nodeSelector":{},"tolerations":[]},"delegate-proxy":{"affinity":{},"nodeSelector":{},"tolerations":[]},"gateway":{"affinity":{},"nodeSelector":{},"tolerations":[]},"harness-manager":{"affinity":{},"featureFlags":{"ADDITIONAL":"","Base":"LDAP_SSO_PROVIDER,ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,BATCH_SECRET_DECRYPTION,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,LOG_STREAMING_INTEGRATION,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_SHOW_DELEGATE,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,LDAP_GROUP_SYNC_JOB_ITERATOR,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,USER_GROUP_AS_EXPRESSION,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,NG_TEMPLATE_GITX,ELK_HEALTH_SOURCE,NG_ENABLE_LDAP_CHECK,CVNG_METRIC_THRESHOLD,SRM_HOST_SAMPLING_ENABLE,SRM_ENABLE_HEALTHSOURCE_CLOUDWATCH_METRICS,NG_SETTINGS","CCM":"CENG_ENABLED,CCM_MICRO_FRONTEND,NODE_RECOMMENDATION_AGGREGATE","CD":"CDS_AUTO_APPROVAL,CDS_NG_TRIGGER_SELECTIVE_STAGE_EXECUTION","CDB":"NG_DASHBOARDS","CET":"CET_ENABLED,SRM_CODE_ERROR_NOTIFICATIONS,SRM_ET_RESOLVED_EVENTS,SRM_ET_CRITICAL_EVENTS","CHAOS":"CHAOS_ENABLED","CI":"CING_ENABLED,CI_INDIRECT_LOG_UPLOAD","FF":"CFNG_ENABLED","GitOps":"GITOPS_ONPREM_ENABLED,CUSTOM_ARTIFACT_NG,SERVICE_DASHBOARD_V2,OPTIMIZED_GIT_FETCH_FILES,MULTI_SERVICE_INFRA,ENV_GROUP,NG_SVC_ENV_REDESIGN","NG":"ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,NEXT_GEN_ENABLED,NEW_LEFT_NAVBAR_SETTINGS,SPG_SIDENAV_COLLAPSE","OPA":"OPA_PIPELINE_GOVERNANCE","SAMLAutoAccept":"AUTO_ACCEPT_SAML_ACCOUNT_INVITES,PL_NO_EMAIL_FOR_SAML_ACCOUNT_INVITES","SRM":"CVNG_ENABLED","STO":"SECURITY,SECURITY_STAGE,STO_CI_PIPELINE_SECURITY,STO_API_V2"},"nodeSelector":{},"tolerations":[]},"harness-secrets":{"enabled":true},"le-nextgen":{"affinity":{},"nodeSelector":{},"tolerations":[]},"learning-engine":{"affinity":{},"nodeSelector":{},"tolerations":[]},"log-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"migrator":{"affinity":{},"nodeSelector":{},"tolerations":[]},"minio":{"affinity":{},"nodeSelector":{},"tolerations":[]},"mongodb":{"affinity":{},"arbiter":{"affinity":{},"nodeSelector":{},"tolerations":[]},"metrics":{"enabled":false},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9216","prometheus.io/scrape":"false"},"tolerations":[]},"next-gen-ui":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ng-auth-ui":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ng-manager":{"affinity":{},"nodeSelector":{},"tolerations":[]},"pipeline-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"platform-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"redis":{"affinity":{},"metrics":{"enabled":false},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9121","prometheus.io/scrape":"false"},"tolerations":[]},"scm-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"template-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"ti-service":{"affinity":{},"nodeSelector":{},"tolerations":[]},"timescaledb":{"affinity":{},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9187","prometheus.io/scrape":"false"},"prometheus":{"enabled":false},"tolerations":[]},"ui":{"affinity":{},"nodeSelector":{},"tolerations":[]},"verification-svc":{"affinity":{},"nodeSelector":{},"tolerations":[]}}` | Config for platform-level services (always deployed by default to support all services) |
| platform.access-control | object | `{"affinity":{},"mongoHosts":[],"mongoSSL":{"enabled":false},"nodeSelector":{},"tolerations":[]}` | Access control settings (taints, tolerations, and so on) |
| platform.access-control.mongoHosts | list | `[]` | - replica3.host.com:27017 |
| platform.access-control.mongoSSL | object | `{"enabled":false}` | enable mongoSSL for external database connections |
| platform.change-data-capture | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | change-data-capture settings (taints, tolerations, and so on) |
| platform.cv-nextgen | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | cv-nextgen settings (taints, tolerations, and so on) |
| platform.delegate-proxy | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | delegate proxy settings (taints, tolerations, and so on) |
| platform.gateway | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | gateway settings (taints, tolerations, and so on) |
| platform.harness-manager | object | `{"affinity":{},"featureFlags":{"ADDITIONAL":"","Base":"LDAP_SSO_PROVIDER,ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,BATCH_SECRET_DECRYPTION,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,LOG_STREAMING_INTEGRATION,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_SHOW_DELEGATE,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,LDAP_GROUP_SYNC_JOB_ITERATOR,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,USER_GROUP_AS_EXPRESSION,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,NG_TEMPLATE_GITX,ELK_HEALTH_SOURCE,NG_ENABLE_LDAP_CHECK,CVNG_METRIC_THRESHOLD,SRM_HOST_SAMPLING_ENABLE,SRM_ENABLE_HEALTHSOURCE_CLOUDWATCH_METRICS,NG_SETTINGS","CCM":"CENG_ENABLED,CCM_MICRO_FRONTEND,NODE_RECOMMENDATION_AGGREGATE","CD":"CDS_AUTO_APPROVAL,CDS_NG_TRIGGER_SELECTIVE_STAGE_EXECUTION","CDB":"NG_DASHBOARDS","CET":"CET_ENABLED,SRM_CODE_ERROR_NOTIFICATIONS,SRM_ET_RESOLVED_EVENTS,SRM_ET_CRITICAL_EVENTS","CHAOS":"CHAOS_ENABLED","CI":"CING_ENABLED,CI_INDIRECT_LOG_UPLOAD","FF":"CFNG_ENABLED","GitOps":"GITOPS_ONPREM_ENABLED,CUSTOM_ARTIFACT_NG,SERVICE_DASHBOARD_V2,OPTIMIZED_GIT_FETCH_FILES,MULTI_SERVICE_INFRA,ENV_GROUP,NG_SVC_ENV_REDESIGN","NG":"ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,NEXT_GEN_ENABLED,NEW_LEFT_NAVBAR_SETTINGS,SPG_SIDENAV_COLLAPSE","OPA":"OPA_PIPELINE_GOVERNANCE","SAMLAutoAccept":"AUTO_ACCEPT_SAML_ACCOUNT_INVITES,PL_NO_EMAIL_FOR_SAML_ACCOUNT_INVITES","SRM":"CVNG_ENABLED","STO":"SECURITY,SECURITY_STAGE,STO_CI_PIPELINE_SECURITY,STO_API_V2"},"nodeSelector":{},"tolerations":[]}` | harness-manager (taints, tolerations, and so on) |
| platform.harness-manager.featureFlags | object | `{"ADDITIONAL":"","Base":"LDAP_SSO_PROVIDER,ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,BATCH_SECRET_DECRYPTION,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,LOG_STREAMING_INTEGRATION,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_SHOW_DELEGATE,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,LDAP_GROUP_SYNC_JOB_ITERATOR,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,USER_GROUP_AS_EXPRESSION,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,NG_TEMPLATE_GITX,ELK_HEALTH_SOURCE,NG_ENABLE_LDAP_CHECK,CVNG_METRIC_THRESHOLD,SRM_HOST_SAMPLING_ENABLE,SRM_ENABLE_HEALTHSOURCE_CLOUDWATCH_METRICS,NG_SETTINGS","CCM":"CENG_ENABLED,CCM_MICRO_FRONTEND,NODE_RECOMMENDATION_AGGREGATE","CD":"CDS_AUTO_APPROVAL,CDS_NG_TRIGGER_SELECTIVE_STAGE_EXECUTION","CDB":"NG_DASHBOARDS","CET":"CET_ENABLED,SRM_CODE_ERROR_NOTIFICATIONS,SRM_ET_RESOLVED_EVENTS,SRM_ET_CRITICAL_EVENTS","CHAOS":"CHAOS_ENABLED","CI":"CING_ENABLED,CI_INDIRECT_LOG_UPLOAD","FF":"CFNG_ENABLED","GitOps":"GITOPS_ONPREM_ENABLED,CUSTOM_ARTIFACT_NG,SERVICE_DASHBOARD_V2,OPTIMIZED_GIT_FETCH_FILES,MULTI_SERVICE_INFRA,ENV_GROUP,NG_SVC_ENV_REDESIGN","NG":"ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,NEXT_GEN_ENABLED,NEW_LEFT_NAVBAR_SETTINGS,SPG_SIDENAV_COLLAPSE","OPA":"OPA_PIPELINE_GOVERNANCE","SAMLAutoAccept":"AUTO_ACCEPT_SAML_ACCOUNT_INVITES,PL_NO_EMAIL_FOR_SAML_ACCOUNT_INVITES","SRM":"CVNG_ENABLED","STO":"SECURITY,SECURITY_STAGE,STO_CI_PIPELINE_SECURITY,STO_API_V2"}` | Feature Flags |
| platform.harness-manager.featureFlags.ADDITIONAL | string | `""` | Additional Feature Flag (placeholder to add any other featureFlags) |
| platform.harness-manager.featureFlags.Base | string | `"LDAP_SSO_PROVIDER,ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,BATCH_SECRET_DECRYPTION,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,LOG_STREAMING_INTEGRATION,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_SHOW_DELEGATE,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,LDAP_GROUP_SYNC_JOB_ITERATOR,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,USER_GROUP_AS_EXPRESSION,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,NG_TEMPLATE_GITX,ELK_HEALTH_SOURCE,NG_ENABLE_LDAP_CHECK,CVNG_METRIC_THRESHOLD,SRM_HOST_SAMPLING_ENABLE,SRM_ENABLE_HEALTHSOURCE_CLOUDWATCH_METRICS,NG_SETTINGS"` | Base flags for all modules(enabled by Default) |
| platform.harness-manager.featureFlags.CCM | string | `"CENG_ENABLED,CCM_MICRO_FRONTEND,NODE_RECOMMENDATION_AGGREGATE"` | CCM Feature Flags (activated when global.ccm is enabled) |
| platform.harness-manager.featureFlags.CD | string | `"CDS_AUTO_APPROVAL,CDS_NG_TRIGGER_SELECTIVE_STAGE_EXECUTION"` | CD Feature Flags (activated when global.cd is enabled) |
| platform.harness-manager.featureFlags.CDB | string | `"NG_DASHBOARDS"` | Custom Dashboard Flags (activated when global.dashboards is enabled) |
| platform.harness-manager.featureFlags.CET | string | `"CET_ENABLED,SRM_CODE_ERROR_NOTIFICATIONS,SRM_ET_RESOLVED_EVENTS,SRM_ET_CRITICAL_EVENTS"` | CET Feature Flags |
| platform.harness-manager.featureFlags.CHAOS | string | `"CHAOS_ENABLED"` | CHAOS Feature Flags (activated when global.chaos is enabled) |
| platform.harness-manager.featureFlags.CI | string | `"CING_ENABLED,CI_INDIRECT_LOG_UPLOAD"` | CI Feature Flags (activated when global.ci is enabled) |
| platform.harness-manager.featureFlags.FF | string | `"CFNG_ENABLED"` | FF Feature Flags (activated when global.ff is enabled) |
| platform.harness-manager.featureFlags.GitOps | string | `"GITOPS_ONPREM_ENABLED,CUSTOM_ARTIFACT_NG,SERVICE_DASHBOARD_V2,OPTIMIZED_GIT_FETCH_FILES,MULTI_SERVICE_INFRA,ENV_GROUP,NG_SVC_ENV_REDESIGN"` | GitOps Feature Flags (activated when global.gitops is enabled) |
| platform.harness-manager.featureFlags.NG | string | `"ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,NEXT_GEN_ENABLED,NEW_LEFT_NAVBAR_SETTINGS,SPG_SIDENAV_COLLAPSE"` | NG Specific Feature Flags(activated when global.ng is enabled) |
| platform.harness-manager.featureFlags.OPA | string | `"OPA_PIPELINE_GOVERNANCE"` | OPA (activated when global.opa is enabled) |
| platform.harness-manager.featureFlags.SAMLAutoAccept | string | `"AUTO_ACCEPT_SAML_ACCOUNT_INVITES,PL_NO_EMAIL_FOR_SAML_ACCOUNT_INVITES"` | AutoAccept Feature Flags |
| platform.harness-manager.featureFlags.SRM | string | `"CVNG_ENABLED"` | SRM Flags (activated when global.srm is enabled) |
| platform.harness-manager.featureFlags.STO | string | `"SECURITY,SECURITY_STAGE,STO_CI_PIPELINE_SECURITY,STO_API_V2"` | STO Feature Flags (activated when global.sto is enabled) |
| platform.harness-secrets | object | `{"enabled":true}` | deploy harness-secret( set false to not deploy any secrets) |
| platform.le-nextgen | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | le-nextgen (taints, tolerations, and so on) |
| platform.log-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | log-service (taints, tolerations, and so on) |
| platform.migrator | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | migrator (taints, tolerations, and so on) |
| platform.minio | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | minio (taints, tolerations, and so on) |
| platform.mongodb | object | `{"affinity":{},"arbiter":{"affinity":{},"nodeSelector":{},"tolerations":[]},"metrics":{"enabled":false},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9216","prometheus.io/scrape":"false"},"tolerations":[]}` | mongodb (taints, tolerations, and so on) |
| platform.next-gen-ui | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | next-gen-ui (Next Generation User Interface) (taints, tolerations, and so on) |
| platform.ng-auth-ui | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | ng-auth-ui (Next Generation Authorization User Interface) (taints, tolerations, and so on) |
| platform.ng-manager | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | ng-manager (Next Generation Manager) (taints, tolerations, and so on) |
| platform.pipeline-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | pipeline-service (Harness pipeline-related services) (taints, tolerations, and so on) |
| platform.platform-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | platform-service (Harness platform-related services) (taints, tolerations, and so on) |
| platform.redis | object | `{"affinity":{},"metrics":{"enabled":false},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9121","prometheus.io/scrape":"false"},"tolerations":[]}` | redis (taints, tolerations, and so on) |
| platform.scm-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | scm-service (taints, tolerations, and so on) |
| platform.template-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | template-service (Harness template-related services) (taints, tolerations, and so on) |
| platform.ti-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | ti-service (Harness Test Intelligence-related services) (taints, tolerations, and so on) |
| platform.timescaledb | object | `{"affinity":{},"nodeSelector":{},"podAnnotations":{"prometheus.io/path":"/metrics","prometheus.io/port":"9187","prometheus.io/scrape":"false"},"prometheus":{"enabled":false},"tolerations":[]}` | timescaledb (Timescale Database service) (taints, tolerations, and so on) |
| platform.ui | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | ui (Harness First CG Ui component) (taints, tolerations, and so on) |
| platform.verification-svc | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | verificiation-service (Harness First CG verification service) (taints, tolerations, and so on) |
| sto | object | `{"sto-core":{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]},"sto-manager":{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]}}` | Config for Security Test Orchestration (STO) |
| sto.sto-core | object | `{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]}` | Install the STO core |
| sto.sto-manager | object | `{"affinity":{},"autoscaling":{"enabled":false},"nodeSelector":{},"tolerations":[]}` | Install the STO manager |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
