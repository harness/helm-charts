## Harness Platform Chart

Helm chart for Harness Platform

![Version: 0.9.0](https://img.shields.io/badge/Version-0.9.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.1](https://img.shields.io/badge/AppVersion-1.16.1-informational?style=flat-square)

## Usage

Use the following dependency to add this chart repository to your Helm installation:

```
dependencies:
    - name: ccm
      repository: https://harness.github.io/helm-platform
      version: 0.9.0
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| access-control.appLogLevel | string | `"INFO"` |  |
| access-control.autoscaling.enabled | bool | `false` |  |
| access-control.image.tag | string | `"79004"` |  |
| access-control.java.memory | string | `"512m"` |  |
| access-control.replicaCount | int | `1` |  |
| access-control.resources.limits.memory | string | `"8192Mi"` |  |
| access-control.resources.requests.cpu | float | `0.5` |  |
| access-control.resources.requests.memory | string | `"512Mi"` |  |
| access-control.slackWebhookURL | string | `""` |  |
| change-data-capture.appLogLevel | string | `"INFO"` |  |
| change-data-capture.autoscaling.enabled | bool | `false` |  |
| change-data-capture.image.tag | string | `"79421"` |  |
| change-data-capture.java.memory | int | `2048` |  |
| change-data-capture.replicaCount | int | `1` |  |
| change-data-capture.resources.limits.memory | string | `"2880Mi"` |  |
| change-data-capture.resources.requests.cpu | int | `1` |  |
| change-data-capture.resources.requests.memory | string | `"2880Mi"` |  |
| cv-nextgen.appLogLevel | string | `"INFO"` |  |
| cv-nextgen.autoscaling.enabled | bool | `false` |  |
| cv-nextgen.image.tag | string | `"79421"` |  |
| cv-nextgen.java.memory | int | `4096` |  |
| cv-nextgen.replicaCount | int | `1` |  |
| cv-nextgen.resources.limits.memory | string | `"6144Mi"` |  |
| cv-nextgen.resources.requests.cpu | int | `1` |  |
| cv-nextgen.resources.requests.memory | string | `"6144Mi"` |  |
| delegate-proxy.image.tag | string | `"79310"` |  |
| delegate-proxy.replicaCount | int | `1` |  |
| delegate-proxy.resources.limits.memory | string | `"100Mi"` |  |
| delegate-proxy.resources.requests.cpu | string | `"200m"` |  |
| delegate-proxy.resources.requests.memory | string | `"100Mi"` |  |
| gateway.autoscaling.enabled | bool | `false` |  |
| gateway.image.tag | string | `"11002"` |  |
| gateway.java.memory | int | `512` |  |
| gateway.replicaCount | int | `1` |  |
| gateway.resources.limits.memory | string | `"1024Mi"` |  |
| gateway.resources.requests.cpu | float | `0.2` |  |
| gateway.resources.requests.memory | string | `"512Mi"` |  |
| global.cg.enabled | bool | `true` |  |
| global.database.mongo.extraArgs | string | `""` |  |
| global.database.mongo.hosts | list | `[]` | provide default values if mongo.installed is set to false |
| global.database.mongo.installed | bool | `true` |  |
| global.database.mongo.passwordKey | string | `""` |  |
| global.database.mongo.protocol | string | `"mongodb"` |  |
| global.database.mongo.secretName | string | `""` |  |
| global.database.mongo.userKey | string | `""` |  |
| global.database.postgres.extraArgs | string | `""` |  |
| global.database.postgres.hosts[0] | string | `"postgres:5432"` |  |
| global.database.postgres.installed | bool | `true` |  |
| global.database.postgres.passwordKey | string | `""` |  |
| global.database.postgres.protocol | string | `"postgres"` |  |
| global.database.postgres.secretName | string | `""` |  |
| global.database.postgres.userKey | string | `""` |  |
| global.database.redis.extraArgs | string | `""` |  |
| global.database.redis.hosts | list | `["redis-sentinel-harness-announce-0:26379","redis-sentinel-harness-announce-1:26379","redis-sentinel-harness-announce-2:26379"]` | provide default values if redis.installed is set to false |
| global.database.redis.installed | bool | `true` |  |
| global.database.redis.passwordKey | string | `"redis-password"` |  |
| global.database.redis.protocol | string | `"redis"` |  |
| global.database.redis.secretName | string | `"redis-secret"` |  |
| global.database.redis.userKey | string | `"redis-user"` |  |
| global.database.timescaledb.certKey | string | `""` |  |
| global.database.timescaledb.certName | string | `""` |  |
| global.database.timescaledb.extraArgs | string | `""` |  |
| global.database.timescaledb.hosts | list | `["timescaledb-single-chart:5432"]` | provide default values if mongo.installed is set to false |
| global.database.timescaledb.installed | bool | `true` |  |
| global.database.timescaledb.passwordKey | string | `""` |  |
| global.database.timescaledb.protocol | string | `"jdbc:postgresql"` |  |
| global.database.timescaledb.secretName | string | `""` |  |
| global.database.timescaledb.sslEnabled | bool | `false` |  |
| global.database.timescaledb.userKey | string | `""` |  |
| global.kubeVersion | string | `""` |  |
| global.ng.enabled | bool | `true` |  |
| harness-manager.autoscaling.enabled | bool | `false` |  |
| harness-manager.delegate_docker_image.image.repository | string | `"harness/delegate"` |  |
| harness-manager.delegate_docker_image.image.tag | string | `"latest"` |  |
| harness-manager.external_graphql_rate_limit | string | `"500"` |  |
| harness-manager.image.tag | string | `"79421"` |  |
| harness-manager.immutable_delegate_docker_image.image.tag | string | `"23.05.79310"` |  |
| harness-manager.java.memory | string | `"2048"` |  |
| harness-manager.replicaCount | int | `1` |  |
| harness-manager.resources.limits.memory | string | `"8192Mi"` |  |
| harness-manager.resources.requests.cpu | int | `2` |  |
| harness-manager.resources.requests.memory | string | `"3000Mi"` |  |
| harness-manager.version | string | `"1.0.79421"` |  |
| harness-secrets.enabled | bool | `true` |  |
| le-nextgen.autoscaling.enabled | bool | `false` |  |
| le-nextgen.image.tag | string | `"67902"` |  |
| le-nextgen.replicaCount | int | `1` |  |
| le-nextgen.resources.limits.memory | string | `"6144Mi"` |  |
| le-nextgen.resources.requests.cpu | int | `1` |  |
| le-nextgen.resources.requests.memory | string | `"6144Mi"` |  |
| log-service.autoscaling.enabled | bool | `false` |  |
| log-service.image.tag | string | `"release-65-ubi"` |  |
| log-service.replicaCount | int | `1` |  |
| log-service.resources.limits.memory | string | `"3072Mi"` |  |
| log-service.resources.requests.cpu | int | `1` |  |
| log-service.resources.requests.memory | string | `"3072Mi"` |  |
| minio.auth.existingSecret | string | `"minio"` |  |
| minio.defaultBuckets | string | `"logs"` |  |
| minio.fullnameOverride | string | `"minio"` |  |
| minio.image.tag | string | `"2023.5.18-debian-11-r2"` |  |
| minio.mode | string | `"standalone"` |  |
| mongodb.arbiter.enabled | bool | `true` |  |
| mongodb.architecture | string | `"replicaset"` |  |
| mongodb.auth.existingSecret | string | `"mongodb-replicaset-chart"` |  |
| mongodb.auth.rootUser | string | `"admin"` |  |
| mongodb.fullnameOverride | string | `"mongodb-replicaset-chart"` |  |
| mongodb.image.registry | string | `"docker.io"` |  |
| mongodb.image.repository | string | `"harness/mongo"` |  |
| mongodb.image.tag | string | `"4.4.22"` |  |
| mongodb.persistence.size | string | `"200Gi"` |  |
| mongodb.podLabels.app | string | `"mongodb-replicaset"` |  |
| mongodb.replicaCount | int | `3` |  |
| mongodb.resources.limits.memory | string | `"8192Mi"` |  |
| mongodb.resources.requests.cpu | int | `4` |  |
| mongodb.resources.requests.memory | string | `"8192Mi"` |  |
| mongodb.service.nameOverride | string | `"mongodb-replicaset-chart"` |  |
| next-gen-ui.autoscaling.enabled | bool | `false` |  |
| next-gen-ui.image.tag | string | `"0.349.16"` |  |
| next-gen-ui.replicaCount | int | `1` |  |
| next-gen-ui.resources.limits.memory | string | `"200Mi"` |  |
| next-gen-ui.resources.requests.cpu | float | `0.2` |  |
| next-gen-ui.resources.requests.memory | string | `"200Mi"` |  |
| ng-auth-ui.autoscaling.enabled | bool | `false` |  |
| ng-auth-ui.image.tag | string | `"1.7.0"` |  |
| ng-auth-ui.replicaCount | int | `1` |  |
| ng-auth-ui.resources.limits.memory | string | `"512Mi"` |  |
| ng-auth-ui.resources.requests.cpu | float | `0.5` |  |
| ng-auth-ui.resources.requests.memory | string | `"512Mi"` |  |
| ng-manager.appLogLevel | string | `"INFO"` |  |
| ng-manager.autoscaling.enabled | bool | `false` |  |
| ng-manager.image.tag | string | `"79421"` |  |
| ng-manager.java.memory | string | `"4096m"` |  |
| ng-manager.replicaCount | int | `1` |  |
| ng-manager.resources.limits.memory | string | `"8192Mi"` |  |
| ng-manager.resources.requests.cpu | int | `2` |  |
| ng-manager.resources.requests.memory | string | `"200Mi"` |  |
| pipeline-service.appLogLevel | string | `"INFO"` |  |
| pipeline-service.autoscaling.enabled | bool | `false` |  |
| pipeline-service.image.tag | string | `"1.33.8"` |  |
| pipeline-service.java.memory | string | `"4096m"` |  |
| pipeline-service.replicaCount | int | `1` |  |
| pipeline-service.resources.limits.memory | string | `"6144Mi"` |  |
| pipeline-service.resources.requests.cpu | int | `1` |  |
| pipeline-service.resources.requests.memory | string | `"6144Mi"` |  |
| platform-service.appLogLevel | string | `"INFO"` |  |
| platform-service.autoscaling.enabled | bool | `false` |  |
| platform-service.image.tag | string | `"79202"` |  |
| platform-service.java.memory | string | `"3072m"` |  |
| platform-service.replicaCount | int | `1` |  |
| platform-service.resources.limits.memory | string | `"8192Mi"` |  |
| platform-service.resources.requests.cpu | float | `0.5` |  |
| platform-service.resources.requests.memory | string | `"512Mi"` |  |
| redis.autoscaling.enabled | bool | `false` |  |
| redis.initContainers.config_init.image.repository | string | `"redis"` |  |
| redis.initContainers.config_init.image.tag | string | `"6.2.12-alpine"` |  |
| redis.redis.image.pullPolicy | string | `"IfNotPresent"` |  |
| redis.redis.image.repository | string | `"redis"` |  |
| redis.redis.image.tag | string | `"6.2.12-alpine"` |  |
| redis.redis.resources.limits.memory | string | `"200Mi"` |  |
| redis.redis.resources.requests.cpu | float | `0.1` |  |
| redis.redis.resources.requests.memory | string | `"200Mi"` |  |
| redis.replicaCount | int | `3` |  |
| redis.sentinel.image.pullPolicy | string | `"IfNotPresent"` |  |
| redis.sentinel.image.repository | string | `"redis"` |  |
| redis.sentinel.image.tag | string | `"6.2.12-alpine"` |  |
| redis.sentinel.resources.limits.memory | string | `"200Mi"` |  |
| redis.sentinel.resources.requests.cpu | string | `"100m"` |  |
| redis.sentinel.resources.requests.memory | string | `"200Mi"` |  |
| redis.volumeClaimTemplate.resources.requests.storage | string | `"10Gi"` |  |
| scm-service.appLogLevel | string | `"INFO"` |  |
| scm-service.autoscaling.enabled | bool | `false` |  |
| scm-service.image.tag | string | `"release-150-ubi"` |  |
| scm-service.replicaCount | int | `1` |  |
| scm-service.resources.limits.memory | string | `"512Mi"` |  |
| scm-service.resources.requests.cpu | float | `0.1` |  |
| scm-service.resources.requests.memory | string | `"512Mi"` |  |
| template-service.appLogLevel | string | `"INFO"` |  |
| template-service.autoscaling.enabled | bool | `false` |  |
| template-service.image.tag | string | `"79421"` |  |
| template-service.java.memory | string | `"1024m"` |  |
| template-service.replicaCount | int | `1` |  |
| template-service.resources.limits.memory | string | `"1400Mi"` |  |
| template-service.resources.requests.cpu | int | `1` |  |
| template-service.resources.requests.memory | string | `"1400Mi"` |  |
| ti-service.appLogLevel | string | `"INFO"` |  |
| ti-service.autoscaling.enabled | bool | `false` |  |
| ti-service.image.tag | string | `"release-177"` |  |
| ti-service.jobresources.limits.memory | string | `"3072Mi"` |  |
| ti-service.jobresources.requests.cpu | int | `1` |  |
| ti-service.jobresources.requests.memory | string | `"3072Mi"` |  |
| ti-service.jobs.migrate.image.tag | string | `"release-177"` |  |
| ti-service.replicaCount | int | `1` |  |
| ti-service.resources.limits.memory | string | `"3072Mi"` |  |
| ti-service.resources.requests.cpu | int | `1` |  |
| ti-service.resources.requests.memory | string | `"3072Mi"` |  |
| timescaledb.autoscaling.enabled | bool | `false` |  |
| timescaledb.enabled | bool | `true` |  |
| timescaledb.image.tag | string | `"pg13-ts2.9-oss-latest"` |  |
| timescaledb.replicaCount | int | `1` |  |
| timescaledb.resources.limits.memory | string | `"2048Mi"` |  |
| timescaledb.resources.requests.cpu | int | `1` |  |
| timescaledb.resources.requests.memory | string | `"2048Mi"` |  |
| timescaledb.storage.capacity | string | `"100Gi"` |  |
| ui.appLogLevel | string | `"INFO"` |  |
| ui.autoscaling.enabled | bool | `false` |  |
| ui.image.tag | string | `"79401"` |  |
| ui.replicaCount | int | `1` |  |
| ui.resources.limits.memory | string | `"512Mi"` |  |
| ui.resources.requests.cpu | string | `"500m"` |  |
| ui.resources.requests.memory | string | `"512Mi"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
