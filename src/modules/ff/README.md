## Harness Feature Flags Chart

A Helm chart for harness Feature Flags module

![Version: 0.7.2](https://img.shields.io/badge/Version-0.7.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.1](https://img.shields.io/badge/AppVersion-0.0.1-informational?style=flat-square)

## Usage

Use the following dependency to add this chart repository to your Helm installation:

```
dependencies:
    - name: harness-ff
      repository: https://harness.github.io/helm-ff
      version: <no value>
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ff-pushpin-service.affinity | object | `{}` |  |
| ff-pushpin-service.appLogLevel | string | `"INFO"` |  |
| ff-pushpin-service.autoscaling.enabled | bool | `false` |  |
| ff-pushpin-service.autoscaling.maxReplicas | int | `100` |  |
| ff-pushpin-service.autoscaling.minReplicas | int | `1` |  |
| ff-pushpin-service.autoscaling.targetCPU | string | `""` |  |
| ff-pushpin-service.autoscaling.targetMemory | string | `""` |  |
| ff-pushpin-service.configmap | object | `{}` |  |
| ff-pushpin-service.fullnameOverride | string | `""` |  |
| ff-pushpin-service.maxSurge | int | `1` |  |
| ff-pushpin-service.maxUnavailable | int | `0` |  |
| ff-pushpin-service.memory | int | `4096` |  |
| ff-pushpin-service.nameOverride | string | `""` |  |
| ff-pushpin-service.nodeSelector | object | `{}` |  |
| ff-pushpin-service.podAnnotations | object | `{}` |  |
| ff-pushpin-service.podSecurityContext | object | `{}` |  |
| ff-pushpin-service.pushpin.image.digest | string | `""` |  |
| ff-pushpin-service.pushpin.image.pullPolicy | string | `"IfNotPresent"` |  |
| ff-pushpin-service.pushpin.image.registry | string | `"docker.io"` |  |
| ff-pushpin-service.pushpin.image.repository | string | `"harness/ff-pushpin-signed"` |  |
| ff-pushpin-service.pushpin.image.tag | string | `"1.0.3"` |  |
| ff-pushpin-service.pushpin.resources.limits.cpu | int | `1` |  |
| ff-pushpin-service.pushpin.resources.limits.memory | string | `"2048Mi"` |  |
| ff-pushpin-service.pushpin.resources.requests.cpu | int | `1` |  |
| ff-pushpin-service.pushpin.resources.requests.memory | string | `"2048Mi"` |  |
| ff-pushpin-service.pushpinworker.image.digest | string | `""` |  |
| ff-pushpin-service.pushpinworker.image.pullPolicy | string | `"IfNotPresent"` |  |
| ff-pushpin-service.pushpinworker.image.registry | string | `"docker.io"` |  |
| ff-pushpin-service.pushpinworker.image.repository | string | `"harness/ff-pushpin-worker-signed"` |  |
| ff-pushpin-service.pushpinworker.image.tag | string | `"1.1075.0"` |  |
| ff-pushpin-service.pushpinworker.resources.limits.cpu | int | `1` |  |
| ff-pushpin-service.pushpinworker.resources.limits.memory | string | `"2048Mi"` |  |
| ff-pushpin-service.pushpinworker.resources.requests.cpu | int | `1` |  |
| ff-pushpin-service.pushpinworker.resources.requests.memory | string | `"2048Mi"` |  |
| ff-pushpin-service.pushpinworker.securityContext.runAsNonRoot | bool | `true` |  |
| ff-pushpin-service.pushpinworker.securityContext.runAsUser | int | `65534` |  |
| ff-pushpin-service.replicaCount | int | `1` |  |
| ff-pushpin-service.service.port17001 | int | `17001` |  |
| ff-pushpin-service.service.port17002 | int | `17002` |  |
| ff-pushpin-service.service.port17003 | int | `17003` |  |
| ff-pushpin-service.service.targetport17001 | int | `7999` |  |
| ff-pushpin-service.service.targetport17002 | int | `443` |  |
| ff-pushpin-service.service.targetport17003 | int | `5561` |  |
| ff-pushpin-service.service.type | string | `"ClusterIP"` |  |
| ff-pushpin-service.serviceAccount.annotations | object | `{}` |  |
| ff-pushpin-service.serviceAccount.create | bool | `false` |  |
| ff-pushpin-service.serviceAccount.name | string | `"harness-default"` |  |
| ff-pushpin-service.tolerations | list | `[]` |  |
| ff-pushpin-service.waitForInitContainer.image.digest | string | `""` |  |
| ff-pushpin-service.waitForInitContainer.image.pullPolicy | string | `"IfNotPresent"` |  |
| ff-pushpin-service.waitForInitContainer.image.registry | string | `"docker.io"` |  |
| ff-pushpin-service.waitForInitContainer.image.repository | string | `"harness/helm-init-container"` |  |
| ff-pushpin-service.waitForInitContainer.image.tag | string | `"latest"` |  |
| ff-service.affinity | object | `{}` |  |
| ff-service.appLogLevel | string | `"INFO"` |  |
| ff-service.autoscaling.enabled | bool | `false` |  |
| ff-service.autoscaling.maxReplicas | int | `100` |  |
| ff-service.autoscaling.minReplicas | int | `1` |  |
| ff-service.autoscaling.targetCPU | string | `""` |  |
| ff-service.autoscaling.targetMemory | string | `""` |  |
| ff-service.configmap | object | `{}` |  |
| ff-service.fullnameOverride | string | `""` |  |
| ff-service.image.digest | string | `""` |  |
| ff-service.image.pullPolicy | string | `"IfNotPresent"` |  |
| ff-service.image.registry | string | `"docker.io"` |  |
| ff-service.image.repository | string | `"harness/ff-server-signed"` |  |
| ff-service.image.tag | string | `"1.1075.0"` |  |
| ff-service.jobs.postgres_migration.image.digest | string | `""` |  |
| ff-service.jobs.postgres_migration.image.pullPolicy | string | `"Always"` |  |
| ff-service.jobs.postgres_migration.image.registry | string | `"docker.io"` |  |
| ff-service.jobs.postgres_migration.image.repository | string | `"harness/ff-postgres-migration-signed"` |  |
| ff-service.jobs.postgres_migration.image.tag | string | `"1.1075.0"` |  |
| ff-service.jobs.timescaledb_migrate.image.digest | string | `""` |  |
| ff-service.jobs.timescaledb_migrate.image.pullPolicy | string | `"Always"` |  |
| ff-service.jobs.timescaledb_migrate.image.registry | string | `"docker.io"` |  |
| ff-service.jobs.timescaledb_migrate.image.repository | string | `"harness/ff-timescale-migration-signed"` |  |
| ff-service.jobs.timescaledb_migrate.image.tag | string | `"1.1075.0"` |  |
| ff-service.maxSurge | int | `1` |  |
| ff-service.maxUnavailable | int | `0` |  |
| ff-service.memory | int | `4096` |  |
| ff-service.nameOverride | string | `""` |  |
| ff-service.nodeSelector | object | `{}` |  |
| ff-service.podAnnotations | object | `{}` |  |
| ff-service.podSecurityContext | object | `{}` |  |
| ff-service.replicaCount | int | `1` |  |
| ff-service.resources.limits.cpu | int | `1` |  |
| ff-service.resources.limits.memory | string | `"2048Mi"` |  |
| ff-service.resources.requests.cpu | int | `1` |  |
| ff-service.resources.requests.memory | string | `"2048Mi"` |  |
| ff-service.securityContext.runAsNonRoot | bool | `true` |  |
| ff-service.securityContext.runAsUser | int | `65534` |  |
| ff-service.service.grpcport | int | `16002` |  |
| ff-service.service.port | int | `16001` |  |
| ff-service.service.targetgrpcport | int | `3001` |  |
| ff-service.service.targetport | int | `3000` |  |
| ff-service.service.type | string | `"ClusterIP"` |  |
| ff-service.serviceAccount.annotations | object | `{}` |  |
| ff-service.serviceAccount.create | bool | `false` |  |
| ff-service.serviceAccount.name | string | `"harness-default"` |  |
| ff-service.timescaleSecret.password.key | string | `"timescaledbPostgresPassword"` |  |
| ff-service.timescaleSecret.password.name | string | `"harness-secrets"` |  |
| ff-service.tolerations | list | `[]` |  |
| ff-service.waitForInitContainer.image.digest | string | `""` |  |
| ff-service.waitForInitContainer.image.pullPolicy | string | `"IfNotPresent"` |  |
| ff-service.waitForInitContainer.image.registry | string | `"docker.io"` |  |
| ff-service.waitForInitContainer.image.repository | string | `"harness/helm-init-container"` |  |
| ff-service.waitForInitContainer.image.tag | string | `"latest"` |  |
| global.airgap | bool | `false` |  |
| global.database.mongo.installed | bool | `true` |  |
| global.database.redis.extraArgs | string | `""` |  |
| global.database.redis.hosts | list | `["redis:6379"]` | provide default values if redis.installed is set to false |
| global.database.redis.installed | bool | `true` |  |
| global.database.redis.passwordKey | string | `"redis-password"` |  |
| global.database.redis.protocol | string | `"redis"` |  |
| global.database.redis.secretName | string | `"redis-secret"` |  |
| global.database.redis.userKey | string | `"redis-user"` |  |
| global.ha | bool | `false` |  |
| global.ingress.className | string | `"nginx"` |  |
| global.ingress.enabled | bool | `false` |  |
| global.ingress.hosts[0] | string | `"my-host.example.org"` |  |
| global.ingress.tls.enabled | bool | `false` |  |
| global.ingress.tls.secretName | string | `"harness-ssl"` |  |
| global.loadbalancerURL | string | `"test@harness.io"` |  |
| global.opa.enabled | bool | `false` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)