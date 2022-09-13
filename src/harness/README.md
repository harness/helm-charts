## Harness Helm Charts

Helm Chart for deploying Harness.

![Version: 0.2.35](https://img.shields.io/badge/Version-0.2.35-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.76620](https://img.shields.io/badge/AppVersion-1.0.76620-informational?style=flat-square)

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

  # -- Enable to install STO
  sto:
    enabled: false

  # -- Enable to install Error Tracking
  et:
    enabled: false

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
| global.airgap | bool | `false` | Enable for complete airgap environment |
| global.et | object | `{"enabled":false}` | Enable to install Error Tracking |
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
| global.sto | object | `{"enabled":false}` | Enable to install STO |
| global.storageClassName | string | `""` |  |

