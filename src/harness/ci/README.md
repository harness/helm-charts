# ci

![Version: 0.1.2](https://img.shields.io/badge/Version-0.1.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://harness.github.io/helm-ci-manager | ci-manager | 0.2.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ci-manager.image.tag | string | `"400"` |  |
| helm-harness-secrets.minio.password | string | `""` |  |
| helm-harness-secrets.minio.user | string | `""` |  |
| helm-harness-secrets.mongodb.password | string | `""` |  |
| helm-harness-secrets.timescaledb.adminPassword | string | `""` |  |
| helm-harness-secrets.timescaledb.postgresPassword | string | `""` |  |
| helm-harness-secrets.timescaledb.standbyPassword | string | `""` |  |
| istio.enabled | bool | `false` |  |

