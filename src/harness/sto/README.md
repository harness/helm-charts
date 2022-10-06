# sto

![Version: 0.1.3](https://img.shields.io/badge/Version-0.1.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://harness.github.io/helm-sto-core | sto-core | 0.2.x |
| https://harness.github.io/helm-sto-manager | sto-manager | 0.2.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| sto-core.autoscaling.enabled | bool | `false` |  |
| sto-core.image.tag | string | `"v1.7.2"` |  |
| sto-manager.autoscaling.enabled | bool | `false` |  |
| sto-manager.image.tag | string | `"76700-000"` |  |

