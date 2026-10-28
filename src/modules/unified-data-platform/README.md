# unified-data-platform

![Version: 0.48.2](https://img.shields.io/badge/Version-0.48.2-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

A Helm chart for Harness Unified Data Platform (UDP) services

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | config-service | 0.1.170 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | dashboard-ui | 1.89.0 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | onboarding-service | 0.14.89 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | query-service | 0.75.3 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | schema-service | 0.23.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config-service.configService.appConfig.harness.auth.cache.enabled | bool | `true` |  |
| config-service.configService.appConfig.harness.auth.cache.profile.enabled | bool | `true` |  |
| config-service.configService.appConfig.harness.auth.cache.profile.max-size | int | `2000` |  |
| config-service.configService.appConfig.harness.auth.cache.profile.ttl-seconds | int | `300` |  |
| config-service.configService.appConfig.harness.auth.cache.token-validation.enabled | bool | `true` |  |
| config-service.configService.appConfig.harness.auth.cache.token-validation.max-size | int | `2000` |  |
| config-service.configService.appConfig.harness.auth.cache.token-validation.ttl-seconds | int | `300` |  |
| config-service.configService.kafka.enabled | bool | `false` |  |
| config-service.configService.kafka.tlsTruststoreSecret | string | `""` |  |
| config-service.configService.kafka.tlsUserSecret | string | `""` |  |
| config-service.createSmpSecret | bool | `false` |  |
| config-service.image.imagePullSecrets | list | `[]` |  |
| config-service.secretValues.AUTHZ_SERVICE_SECRET | string | `"IC04LYMBf1lDP5oeY4hupxd4HJhLmN6azUku3xEbeE3SUx5G3ZYzhbiwVtK4i7AmqyU9OZkwB4v8E9qM"` |  |
| config-service.secretValues.UDP_INTERNAL_SECRET | string | `"x6ee13sGJdtzccBJhgHfMXtMTE37EBJ9wIrXH01OUrOcRfbwPLo5oaSdplXnGlAq"` |  |
| config-service.secrets.authzServiceSecret.key | string | `"jwtNextGenManagerSecret"` |  |
| config-service.secrets.authzServiceSecret.secretName | string | `"harness-shared-secrets"` |  |
| config-service.secrets.udpInternalSecret.key | string | `"udpInternalSecret"` |  |
| config-service.secrets.udpInternalSecret.secretName | string | `"harness-shared-secrets"` |  |
| dashboard-ui.image.imagePullSecrets | list | `[]` |  |
| onboarding-service.createSmpSecret | bool | `false` |  |
| onboarding-service.image.imagePullSecrets | list | `[]` |  |
| onboarding-service.onboardingService.appConfig.onboarding-service.provider-groups.include[0].name | string | `"02_smp"` |  |
| onboarding-service.onboardingService.kafka.enabled | bool | `false` |  |
| onboarding-service.onboardingService.kafka.tlsTruststoreSecret | string | `""` |  |
| onboarding-service.onboardingService.kafka.tlsUserSecret | string | `""` |  |
| onboarding-service.onboardingService.serviceAccount.create | bool | `true` |  |
| onboarding-service.onboardingService.serviceAccount.name | string | `"onboarding-service"` |  |
| onboarding-service.secretValues.UDP_INTERNAL_SECRET | string | `"x6ee13sGJdtzccBJhgHfMXtMTE37EBJ9wIrXH01OUrOcRfbwPLo5oaSdplXnGlAq"` |  |
| onboarding-service.secrets.udpInternalSecret.key | string | `"udpInternalSecret"` |  |
| onboarding-service.secrets.udpInternalSecret.secretName | string | `"harness-shared-secrets"` |  |
| query-service.createSmpSecret | bool | `false` |  |
| query-service.image.imagePullSecrets | list | `[]` |  |
| query-service.queryService.appConfig.grpcClients.config-service.cache-duration | string | `"15m"` |  |
| query-service.queryService.appConfig.grpcClients.schema-service.cache-duration | string | `"15m"` |  |
| query-service.queryService.appConfig.queryService.data.connections | list | `[]` |  |
| query-service.queryService.appConfig.queryService.kafka.enabled | bool | `false` |  |
| query-service.queryService.appConfig.queryService.kafka.tlsTruststoreSecret | string | `""` |  |
| query-service.queryService.appConfig.queryService.kafka.tlsUserSecret | string | `""` |  |
| query-service.queryService.connectionSecrets | list | `[]` |  |
| query-service.queryService.serviceAccount.name | string | `"default"` |  |
| query-service.secretValues.AUTHZ_SERVICE_SECRET | string | `"IC04LYMBf1lDP5oeY4hupxd4HJhLmN6azUku3xEbeE3SUx5G3ZYzhbiwVtK4i7AmqyU9OZkwB4v8E9qM"` |  |
| query-service.secretValues.UDP_INTERNAL_SECRET | string | `"x6ee13sGJdtzccBJhgHfMXtMTE37EBJ9wIrXH01OUrOcRfbwPLo5oaSdplXnGlAq"` |  |
| query-service.secrets.authzServiceSecret.key | string | `"jwtNextGenManagerSecret"` |  |
| query-service.secrets.authzServiceSecret.secretName | string | `"harness-shared-secrets"` |  |
| query-service.secrets.udpInternalSecret.key | string | `"udpInternalSecret"` |  |
| query-service.secrets.udpInternalSecret.secretName | string | `"harness-shared-secrets"` |  |
| schema-service.createSmpSecret | bool | `false` |  |
| schema-service.image.imagePullSecrets | list | `[]` |  |
| schema-service.schemaService.appConfig.harness.auth.cache.enabled | bool | `true` |  |
| schema-service.schemaService.appConfig.harness.auth.cache.profile.enabled | bool | `true` |  |
| schema-service.schemaService.appConfig.harness.auth.cache.profile.max-size | int | `2000` |  |
| schema-service.schemaService.appConfig.harness.auth.cache.profile.ttl-seconds | int | `300` |  |
| schema-service.schemaService.appConfig.harness.auth.cache.token-validation.enabled | bool | `true` |  |
| schema-service.schemaService.appConfig.harness.auth.cache.token-validation.max-size | int | `2000` |  |
| schema-service.schemaService.appConfig.harness.auth.cache.token-validation.ttl-seconds | int | `300` |  |
| schema-service.schemaService.kafka.enabled | bool | `false` |  |
| schema-service.schemaService.kafka.tlsTruststoreSecret | string | `""` |  |
| schema-service.schemaService.kafka.tlsUserSecret | string | `""` |  |
| schema-service.secretValues.AUTHZ_SERVICE_SECRET | string | `"IC04LYMBf1lDP5oeY4hupxd4HJhLmN6azUku3xEbeE3SUx5G3ZYzhbiwVtK4i7AmqyU9OZkwB4v8E9qM"` |  |
| schema-service.secretValues.UDP_INTERNAL_SECRET | string | `"x6ee13sGJdtzccBJhgHfMXtMTE37EBJ9wIrXH01OUrOcRfbwPLo5oaSdplXnGlAq"` |  |
| schema-service.secrets.authzServiceSecret.key | string | `"jwtNextGenManagerSecret"` |  |
| schema-service.secrets.authzServiceSecret.secretName | string | `"harness-shared-secrets"` |  |
| schema-service.secrets.udpInternalSecret.key | string | `"udpInternalSecret"` |  |
| schema-service.secrets.udpInternalSecret.secretName | string | `"harness-shared-secrets"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
