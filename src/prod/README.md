# harness-prod

![Version: 0.2.16](https://img.shields.io/badge/Version-0.2.16-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.76019](https://img.shields.io/badge/AppVersion-1.0.76019-informational?style=flat-square)

Helm Chart for deploying Harness in Prod configuration

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://ci | ci | 0.1.x |
| file://platform | platform | 0.1.x |
| file://sto | sto | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ci.enabled | bool | `true` | Enable to install CI |
| global.airgap | bool | `false` | Enable for complete airgap environment |
| global.ha | bool | `false` |  |
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
| platform.features | string | `""` | Feature list to enable within platform.  Contact Harness for value |
| sto.enabled | bool | `true` |  |

