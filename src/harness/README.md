## Harness Helm Charts

Helm Chart for deploying Harness.

![Version: 0.2.33](https://img.shields.io/badge/Version-0.2.33-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.76519](https://img.shields.io/badge/AppVersion-1.0.76519-informational?style=flat-square)

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
$ helm repo add harness https://harness.github.io/helm-charts
```
## Requirements
* Istio installed within kubernetes, for reference: https://istio.io/latest/docs/setup/getting-started/

## Installing the chart
Create a namespace for your installation
```
$ kubectl create namespace <namespace>
```

Create your override.yaml file with your envirionment settings:

```
## Global Settings
global:
  # -- Enable for complete airgap environment
  airgap: false
  ha: true
  # -- Global Docker image registry
  imageRegistry: ""
  # -- Fully qualified URL of your loadbalancer (ex: https://www.foo.com)
  loadbalancerURL: ""
  mongoSSL: false
  storageClassName: ""
  ingress:
    enabled: false
  istio:
    enabled: true
    strict: true
    gateway:
      # -- Enable to create istio-system gateway
      create: true
      port: 443
      protocol: HTTPS
    hosts:
      - '*'
    tls:
      credentialName:
      minProtocolVersion: TLSV1_2
      mode: SIMPLE
    virtualService:
      gateways:
        - ""
      hosts:
        - ""

ci:
  # -- Enable to install CI
  enabled: true

sto:
  # -- Enable to install STO
  enabled: true

et:
  # --- Enable to install ET
  enabled: true

## Platform Settings
platform:
  # -- Feature list to enable within platform.  Contact Harness for value
  harness-manager:
    features: SECURITY,SECURITY_STAGE,STO_CI_PIPELINE_SECURITY,STO_API_V2,LDAP_SSO_PROVIDER,ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,BATCH_SECRET_DECRYPTION,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,CDNG_ENABLED,NEXT_GEN_ENABLED,LOG_STREAMING_INTEGRATION,CING_ENABLED,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_SHOW_DELEGATE,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,PRUNE_KUBERNETES_RESOURCES,LDAP_GROUP_SYNC_JOB_ITERATOR,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,USER_GROUP_AS_EXPRESSION,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,CVNG_ENABLED,ERROR_TRACKING_ENABLED

```

Installing the helm chart
```
$  helm install my-release harness/harness-prod -n <namespace> -f override.yaml
```

### Accessing the application
Please refer the following documentation: https://docs.harness.io/article/gqoqinkhck-install-harness-self-managed-enterprise-edition-with-helm#create_your_harness_account
## Upgrading the chart
Find out the release-name using
```
$ helm ls -n <namespace>
```
Get the data from previous release
```
$ helm get values my-release > old_values.yaml
```
Then change the fields in old_values.yaml file as required. Now update the chart using
Helm Upgrade
```
$ helm upgrade my-release harness/harness-demo -n <namespace> -f old_values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm uninstall my-release -n <namespace>
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ci.enabled | bool | `true` | Enable to install CI |
| et.enabled | bool | `true` | - Enable to install ET |
| global.airgap | bool | `false` | Enable for complete airgap environment |
| global.ha | bool | `true` |  |
| global.imageRegistry | string | `""` | Global Docker image registry |
| global.ingress.enabled | bool | `false` |  |
| global.istio.enabled | bool | `true` |  |
| global.istio.gateway.create | bool | `true` | Enable to create istio-system gateway |
| global.istio.gateway.port | int | `443` |  |
| global.istio.gateway.protocol | string | `"HTTPS"` |  |
| global.istio.hosts[0] | string | `"*"` |  |
| global.istio.strict | bool | `true` |  |
| global.istio.tls.credentialName | string | `nil` |  |
| global.istio.tls.minProtocolVersion | string | `"TLSV1_2"` |  |
| global.istio.tls.mode | string | `"SIMPLE"` |  |
| global.istio.virtualService.gateways[0] | string | `""` |  |
| global.istio.virtualService.hosts[0] | string | `""` |  |
| global.loadbalancerURL | string | `""` | Fully qualified URL of your loadbalancer (ex: https://www.foo.com) |
| global.mongoSSL | bool | `false` |  |
| global.storageClassName | string | `""` |  |
| platform.harness-manager | object | `{"features":"SECURITY,SECURITY_STAGE,STO_CI_PIPELINE_SECURITY,STO_API_V2,LDAP_SSO_PROVIDER,ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,BATCH_SECRET_DECRYPTION,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,CDNG_ENABLED,NEXT_GEN_ENABLED,LOG_STREAMING_INTEGRATION,CING_ENABLED,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_SHOW_DELEGATE,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,PRUNE_KUBERNETES_RESOURCES,LDAP_GROUP_SYNC_JOB_ITERATOR,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,USER_GROUP_AS_EXPRESSION,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM,CVNG_ENABLED,ERROR_TRACKING_ENABLED"}` | Feature list to enable within platform.  Contact Harness for value |
| sto.enabled | bool | `true` | Enable to install STO |

