# platform

![Version: 0.1.6](https://img.shields.io/badge/Version-0.1.6-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Kubernetes

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://charts.bitnami.com/bitnami | minio | 11.9.1 |
| https://charts.bitnami.com/bitnami | mongodb | 13.1.2 |
| https://harness.github.io/helm-access-control | access-control | 0.2.x |
| https://harness.github.io/helm-change-data-capture | change-data-capture | 0.2.x |
| https://harness.github.io/helm-cv-nextgen | cv-nextgen | 0.2.x |
| https://harness.github.io/helm-delegate-proxy | delegate-proxy | 0.2.x |
| https://harness.github.io/helm-gateway | gateway | 0.2.x |
| https://harness.github.io/helm-gitops | gitops | 0.1.x |
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
| access-control.appLogLevel | string | `"INFO"` |  |
| access-control.autoscaling.enabled | bool | `false` |  |
| access-control.image.tag | string | `"77002"` |  |
| access-control.java.memory | string | `"512m"` |  |
| access-control.replicaCount | int | `1` |  |
| access-control.resources.limits.cpu | float | `0.5` |  |
| access-control.resources.limits.memory | string | `"8192Mi"` |  |
| access-control.resources.requests.cpu | float | `0.5` |  |
| access-control.resources.requests.memory | string | `"512Mi"` |  |
| access-control.slackWebhookURL | string | `""` |  |
| change-data-capture.appLogLevel | string | `"INFO"` |  |
| change-data-capture.autoscaling.enabled | bool | `false` |  |
| change-data-capture.image.tag | string | `"77125"` |  |
| change-data-capture.java.memory | int | `2048` |  |
| change-data-capture.replicaCount | int | `1` |  |
| change-data-capture.resources.limits.cpu | int | `1` |  |
| change-data-capture.resources.limits.memory | string | `"2880Mi"` |  |
| change-data-capture.resources.requests.cpu | int | `1` |  |
| change-data-capture.resources.requests.memory | string | `"2880Mi"` |  |
| cv-nextgen.appLogLevel | string | `"INFO"` |  |
| cv-nextgen.autoscaling.enabled | bool | `false` |  |
| cv-nextgen.image.tag | string | `"77125"` |  |
| cv-nextgen.java.memory | int | `4096` |  |
| cv-nextgen.replicaCount | int | `1` |  |
| cv-nextgen.resources.limits.cpu | int | `1` |  |
| cv-nextgen.resources.limits.memory | string | `"6144Mi"` |  |
| cv-nextgen.resources.requests.cpu | int | `1` |  |
| cv-nextgen.resources.requests.memory | string | `"6144Mi"` |  |
| delegate-proxy.image.tag | string | `"77036"` |  |
| delegate-proxy.replicaCount | int | `1` |  |
| delegate-proxy.resources.limits.cpu | string | `"200m"` |  |
| delegate-proxy.resources.limits.memory | string | `"100Mi"` |  |
| delegate-proxy.resources.requests.cpu | string | `"200m"` |  |
| delegate-proxy.resources.requests.memory | string | `"100Mi"` |  |
| gateway.autoscaling.enabled | bool | `false` |  |
| gateway.image.tag | string | `"200091"` |  |
| gateway.java.memory | int | `512` |  |
| gateway.replicaCount | int | `1` |  |
| gateway.resources.limits.cpu | float | `0.4` |  |
| gateway.resources.limits.memory | string | `"1024Mi"` |  |
| gateway.resources.requests.cpu | float | `0.2` |  |
| gateway.resources.requests.memory | string | `"512Mi"` |  |
| harness-manager.autoscaling.enabled | bool | `false` |  |
| harness-manager.delegate_docker_image.image.repository | string | `"harness/delegate"` |  |
| harness-manager.delegate_docker_image.image.tag | string | `"latest"` |  |
| harness-manager.external_graphql_rate_limit | string | `"500"` |  |
| harness-manager.image.tag | string | `"77125"` |  |
| harness-manager.java.memory | string | `"2048"` |  |
| harness-manager.replicaCount | int | `1` |  |
| harness-manager.resources.limits.cpu | int | `2` |  |
| harness-manager.resources.limits.memory | string | `"8192Mi"` |  |
| harness-manager.resources.requests.cpu | int | `2` |  |
| harness-manager.resources.requests.memory | string | `"3000Mi"` |  |
| harness-manager.version | string | `"1.0.77125"` |  |
| le-nextgen.autoscaling.enabled | bool | `false` |  |
| le-nextgen.image.tag | string | `"67101"` |  |
| le-nextgen.replicaCount | int | `1` |  |
| le-nextgen.resources.limits.cpu | int | `1` |  |
| le-nextgen.resources.limits.memory | string | `"6144Mi"` |  |
| le-nextgen.resources.requests.cpu | int | `1` |  |
| le-nextgen.resources.requests.memory | string | `"6144Mi"` |  |
| log-service.autoscaling.enabled | bool | `false` |  |
| log-service.image.tag | string | `"release-18"` |  |
| log-service.replicaCount | int | `1` |  |
| log-service.resources.limits.cpu | int | `1` |  |
| log-service.resources.limits.memory | string | `"3072Mi"` |  |
| log-service.resources.requests.cpu | int | `1` |  |
| log-service.resources.requests.memory | string | `"3072Mi"` |  |
| minio.defaultBuckets | string | `"logs"` |  |
| minio.fullnameOverride | string | `"minio"` |  |
| minio.mode | string | `"standalone"` |  |
| mongodb.arbiter.enabled | bool | `true` |  |
| mongodb.architecture | string | `"replicaset"` |  |
| mongodb.auth.rootUser | string | `"admin"` |  |
| mongodb.fullnameOverride | string | `"mongodb-replicaset-chart"` |  |
| mongodb.image.registry | string | `"docker.io"` |  |
| mongodb.image.repository | string | `"bitnami/mongodb"` |  |
| mongodb.image.tag | string | `"4.2.19"` |  |
| mongodb.persistence.size | string | `"200Gi"` |  |
| mongodb.podLabels.app | string | `"mongodb-replicaset"` |  |
| mongodb.replicaCount | int | `3` |  |
| mongodb.resources.limits.cpu | int | `4` |  |
| mongodb.resources.limits.memory | string | `"8192Mi"` |  |
| mongodb.resources.requests.cpu | int | `4` |  |
| mongodb.resources.requests.memory | string | `"8192Mi"` |  |
| mongodb.service.nameOverride | string | `"mongodb-replicaset-chart"` |  |
| next-gen-ui.autoscaling.enabled | bool | `false` |  |
| next-gen-ui.image.tag | string | `"0.323.11"` |  |
| next-gen-ui.replicaCount | int | `1` |  |
| next-gen-ui.resources.limits.cpu | float | `0.2` |  |
| next-gen-ui.resources.limits.memory | string | `"200Mi"` |  |
| next-gen-ui.resources.requests.cpu | float | `0.2` |  |
| next-gen-ui.resources.requests.memory | string | `"200Mi"` |  |
| ng-auth-ui.autoscaling.enabled | bool | `false` |  |
| ng-auth-ui.image.tag | string | `"0.42.2"` |  |
| ng-auth-ui.replicaCount | int | `1` |  |
| ng-auth-ui.resources.limits.cpu | float | `0.5` |  |
| ng-auth-ui.resources.limits.memory | string | `"512Mi"` |  |
| ng-auth-ui.resources.requests.cpu | float | `0.5` |  |
| ng-auth-ui.resources.requests.memory | string | `"512Mi"` |  |
| ng-manager.appLogLevel | string | `"INFO"` |  |
| ng-manager.autoscaling.enabled | bool | `false` |  |
| ng-manager.image.tag | string | `"77125"` |  |
| ng-manager.java.memory | string | `"4096m"` |  |
| ng-manager.replicaCount | int | `1` |  |
| ng-manager.resources.limits.cpu | int | `2` |  |
| ng-manager.resources.limits.memory | string | `"8192Mi"` |  |
| ng-manager.resources.requests.cpu | int | `2` |  |
| ng-manager.resources.requests.memory | string | `"200Mi"` |  |
| pipeline-service.appLogLevel | string | `"INFO"` |  |
| pipeline-service.autoscaling.enabled | bool | `false` |  |
| pipeline-service.image.tag | string | `"1.11.1"` |  |
| pipeline-service.java.memory | string | `"4096m"` |  |
| pipeline-service.replicaCount | int | `1` |  |
| pipeline-service.resources.limits.cpu | int | `1` |  |
| pipeline-service.resources.limits.memory | string | `"6144Mi"` |  |
| pipeline-service.resources.requests.cpu | int | `1` |  |
| pipeline-service.resources.requests.memory | string | `"6144Mi"` |  |
| platform-service.appLogLevel | string | `"INFO"` |  |
| platform-service.autoscaling.enabled | bool | `false` |  |
| platform-service.image.tag | string | `"77201"` |  |
| platform-service.java.memory | string | `"3072m"` |  |
| platform-service.replicaCount | int | `1` |  |
| platform-service.resources.limits.cpu | float | `0.5` |  |
| platform-service.resources.limits.memory | string | `"8192Mi"` |  |
| platform-service.resources.requests.cpu | float | `0.5` |  |
| platform-service.resources.requests.memory | string | `"512Mi"` |  |
| redis.autoscaling.enabled | bool | `false` |  |
| redis.initContainers.config_init.image.tag | string | `"6.2.7-alpine"` |  |
| redis.redis.image.pullPolicy | string | `"IfNotPresent"` |  |
| redis.redis.image.repository | string | `"harness/redis"` |  |
| redis.redis.image.tag | string | `"6.2.7-alpine"` |  |
| redis.redis.resources.limits.cpu | float | `0.1` |  |
| redis.redis.resources.limits.memory | string | `"200Mi"` |  |
| redis.redis.resources.requests.cpu | float | `0.1` |  |
| redis.redis.resources.requests.memory | string | `"200Mi"` |  |
| redis.replicaCount | int | `3` |  |
| redis.sentinel.image.pullPolicy | string | `"IfNotPresent"` |  |
| redis.sentinel.image.repository | string | `"harness/redis"` |  |
| redis.sentinel.image.tag | string | `"6.2.7-alpine"` |  |
| redis.sentinel.resources.limits.cpu | string | `"100m"` |  |
| redis.sentinel.resources.limits.memory | string | `"200Mi"` |  |
| redis.sentinel.resources.requests.cpu | string | `"100m"` |  |
| redis.sentinel.resources.requests.memory | string | `"200Mi"` |  |
| redis.volumeClaimTemplate.resources.requests.storage | string | `"10Gi"` |  |
| scm-service.appLogLevel | string | `"INFO"` |  |
| scm-service.autoscaling.enabled | bool | `false` |  |
| scm-service.image.tag | string | `"release-87-ubi"` |  |
| scm-service.replicaCount | int | `1` |  |
| scm-service.resources.limits.cpu | float | `0.1` |  |
| scm-service.resources.limits.memory | string | `"512Mi"` |  |
| scm-service.resources.requests.cpu | float | `0.1` |  |
| scm-service.resources.requests.memory | string | `"512Mi"` |  |
| template-service.appLogLevel | string | `"INFO"` |  |
| template-service.autoscaling.enabled | bool | `false` |  |
| template-service.image.tag | string | `"77125"` |  |
| template-service.java.memory | string | `"1024m"` |  |
| template-service.replicaCount | int | `1` |  |
| template-service.resources.limits.cpu | int | `1` |  |
| template-service.resources.limits.memory | string | `"1400Mi"` |  |
| template-service.resources.requests.cpu | int | `1` |  |
| template-service.resources.requests.memory | string | `"1400Mi"` |  |
| ti-service.appLogLevel | string | `"INFO"` |  |
| ti-service.autoscaling.enabled | bool | `false` |  |
| ti-service.image.tag | string | `"release-87"` |  |
| ti-service.jobresources.limits.cpu | int | `1` |  |
| ti-service.jobresources.limits.memory | string | `"3072Mi"` |  |
| ti-service.jobresources.requests.cpu | int | `1` |  |
| ti-service.jobresources.requests.memory | string | `"3072Mi"` |  |
| ti-service.jobs.migrate.image.tag | string | `"release-87"` |  |
| ti-service.replicaCount | int | `1` |  |
| ti-service.resources.limits.cpu | int | `1` |  |
| ti-service.resources.limits.memory | string | `"3072Mi"` |  |
| ti-service.resources.requests.cpu | int | `1` |  |
| ti-service.resources.requests.memory | string | `"3072Mi"` |  |
| timescaledb.autoscaling.enabled | bool | `false` |  |
| timescaledb.enabled | bool | `true` |  |
| timescaledb.image.tag | string | `"pg13-ts2.6-oss-latest"` |  |
| timescaledb.replicaCount | int | `1` |  |
| timescaledb.resources.limits.cpu | int | `1` |  |
| timescaledb.resources.limits.memory | string | `"2048Mi"` |  |
| timescaledb.resources.requests.cpu | int | `1` |  |
| timescaledb.resources.requests.memory | string | `"2048Mi"` |  |
| timescaledb.storage.capacity | string | `"100Gi"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
