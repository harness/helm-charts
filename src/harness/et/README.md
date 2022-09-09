# et

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://harness.github.io/helm-et-collector | et-collector | 0.1.x |
| https://harness.github.io/helm-et-receiver | et-receiver-hit(et-receiver) | 0.1.x |
| https://harness.github.io/helm-et-receiver | et-receiver-decompile(et-receiver) | 0.1.x |
| https://harness.github.io/helm-et-receiver | et-receiver-sql(et-receiver) | 0.1.x |
| https://harness.github.io/helm-et-receiver | et-receiver-agent(et-receiver) | 0.1.x |
| https://harness.github.io/helm-et-service | et-service | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| enable-receivers | bool | `false` |  |
| et-collector.autoscaling.enabled | bool | `false` |  |
| et-collector.image.tag | string | `"5.0.7"` |  |
| et-receiver-agent.image.tag | string | `"5.3.0"` |  |
| et-receiver-decompile.image.tag | string | `"5.3.0"` |  |
| et-receiver-hit.image.tag | string | `"5.3.0"` |  |
| et-receiver-sql.image.tag | string | `"5.3.0"` |  |
| et-service.autoscaling.enabled | bool | `false` |  |
| et-service.image.tag | string | `"5.3.0"` |  |

