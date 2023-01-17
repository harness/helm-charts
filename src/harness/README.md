## Harness Helm Charts

This readme provides the basic instructions you need to deploy Harness using a Helm chart. The Helm chart deploys Harness in a production configuration.

Helm Chart for deploying Harness.

![Version: 0.2.93](https://img.shields.io/badge/Version-0.2.93-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.77629](https://img.shields.io/badge/AppVersion-1.0.77629-informational?style=flat-square)

## Usage

Harness Helm charts require the installation of [Helm](https://helm.sh). To download and get started with Helm, see the [Helm documentation](https://helm.sh/docs/).

Use the following command to add the Harness chart repository to your Helm installation:

```console
$ helm repo add harness https://harness.github.io/helm-charts
```
## Requirements
* [Istio](https://isio/io). This Helm chart includes Istio service mesh as an optional dependency and requires its installation. For information about how to download and install Istio into your Kubernetes clusters, see https://istio.io/latest/docs/setup/getting-started/

## Install the chart
Use the following process to install the Helm chart.
1. Create a namespace for your installation.
```
$ kubectl create namespace <namespace>
```

2. Create the override.yaml file using your envirionment settings:

Install the Helm chart:
```
$  helm install my-release harness/harness-prod -n <namespace> -f override.yaml
```

### Access the application
Verify your installation by accessing the Harness application and creating your Harness account. For basic instructions, see https://docs.harness.io/article/gqoqinkhck-install-harness-self-managed-enterprise-edition-with-helm#create_your_harness_account.

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
docker.io/harness/gitops-service-signed:v0.59.5
docker.io/bitnami/minio:2022.8.22-debian-11-r0
docker.io/bitnami/mongodb:4.2.19
docker.io/bitnami/postgresql:14.4.0-debian-11-r9
docker.io/harness/accesscontrol-service-signed:77301
docker.io/harness/cdcdata-signed:77629
docker.io/harness/ci-manager-signed:1714
docker.io/harness/ci-scm-signed:release-88-ubi
docker.io/harness/cv-nextgen-signed:77629
docker.io/harness/dashboard-service-signed:v1.52.24
docker.io/harness/delegate-proxy-signed:77629
docker.io/harness/error-tracking-signed:5.7.4
docker.io/harness/et-collector-signed:5.7.2
docker.io/harness/ff-pushpin-signed:1.0.3
docker.io/harness/ff-pushpin-worker-signed:1.738.0
docker.io/harness/ff-server-signed:1.738.0
docker.io/harness/gateway-signed:2000125
docker.io/harness/helm-init-container:latest
docker.io/harness/le-nextgen-signed:67200
docker.io/harness/looker-signed:22.18.18.0
docker.io/harness/manager-signed:77629
docker.io/harness/policy-mgmt:v1.49.0
docker.io/harness/stocore-signed:v1.14.4
docker.io/harness/stomanager-signed:77800-000
docker.io/harness/ti-service-signed:release-98
docker.io/ubuntu:20.04
docker.io/harness/template-service-signed:77629
docker.io/harness/ff-postgres-migration-signed:1.738.0
docker.io/harness/ff-timescale-migration-signed:1.738.0
docker.io/harness/helm-init-container:latest
docker.io/harness/log-service-signed:release-18
docker.io/harness/nextgenui-signed:0.331.16
docker.io/harness/ng-auth-ui-signed:0.45.0
docker.io/harness/ng-manager-signed:77629
docker.io/harness/pipeline-service-signed:1.16.3
docker.io/harness/platform-service-signed:77502
docker.io/harness/redis:6.2.7-alpine
docker.io/harness/ti-service-signed:release-98
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
docker.io/harness/delegate:22.12.77629
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
| ci.ci-manager.affinity | object | `{}` |  |
| ci.ci-manager.nodeSelector | object | `{}` |  |
| ci.ci-manager.tolerations | list | `[]` |  |
| global.airgap | string | `"false"` |  |
| global.ccm | object | `{"enabled":false}` | Enable to install CCM(beta) |
| global.cd.enabled | bool | `false` |  |
| global.cg.enabled | bool | `false` |  |
| global.ci | object | `{"enabled":false}` | Enable to install CI |
| global.ff | object | `{"enabled":false}` | Enable to install FF |
| global.gitops | object | `{"enabled":false}` | Enable to install gitops(beta) |
| global.ha | bool | `true` |  |
| global.imageRegistry | string | `""` | This private Docker image registry will override any registries that are defined in subcharts. |
| global.ingress | object | `{"className":"harness","defaultbackend":{"create":false,"image":{"digest":"","pullPolicy":"IfNotPresent","registry":"k8s.gcr.io","repository":"defaultbackend-amd64","tag":"1.5"}},"enabled":true,"hosts":["myhost.example.com"],"loadBalancerEnabled":false,"loadBalancerIP":"0.0.0.0","nginx":{"controller":{"annotations":{}},"create":false,"image":{"digest":"","pullPolicy":"IfNotPresent","registry":"us.gcr.io","repository":"k8s-artifacts-prod/ingress-nginx/controller","tag":"v1.0.0-alpha.2"},"objects":{"annotations":{}}},"tls":{"enabled":true,"secretName":"harness-cert"}}` | - Set `ingress.enabled` to `true` to create Kubernetes *Ingress* objects for Nginx. |
| global.ingress.defaultbackend.create | bool | `false` | Create will deploy a default backend into your cluster |
| global.ingress.nginx.controller.annotations | object | `{}` | annotations to be addded to ingress Controller |
| global.ingress.nginx.create | bool | `false` | Create Nginx Controller.  True will deploy a controller into your cluster |
| global.ingress.nginx.objects.annotations | object | `{}` | annotations to be added to ingress Objects |
| global.istio | object | `{"enabled":false,"gateway":{"create":true,"port":443,"protocol":"HTTPS"},"hosts":["*"],"strict":false,"tls":{"credentialName":"harness-cert","minProtocolVersion":"TLSV1_2","mode":"SIMPLE"},"virtualService":{"hosts":["myhostname.example.com"]}}` | Istio Ingress Settings |
| global.license.cg | string | `""` |  |
| global.license.ng | string | `""` |  |
| global.loadbalancerURL | string | `"https://myhostname.example.com"` |  |
| global.mongoSSL | bool | `false` |  |
| global.ngcustomdashboard | object | `{"enabled":false}` | Enable to install CDB |
| global.opa | object | `{"enabled":false}` | Enable to install opa(beta) |
| global.saml | object | `{"autoaccept":false}` | Enabled will not send invites to email and autoaccepts |
| global.srm | object | `{"enabled":false}` | Enable to install SRM |
| global.sto | object | `{"enabled":false}` | Enable to install STO |
| global.storageClassName | string | `""` |  |
| ngcustomdashboard.looker.affinity | object | `{}` |  |
| ngcustomdashboard.looker.nodeSelector | object | `{}` |  |
| ngcustomdashboard.looker.tolerations | list | `[]` |  |
| ngcustomdashboard.ng-custom-dashboards.affinity | object | `{}` |  |
| ngcustomdashboard.ng-custom-dashboards.nodeSelector | object | `{}` |  |
| ngcustomdashboard.ng-custom-dashboards.tolerations | list | `[]` |  |
| platform.access-control | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Access control settings (taints, tolerations, and so on) |
| platform.change-data-capture | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | change-data-capture settings (taints, tolerations, and so on) |
| platform.cv-nextgen | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | cv-nextgen settings (taints, tolerations, and so on) |
| platform.delegate-proxy | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | delegate proxy settings (taints, tolerations, and so on) |
| platform.gateway | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | gateway settings (taints, tolerations, and so on) |
| platform.harness-manager | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | harness-manager (taints, tolerations, and so on) |
| platform.le-nextgen | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | le-nextgen (taints, tolerations, and so on) |
| platform.log-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | log-service (taints, tolerations, and so on) |
| platform.minio | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | minio (taints, tolerations, and so on) |
| platform.mongodb.affinity | object | `{}` |  |
| platform.mongodb.nodeSelector | object | `{}` |  |
| platform.mongodb.tolerations | list | `[]` |  |
| platform.next-gen-ui.affinity | object | `{}` |  |
| platform.next-gen-ui.nodeSelector | object | `{}` |  |
| platform.next-gen-ui.tolerations | list | `[]` |  |
| platform.ng-auth-ui.affinity | object | `{}` |  |
| platform.ng-auth-ui.nodeSelector | object | `{}` |  |
| platform.ng-auth-ui.tolerations | list | `[]` |  |
| platform.ng-manager.affinity | object | `{}` |  |
| platform.ng-manager.nodeSelector | object | `{}` |  |
| platform.ng-manager.tolerations | list | `[]` |  |
| platform.pipeline-service.affinity | object | `{}` |  |
| platform.pipeline-service.nodeSelector | object | `{}` |  |
| platform.pipeline-service.tolerations | list | `[]` |  |
| platform.platform-service.affinity | object | `{}` |  |
| platform.platform-service.nodeSelector | object | `{}` |  |
| platform.platform-service.tolerations | list | `[]` |  |
| platform.redis.affinity | object | `{}` |  |
| platform.redis.nodeSelector | object | `{}` |  |
| platform.redis.tolerations | list | `[]` |  |
| platform.scm-service.affinity | object | `{}` |  |
| platform.scm-service.nodeSelector | object | `{}` |  |
| platform.scm-service.tolerations | list | `[]` |  |
| platform.template-service.affinity | object | `{}` |  |
| platform.template-service.nodeSelector | object | `{}` |  |
| platform.template-service.tolerations | list | `[]` |  |
| platform.ti-service.affinity | object | `{}` |  |
| platform.ti-service.nodeSelector | object | `{}` |  |
| platform.ti-service.tolerations | list | `[]` |  |
| platform.timescaledb.affinity | object | `{}` |  |
| platform.timescaledb.nodeSelector | object | `{}` |  |
| platform.timescaledb.tolerations | list | `[]` |  |
| srm.enable-receivers | bool | `false` |  |
| srm.et-collector.affinity | object | `{}` |  |
| srm.et-collector.nodeSelector | object | `{}` |  |
| srm.et-collector.tolerations | list | `[]` |  |
| srm.et-receiver-agent.affinity | object | `{}` |  |
| srm.et-receiver-agent.nodeSelector | object | `{}` |  |
| srm.et-receiver-agent.tolerations | list | `[]` |  |
| srm.et-receiver-decompile.affinity | object | `{}` |  |
| srm.et-receiver-decompile.nodeSelector | object | `{}` |  |
| srm.et-receiver-decompile.tolerations | list | `[]` |  |
| srm.et-receiver-hit.affinity | object | `{}` |  |
| srm.et-receiver-hit.nodeSelector | object | `{}` |  |
| srm.et-receiver-hit.tolerations | list | `[]` |  |
| srm.et-receiver-sql.affinity | object | `{}` |  |
| srm.et-receiver-sql.nodeSelector | object | `{}` |  |
| srm.et-receiver-sql.tolerations | list | `[]` |  |
| srm.et-service.affinity | object | `{}` |  |
| srm.et-service.nodeSelector | object | `{}` |  |
| srm.et-service.tolerations | list | `[]` |  |
| sto.sto-core.affinity | object | `{}` |  |
| sto.sto-core.autoscaling.enabled | bool | `false` |  |
| sto.sto-core.nodeSelector | object | `{}` |  |
| sto.sto-core.tolerations | list | `[]` |  |
| sto.sto-manager.affinity | object | `{}` |  |
| sto.sto-manager.autoscaling.enabled | bool | `false` |  |
| sto.sto-manager.nodeSelector | object | `{}` |  |
| sto.sto-manager.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
