## Harness Helm Charts

This readme provides the basic instructions you need to deploy Harness using a Helm chart. The Helm chart deploys Harness in a production configuration.

Helm Chart for deploying Harness.

![Version: 0.2.82](https://img.shields.io/badge/Version-0.2.82-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.77125](https://img.shields.io/badge/AppVersion-1.0.77125-informational?style=flat-square)

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

```

```

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

```
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.airgap | string | `"false"` |  |
| global.ccm | object | `{"enabled":false}` | Enable to install CCM(beta) |
| global.cd.enabled | bool | `false` |  |
| global.ci | object | `{"enabled":false}` | Enable to install CI |
| global.ff | object | `{"enabled":false}` | Enable to install FF |
| global.ha | bool | `true` |  |
| global.imageRegistry | string | `""` | This private Docker image registry will override any registries that are defined in subcharts. |
| global.ingress | object | `{"className":"harness","defaultbackend":{"create":false},"enabled":true,"hosts":["myhost.example.com"],"loadBalancerEnabled":false,"loadBalancerIP":"0.0.0.0","nginx":{"controller":{"annotations":{}},"create":false,"objects":{"annotations":{}}},"tls":{"enabled":true,"secretName":"harness-cert"}}` | - Set `ingress.enabled` to `true` to create Kubernetes *Ingress* objects for Nginx. |
| global.ingress.defaultbackend.create | bool | `false` | Create will deploy a default backend into your cluster |
| global.ingress.nginx.controller.annotations | object | `{}` | annotations to be addded to ingress Controller |
| global.ingress.nginx.create | bool | `false` | Create Nginx Controller.  True will deploy a controller into your cluster |
| global.ingress.nginx.objects.annotations | object | `{}` | annotations to be added to ingress Objects |
| global.istio | object | `{"enabled":false,"gateway":{"create":true,"port":443,"protocol":"HTTPS"},"hosts":["*"],"strict":false,"tls":{"credentialName":"harness-cert","minProtocolVersion":"TLSV1_2","mode":"SIMPLE"},"virtualService":{"hosts":["myhostname.example.com"]}}` | Istio Ingress Settings |
| global.loadbalancerURL | string | `"https://myhostname.example.com"` |  |
| global.mongoSSL | bool | `false` |  |
| global.ngcustomdashboard | object | `{"enabled":false}` | Enable to install CDB |
| global.saml | object | `{"autoaccept":false}` | Enabled will not send invites to email and autoaccepts |
| global.srm | object | `{"enabled":false}` | Enable to install SRM |
| global.sto | object | `{"enabled":false}` | Enable to install STO |
| global.storageClassName | string | `""` |  |
| harness.ci.ci-manager.affinity | object | `{}` |  |
| harness.ci.ci-manager.nodeSelector | object | `{}` |  |
| harness.ci.ci-manager.tolerations | list | `[]` |  |
| harness.ngcustomdashboard.looker.affinity | object | `{}` |  |
| harness.ngcustomdashboard.looker.nodeSelector | object | `{}` |  |
| harness.ngcustomdashboard.looker.tolerations | list | `[]` |  |
| harness.ngcustomdashboard.ng-custom-dashboards.affinity | object | `{}` |  |
| harness.ngcustomdashboard.ng-custom-dashboards.nodeSelector | object | `{}` |  |
| harness.ngcustomdashboard.ng-custom-dashboards.tolerations | list | `[]` |  |
| harness.platform.access-control | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | Access control settings (taints, tolerations, and so on) |
| harness.platform.change-data-capture | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | change-data-capture settings (taints, tolerations, and so on) |
| harness.platform.cv-nextgen | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | cv-nextgen settings (taints, tolerations, and so on) |
| harness.platform.delegate-proxy | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | delegate proxy settings (taints, tolerations, and so on) |
| harness.platform.gateway | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | gateway settings (taints, tolerations, and so on) |
| harness.platform.harness-manager | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | harness-manager (taints, tolerations, and so on) |
| harness.platform.le-nextgen | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | le-nextgen (taints, tolerations, and so on) |
| harness.platform.log-service | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | log-service (taints, tolerations, and so on) |
| harness.platform.minio | object | `{"affinity":{},"nodeSelector":{},"tolerations":[]}` | minio (taints, tolerations, and so on) |
| harness.platform.mongodb.affinity | object | `{}` |  |
| harness.platform.mongodb.nodeSelector | object | `{}` |  |
| harness.platform.mongodb.tolerations | list | `[]` |  |
| harness.platform.next-gen-ui.affinity | object | `{}` |  |
| harness.platform.next-gen-ui.nodeSelector | object | `{}` |  |
| harness.platform.next-gen-ui.tolerations | list | `[]` |  |
| harness.platform.ng-auth-ui.affinity | object | `{}` |  |
| harness.platform.ng-auth-ui.nodeSelector | object | `{}` |  |
| harness.platform.ng-auth-ui.tolerations | list | `[]` |  |
| harness.platform.ng-manager.affinity | object | `{}` |  |
| harness.platform.ng-manager.nodeSelector | object | `{}` |  |
| harness.platform.ng-manager.tolerations | list | `[]` |  |
| harness.platform.pipeline-service.affinity | object | `{}` |  |
| harness.platform.pipeline-service.nodeSelector | object | `{}` |  |
| harness.platform.pipeline-service.tolerations | list | `[]` |  |
| harness.platform.platform-service.affinity | object | `{}` |  |
| harness.platform.platform-service.nodeSelector | object | `{}` |  |
| harness.platform.platform-service.tolerations | list | `[]` |  |
| harness.platform.redis.affinity | object | `{}` |  |
| harness.platform.redis.nodeSelector | object | `{}` |  |
| harness.platform.redis.tolerations | list | `[]` |  |
| harness.platform.scm-service.affinity | object | `{}` |  |
| harness.platform.scm-service.nodeSelector | object | `{}` |  |
| harness.platform.scm-service.tolerations | list | `[]` |  |
| harness.platform.template-service.affinity | object | `{}` |  |
| harness.platform.template-service.nodeSelector | object | `{}` |  |
| harness.platform.template-service.tolerations | list | `[]` |  |
| harness.platform.ti-service.affinity | object | `{}` |  |
| harness.platform.ti-service.nodeSelector | object | `{}` |  |
| harness.platform.ti-service.tolerations | list | `[]` |  |
| harness.platform.timescaledb.affinity | object | `{}` |  |
| harness.platform.timescaledb.nodeSelector | object | `{}` |  |
| harness.platform.timescaledb.tolerations | list | `[]` |  |
| harness.srm.enable-receivers | bool | `false` |  |
| harness.srm.et-collector.affinity | object | `{}` |  |
| harness.srm.et-collector.nodeSelector | object | `{}` |  |
| harness.srm.et-collector.tolerations | list | `[]` |  |
| harness.srm.et-receiver-agent.affinity | object | `{}` |  |
| harness.srm.et-receiver-agent.nodeSelector | object | `{}` |  |
| harness.srm.et-receiver-agent.tolerations | list | `[]` |  |
| harness.srm.et-receiver-decompile.affinity | object | `{}` |  |
| harness.srm.et-receiver-decompile.nodeSelector | object | `{}` |  |
| harness.srm.et-receiver-decompile.tolerations | list | `[]` |  |
| harness.srm.et-receiver-hit.affinity | object | `{}` |  |
| harness.srm.et-receiver-hit.nodeSelector | object | `{}` |  |
| harness.srm.et-receiver-hit.tolerations | list | `[]` |  |
| harness.srm.et-receiver-sql.affinity | object | `{}` |  |
| harness.srm.et-receiver-sql.nodeSelector | object | `{}` |  |
| harness.srm.et-receiver-sql.tolerations | list | `[]` |  |
| harness.srm.et-service.affinity | object | `{}` |  |
| harness.srm.et-service.nodeSelector | object | `{}` |  |
| harness.srm.et-service.tolerations | list | `[]` |  |
| harness.sto.sto-core.affinity | object | `{}` |  |
| harness.sto.sto-core.nodeSelector | object | `{}` |  |
| harness.sto.sto-core.tolerations | list | `[]` |  |
| harness.sto.sto-manager.affinity | object | `{}` |  |
| harness.sto.sto-manager.nodeSelector | object | `{}` |  |
| harness.sto.sto-manager.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
