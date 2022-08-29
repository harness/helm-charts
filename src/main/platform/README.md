# platform

![Version: 0.1.4](https://img.shields.io/badge/Version-0.1.4-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | common | 1.16.1 |
| https://charts.bitnami.com/bitnami | minio | 11.9.1 |
| https://charts.bitnami.com/bitnami | mongodb | 13.1.2 |
| https://harness.github.io/helm-access-control | access-control | 0.2.x |
| https://harness.github.io/helm-change-data-capture | change-data-capture | 0.2.x |
| https://harness.github.io/helm-cv-nextgen | cv-nextgen | 0.2.x |
| https://harness.github.io/helm-delegate-proxy | delegate-proxy | 0.2.x |
| https://harness.github.io/helm-gateway | gateway | 0.2.x |
| https://harness.github.io/helm-harness-manager | harness-manager | 0.2.x |
| https://harness.github.io/helm-harness-secrets | harness-secrets | 0.2.x |
| https://harness.github.io/helm-le-nextgen | le-nextgen | 0.2.x |
| https://harness.github.io/helm-log-service | log-service | 0.2.x |
| https://harness.github.io/helm-next-gen-ui | next-gen-ui | 0.2.x |
| https://harness.github.io/helm-ng-auth-ui | ng-auth-ui | 0.2.x |
| https://harness.github.io/helm-ng-manager | ng-manager | 0.2.x |
| https://harness.github.io/helm-pipeline-service | pipeline-service | 0.2.x |
| https://harness.github.io/helm-platform-service | platform-service | 0.2.x |
| https://harness.github.io/helm-redis | redis | 0.2.x |
| https://harness.github.io/helm-scm-service | scm-service | 0.2.x |
| https://harness.github.io/helm-template-service | template-service | 0.2.x |
| https://harness.github.io/helm-ti-service | ti-service | 0.2.x |
| https://harness.github.io/helm-timescaledb | timescaledb | 0.2.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ci.enabled | bool | `true` | Enable to install CI |
| global.airgap | bool | `false` | Enable for complete airgap environment |
| global.ha | bool | `true` |  |
| global.imageRegistry | string | `""` | Global Docker image registry |
| global.loadbalancerURL | string | `""` | Fully qualified URL of your loadbalancer (ex: https://www.foo.com) |
| global.mongoSSL | bool | `false` |  |
| global.storageClassName | string | `""` |  |
| istio.enabled | bool | `true` |  |
| istio.gateway.create | bool | `true` | Enable to create istio-system gateway |
| istio.gateway.port | int | `443` |  |
| istio.gateway.protocol | string | `"HTTPS"` |  |
| istio.hosts[0] | string | `"*"` |  |
| istio.tls.credentialName | string | `nil` |  |
| istio.tls.minProtocolVersion | string | `"TLSV1_2"` |  |
| istio.tls.mode | string | `"SIMPLE"` |  |
| istio.virtualService.gateways[0] | string | `""` |  |
| istio.virtualService.hosts[0] | string | `""` |  |
| platform.harness-manager | object | `{"features":""}` | Feature list to enable within platform.  Contact Harness for value |
| sto.enabled | bool | `true` |  |

