## Harness STO Chart

A Helm chart for harness STO module

![Version: 0.7.3](https://img.shields.io/badge/Version-0.7.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.0.79001](https://img.shields.io/badge/AppVersion-0.0.79001-informational?style=flat-square)


## Usage

Use the following dependency to add this chart to your Helm chart:

```
dependencies:
    - name: harness-sto
      repository: https://harness.github.io/helm-sto
      version: 0.7.3
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.loadbalancerURL | string | `"https://test"` |  |
| sto-core.affinity | object | `{}` |  |
| sto-core.autoscaling.enabled | bool | `false` |  |
| sto-core.autoscaling.maxReplicas | int | `100` |  |
| sto-core.autoscaling.minReplicas | int | `1` |  |
| sto-core.autoscaling.targetCPU | string | `""` |  |
| sto-core.autoscaling.targetMemory | string | `""` |  |
| sto-core.fullnameOverride | string | `""` |  |
| sto-core.image.digest | string | `""` |  |
| sto-core.image.pullPolicy | string | `"IfNotPresent"` |  |
| sto-core.image.registry | string | `"docker.io"` |  |
| sto-core.image.repository | string | `"harness/stocore-signed"` |  |
| sto-core.image.tag | string | `"v1.47.0"` |  |
| sto-core.maxSurge | string | `"100%"` |  |
| sto-core.maxUnavailable | int | `0` |  |
| sto-core.nameOverride | string | `""` |  |
| sto-core.nodeSelector | object | `{}` |  |
| sto-core.podAnnotations | object | `{}` |  |
| sto-core.podSecurityContext | object | `{}` |  |
| sto-core.postgresPassword.key | string | `"postgres-password"` |  |
| sto-core.postgresPassword.name | string | `"postgres"` |  |
| sto-core.replicaCount | int | `1` |  |
| sto-core.resources.requests.cpu | string | `"500m"` |  |
| sto-core.resources.requests.memory | string | `"500Mi"` |  |
| sto-core.retryMigrations | bool | `true` |  |
| sto-core.securityContext | object | `{}` |  |
| sto-core.service.port | int | `4000` |  |
| sto-core.service.type | string | `"ClusterIP"` |  |
| sto-core.serviceAccount.annotations | object | `{}` |  |
| sto-core.serviceAccount.create | bool | `false` |  |
| sto-core.serviceAccount.name | string | `"harness-default"` |  |
| sto-core.stoAppAuditJWTSecret.key | string | `"stoAppAuditJWTSecret"` |  |
| sto-core.stoAppAuditJWTSecret.name | string | `"harness-secrets"` |  |
| sto-core.stoAppHarnessToken.key | string | `"stoAppHarnessToken"` |  |
| sto-core.stoAppHarnessToken.name | string | `"harness-secrets"` |  |
| sto-core.tolerations | list | `[]` |  |
| sto-core.waitForInitContainer.image.digest | string | `""` |  |
| sto-core.waitForInitContainer.image.pullPolicy | string | `"IfNotPresent"` |  |
| sto-core.waitForInitContainer.image.registry | string | `"docker.io"` |  |
| sto-core.waitForInitContainer.image.repository | string | `"harness/helm-init-container"` |  |
| sto-core.waitForInitContainer.image.tag | string | `"latest"` |  |
| sto-manager.addOnImage.image.digest | string | `""` |  |
| sto-manager.addOnImage.image.pullPolicy | string | `"IfNotPresent"` |  |
| sto-manager.addOnImage.image.registry | string | `"docker.io"` |  |
| sto-manager.addOnImage.image.repository | string | `"harness/ci-addon"` |  |
| sto-manager.addOnImage.image.tag | string | `"1.16.4"` |  |
| sto-manager.affinity | object | `{}` |  |
| sto-manager.autoscaling.enabled | bool | `false` |  |
| sto-manager.autoscaling.maxReplicas | int | `100` |  |
| sto-manager.autoscaling.minReplicas | int | `1` |  |
| sto-manager.autoscaling.targetCPU | string | `""` |  |
| sto-manager.autoscaling.targetMemory | string | `""` |  |
| sto-manager.defaultInternalImageConnector | string | `"account.harnessImage"` |  |
| sto-manager.fullnameOverride | string | `""` |  |
| sto-manager.global.delegate.airgapped | bool | `false` |  |
| sto-manager.global.loadbalancerURL | string | `"https://test"` |  |
| sto-manager.image.digest | string | `""` |  |
| sto-manager.image.pullPolicy | string | `"IfNotPresent"` |  |
| sto-manager.image.registry | string | `"docker.io"` |  |
| sto-manager.image.repository | string | `"harness/stomanager-signed"` |  |
| sto-manager.image.tag | string | `"79400-000"` |  |
| sto-manager.ingress.annotations | object | `{}` |  |
| sto-manager.ingress.className | string | `""` |  |
| sto-manager.ingress.enabled | bool | `false` |  |
| sto-manager.ingress.hosts[0].host | string | `"chart-example.local"` |  |
| sto-manager.ingress.hosts[0].paths[0].path | string | `"/"` |  |
| sto-manager.ingress.hosts[0].paths[0].pathType | string | `"ImplementationSpecific"` |  |
| sto-manager.ingress.tls | list | `[]` |  |
| sto-manager.java.memory | int | `2500` |  |
| sto-manager.java.memoryLimit | int | `600` |  |
| sto-manager.leImage.image.digest | string | `""` |  |
| sto-manager.leImage.image.pullPolicy | string | `"IfNotPresent"` |  |
| sto-manager.leImage.image.registry | string | `"docker.io"` |  |
| sto-manager.leImage.image.repository | string | `"harness/ci-lite-engine"` |  |
| sto-manager.leImage.image.tag | string | `"1.16.4"` |  |
| sto-manager.maxSurge | string | `"100%"` |  |
| sto-manager.maxUnavailable | int | `0` |  |
| sto-manager.mongoSecrets.password.key | string | `"mongodb-root-password"` |  |
| sto-manager.mongoSecrets.password.name | string | `"mongodb-replicaset-chart"` |  |
| sto-manager.mongoSecrets.userName.key | string | `"mongodbUsername"` |  |
| sto-manager.mongoSecrets.userName.name | string | `"harness-secrets"` |  |
| sto-manager.nameOverride | string | `""` |  |
| sto-manager.ngServiceAccount | string | `"test"` |  |
| sto-manager.nodeSelector | object | `{}` |  |
| sto-manager.podAnnotations | object | `{}` |  |
| sto-manager.podSecurityContext | object | `{}` |  |
| sto-manager.probes.livenessProbe.failureThreshold | int | `5` |  |
| sto-manager.probes.livenessProbe.httpGet.path | string | `"/health/liveness"` |  |
| sto-manager.probes.livenessProbe.httpGet.port | string | `"http"` |  |
| sto-manager.probes.livenessProbe.periodSeconds | int | `5` |  |
| sto-manager.probes.livenessProbe.timeoutSeconds | int | `2` |  |
| sto-manager.probes.readinessProbe.failureThreshold | int | `5` |  |
| sto-manager.probes.readinessProbe.httpGet.path | string | `"/health"` |  |
| sto-manager.probes.readinessProbe.httpGet.port | string | `"http"` |  |
| sto-manager.probes.readinessProbe.periodSeconds | int | `10` |  |
| sto-manager.probes.readinessProbe.timeoutSeconds | int | `2` |  |
| sto-manager.probes.startupProbe.failureThreshold | int | `25` |  |
| sto-manager.probes.startupProbe.httpGet.path | string | `"/health"` |  |
| sto-manager.probes.startupProbe.httpGet.port | string | `"http"` |  |
| sto-manager.probes.startupProbe.periodSeconds | int | `10` |  |
| sto-manager.probes.startupProbe.timeoutSeconds | int | `2` |  |
| sto-manager.redislabsCATruststore | string | `"test"` |  |
| sto-manager.replicaCount | int | `1` |  |
| sto-manager.resources.requests.cpu | int | `1` |  |
| sto-manager.resources.requests.memory | string | `"3Gi"` |  |
| sto-manager.s3UploadImage.image.digest | string | `""` |  |
| sto-manager.s3UploadImage.image.pullPolicy | string | `"IfNotPresent"` |  |
| sto-manager.s3UploadImage.image.registry | string | `"docker.io"` |  |
| sto-manager.s3UploadImage.image.repository | string | `"plugins/s3"` |  |
| sto-manager.s3UploadImage.image.tag | string | `"1.2.3"` |  |
| sto-manager.securityContext | object | `{}` |  |
| sto-manager.securityImage.image.digest | string | `""` |  |
| sto-manager.securityImage.image.pullPolicy | string | `"IfNotPresent"` |  |
| sto-manager.securityImage.image.registry | string | `"docker.io"` |  |
| sto-manager.securityImage.image.repository | string | `"harness/sto-plugin"` |  |
| sto-manager.securityImage.image.tag | string | `"1.13.0"` |  |
| sto-manager.service.grpcport | int | `9979` |  |
| sto-manager.service.port | int | `7090` |  |
| sto-manager.service.type | string | `"ClusterIP"` |  |
| sto-manager.serviceAccount.annotations | object | `{}` |  |
| sto-manager.serviceAccount.create | bool | `false` |  |
| sto-manager.serviceAccount.name | string | `"harness-default"` |  |
| sto-manager.stoServiceGlobalToken.key | string | `"stoAppHarnessToken"` |  |
| sto-manager.stoServiceGlobalToken.name | string | `"harness-secrets"` |  |
| sto-manager.timescaleSecret.password.key | string | `"timescaledbPostgresPassword"` |  |
| sto-manager.timescaleSecret.password.name | string | `"harness-secrets"` |  |
| sto-manager.tolerations | list | `[]` |  |
| sto-manager.waitForInitContainer.image.digest | string | `""` |  |
| sto-manager.waitForInitContainer.image.pullPolicy | string | `"IfNotPresent"` |  |
| sto-manager.waitForInitContainer.image.registry | string | `"docker.io"` |  |
| sto-manager.waitForInitContainer.image.repository | string | `"harness/helm-init-container"` |  |
| sto-manager.waitForInitContainer.image.tag | string | `"latest"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
