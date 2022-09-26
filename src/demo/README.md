# harness-demo

![Version: 0.2.48](https://img.shields.io/badge/Version-0.2.48-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.76620](https://img.shields.io/badge/AppVersion-1.0.76620-informational?style=flat-square)

Helm Chart for deploying Harness in Demo configuration

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| https://harness.github.io/helm-charts | harness | 0.2.44 |
| https://harness.github.io/helm-common | harness-common | 1.x.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.airgap | bool | `false` | Enable for complete airgap environment |
| global.et.enabled | bool | `false` | Enable to install Error Tracking |
| global.ff.enabled | bool | `false` | Enabled will deploy Feature Flags Component |
| global.ha | bool | `true` |  |
| global.imageRegistry | string | `""` | Global Docker image registry |
| global.ingress.className | string | `"harness"` |  |
| global.ingress.createDefaultBackend | bool | `false` |  |
| global.ingress.createNginxIngressController | bool | `false` |  |
| global.ingress.defaultbackend.image.digest | string | `""` |  |
| global.ingress.defaultbackend.image.pullPolicy | string | `"IfNotPresent"` |  |
| global.ingress.defaultbackend.image.registry | string | `"k8s.gcr.io"` |  |
| global.ingress.defaultbackend.image.repository | string | `"defaultbackend-amd64"` |  |
| global.ingress.defaultbackend.image.tag | string | `"1.5"` |  |
| global.ingress.enabled | bool | `false` |  |
| global.ingress.hosts[0] | string | `"my-host.example.org"` |  |
| global.ingress.loadBalancerEnabled | bool | `false` |  |
| global.ingress.loadBalancerIP | string | `"0.0.0.0"` |  |
| global.ingress.nginx.image.digest | string | `""` |  |
| global.ingress.nginx.image.pullPolicy | string | `"IfNotPresent"` |  |
| global.ingress.nginx.image.registry | string | `"us.gcr.io"` |  |
| global.ingress.nginx.image.repository | string | `"k8s-artifacts-prod/ingress-nginx/controller"` |  |
| global.ingress.nginx.image.tag | string | `"v1.0.0-alpha.2"` |  |
| global.ingress.tls.enabled | bool | `false` |  |
| global.ingress.tls.secretName | string | `"harness-ssl"` |  |
| global.ingress.useSelfSignedCert | bool | `false` |  |
| global.istio.enabled | bool | `false` |  |
| global.istio.gateway.create | bool | `true` | Enable to create istio-system gateway |
| global.istio.gateway.port | int | `443` |  |
| global.istio.gateway.protocol | string | `"HTTPS"` |  |
| global.istio.hosts[0] | string | `"*"` |  |
| global.istio.tls.credentialName | string | `nil` |  |
| global.istio.tls.minProtocolVersion | string | `"TLSV1_2"` |  |
| global.istio.tls.mode | string | `"SIMPLE"` |  |
| global.istio.virtualService.gateways[0] | string | `""` |  |
| global.istio.virtualService.hosts[0] | string | `""` |  |
| global.loadbalancerURL | string | `""` | Fully qualified URL of your loadbalancer (ex: https://www.foo.com) |
| global.mongoSSL | bool | `false` |  |
| global.ngcustomdashboard.enabled | bool | `false` | Enabled will deploy NG Customer Dashboards |
| global.sto.enabled | bool | `false` | Enable to install STO |
| global.storageClassName | string | `""` |  |
| harness.ci.ci-manager.autoscaling.enabled | bool | `false` |  |
| harness.ci.ci-manager.java.memory | string | `"2048m"` |  |
| harness.ci.ci-manager.replicaCount | int | `1` |  |
| harness.ci.ci-manager.resources.limits.cpu | float | `0.5` |  |
| harness.ci.ci-manager.resources.limits.memory | string | `"3000Mi"` |  |
| harness.ci.ci-manager.resources.requests.cpu | float | `0.5` |  |
| harness.ci.ci-manager.resources.requests.memory | string | `"3000Mi"` |  |
| harness.ci.enabled | bool | `true` | Enable to install CI |
| harness.et.enable-receivers | bool | `false` |  |
| harness.et.et-collector.autoscaling.enabled | bool | `false` |  |
| harness.et.et-collector.et.java.heapSize | string | `"1600m"` |  |
| harness.et.et-collector.replicaCount | int | `1` |  |
| harness.et.et-collector.resources.limits.cpu | string | `"500m"` |  |
| harness.et.et-collector.resources.limits.memory | string | `"2Gi"` |  |
| harness.et.et-collector.resources.requests.cpu | string | `"100m"` |  |
| harness.et.et-collector.resources.requests.memory | string | `"2Gi"` |  |
| harness.et.et-service.autoscaling.enabled | bool | `false` |  |
| harness.et.et-service.et.java.heapSize | string | `"2048m"` |  |
| harness.et.et-service.et.redis.enabled | bool | `false` |  |
| harness.et.et-service.replicaCount | int | `1` |  |
| harness.et.et-service.resources.limits.cpu | int | `1` |  |
| harness.et.et-service.resources.limits.memory | string | `"3Gi"` |  |
| harness.et.et-service.resources.requests.cpu | string | `"100m"` |  |
| harness.et.et-service.resources.requests.memory | string | `"3Gi"` |  |
| harness.ngcustomdashboard.looker.config.clientId | string | `""` | id used by initial setup user for authentication, generate a 20-byte key, e.g. openssl rand -hex 10 |
| harness.ngcustomdashboard.looker.config.email | string | `""` | email address of the support user, required for initial signup and support |
| harness.ngcustomdashboard.looker.config.firstName | string | `"Harness"` | name of the user who performs setup and support tasks |
| harness.ngcustomdashboard.looker.config.lastName | string | `"Support"` | last name of the user who performs setup and support tasks |
| harness.ngcustomdashboard.looker.config.projectName | string | `"Harness"` | name of the looker project which will be created |
| harness.ngcustomdashboard.looker.config.timescaleConnectionName | string | `"qa-timescale"` | timescale connection name, must match model connection name |
| harness.ngcustomdashboard.looker.config.timescaleDatabase | string | `""` | timescale database name |
| harness.ngcustomdashboard.looker.config.timescaleHost | string | `""` | timescale hostname |
| harness.ngcustomdashboard.looker.config.timescalePort | string | `""` | timescale port |
| harness.ngcustomdashboard.looker.config.timescaleUser | string | `""` | timescale user |
| harness.ngcustomdashboard.looker.ingress.host | string | `""` | Required if ingress is enabled, Looker requires a separate DNS domain name to function |
| harness.ngcustomdashboard.looker.ingress.tls.secretName | string | `""` |  |
| harness.ngcustomdashboard.looker.lookerSecrets.clientSecret.key | string | `"lookerClientSecret"` | name of secret containing the client secret used for initial setup, generate a 24-byte key, e.g. openssl rand -hex 12 |
| harness.ngcustomdashboard.looker.lookerSecrets.clientSecret.name | string | `"harness-secrets"` |  |
| harness.ngcustomdashboard.looker.lookerSecrets.licenseKey.key | string | `"lookerLicenseKey"` | name of secret containing the looker license key which will be provided by Harness |
| harness.ngcustomdashboard.looker.lookerSecrets.licenseKey.name | string | `"harness-secrets"` |  |
| harness.ngcustomdashboard.looker.lookerSecrets.masterKey.key | string | `"lookerMasterKey"` | name of secret containing the key used for at rest encryption by looker, generate a Base64, 32-byte key, e.g. openssl rand -base64 32 |
| harness.ngcustomdashboard.looker.lookerSecrets.masterKey.name | string | `"harness-secrets"` |  |
| harness.ngcustomdashboard.looker.resources.limits.cpu | int | `4` |  |
| harness.ngcustomdashboard.looker.resources.limits.memory | string | `"8Gi"` |  |
| harness.ngcustomdashboard.looker.resources.requests.cpu | int | `2` |  |
| harness.ngcustomdashboard.looker.resources.requests.memory | string | `"4Gi"` |  |
| harness.ngcustomdashboard.looker.timescaleSecrets.password.key | string | `"lookerTimescalePassword"` | name of secret containing the timescale password |
| harness.ngcustomdashboard.looker.timescaleSecrets.password.name | string | `"harness-secrets"` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.config.customerFolderId | string | `"6"` | folder ID of the 'CUSTOMER' folder in looker |
| harness.ngcustomdashboard.ng-custom-dashboard.config.lookerApiVersion | string | `"4.0"` | looker sdk param |
| harness.ngcustomdashboard.ng-custom-dashboard.config.lookerHost | string | `""` | hostname of your looker install |
| harness.ngcustomdashboard.ng-custom-dashboard.config.lookerPort | string | `"80"` | port of your looker install |
| harness.ngcustomdashboard.ng-custom-dashboard.config.lookerScheme | string | `"https"` | scheme used for your looker install, http or https |
| harness.ngcustomdashboard.ng-custom-dashboard.config.lookerTimeout | string | `"120"` | looker sdk param |
| harness.ngcustomdashboard.ng-custom-dashboard.config.lookerVerifySsl | string | `"false"` | looker sdk param |
| harness.ngcustomdashboard.ng-custom-dashboard.config.modelPrefix | string | `""` | if you have configured Looker models with a prefix enter it here |
| harness.ngcustomdashboard.ng-custom-dashboard.config.ootbFolderId | string | `"7"` | folder ID of the 'OOTB' folder in looker |
| harness.ngcustomdashboard.ng-custom-dashboard.config.redisHost | string | `""` | hostname of your redis install |
| harness.ngcustomdashboard.ng-custom-dashboard.config.redisPort | string | `"6379"` | port of your redis install |
| harness.ngcustomdashboard.ng-custom-dashboard.lookerSecrets.clientId.key | string | `"lookerSdkClientId"` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.lookerSecrets.clientId.name | string | `"harness-secrets"` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.lookerSecrets.clientSecret.key | string | `"lookerSdkClientSecret"` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.lookerSecrets.clientSecret.name | string | `"harness-secrets"` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.lookerSecrets.secret.key | string | `"lookerEmbedSecret"` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.lookerSecrets.secret.name | string | `"harness-secrets"` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.resources.limits.cpu | int | `1` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.resources.limits.memory | string | `"600Mi"` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.resources.requests.cpu | float | `0.5` |  |
| harness.ngcustomdashboard.ng-custom-dashboard.resources.requests.memory | string | `"300Mi"` |  |
| harness.platform.access-control | object | `{"appLogLevel":"INFO","autoscaling":{"enabled":false},"java":{"memory":"512m"},"replicaCount":1,"resources":{"limits":{"cpu":1,"memory":"4096Mi"},"requests":{"cpu":1,"memory":"4096Mi"}}}` | Feature list to enable within platform.  Contact Harness for value |
| harness.platform.change-data-capture.appLogLevel | string | `"INFO"` |  |
| harness.platform.change-data-capture.autoscaling.enabled | bool | `false` |  |
| harness.platform.change-data-capture.java.memory | int | `2048` |  |
| harness.platform.change-data-capture.replicaCount | int | `1` |  |
| harness.platform.change-data-capture.resources.limits.cpu | int | `1` |  |
| harness.platform.change-data-capture.resources.limits.memory | string | `"2880Mi"` |  |
| harness.platform.change-data-capture.resources.requests.cpu | int | `1` |  |
| harness.platform.change-data-capture.resources.requests.memory | string | `"2880Mi"` |  |
| harness.platform.cv-nextgen.autoscaling.enabled | bool | `false` |  |
| harness.platform.cv-nextgen.java.memory | int | `1024` |  |
| harness.platform.cv-nextgen.replicaCount | int | `1` |  |
| harness.platform.cv-nextgen.resources.limits.cpu | float | `0.5` |  |
| harness.platform.cv-nextgen.resources.limits.memory | string | `"1440Mi"` |  |
| harness.platform.cv-nextgen.resources.requests.cpu | float | `0.5` |  |
| harness.platform.cv-nextgen.resources.requests.memory | string | `"1440Mi"` |  |
| harness.platform.delegate-proxy.autoscaling.enabled | bool | `false` |  |
| harness.platform.delegate-proxy.replicaCount | int | `1` |  |
| harness.platform.delegate-proxy.resources.limits.cpu | string | `"200m"` |  |
| harness.platform.delegate-proxy.resources.limits.memory | string | `"100Mi"` |  |
| harness.platform.delegate-proxy.resources.requests.cpu | string | `"200m"` |  |
| harness.platform.delegate-proxy.resources.requests.memory | string | `"100Mi"` |  |
| harness.platform.gateway.autoscaling.enabled | bool | `false` |  |
| harness.platform.gateway.java.memory | int | `1024` |  |
| harness.platform.gateway.replicaCount | int | `1` |  |
| harness.platform.gateway.resources.limits.cpu | float | `0.5` |  |
| harness.platform.gateway.resources.limits.memory | string | `"1300Mi"` |  |
| harness.platform.gateway.resources.requests.cpu | float | `0.2` |  |
| harness.platform.gateway.resources.requests.memory | string | `"1300Mi"` |  |
| harness.platform.harness-manager.autoscaling.enabled | bool | `false` |  |
| harness.platform.harness-manager.external_graphql_rate_limit | string | `"500"` |  |
| harness.platform.harness-manager.java.memory | string | `"2048"` |  |
| harness.platform.harness-manager.replicaCount | int | `1` |  |
| harness.platform.harness-manager.resources.limits.cpu | float | `0.5` |  |
| harness.platform.harness-manager.resources.limits.memory | string | `"3000Mi"` |  |
| harness.platform.harness-manager.resources.requests.cpu | float | `0.5` |  |
| harness.platform.harness-manager.resources.requests.memory | string | `"3000Mi"` |  |
| harness.platform.le-nextgen.autoscaling.enabled | bool | `false` |  |
| harness.platform.le-nextgen.replicaCount | int | `1` |  |
| harness.platform.le-nextgen.resources.limits.cpu | float | `0.5` |  |
| harness.platform.le-nextgen.resources.limits.memory | string | `"512Mi"` |  |
| harness.platform.le-nextgen.resources.requests.cpu | float | `0.5` |  |
| harness.platform.le-nextgen.resources.requests.memory | string | `"512Mi"` |  |
| harness.platform.log-service.autoscaling.enabled | bool | `false` |  |
| harness.platform.log-service.replicaCount | int | `1` |  |
| harness.platform.log-service.resources.limits.cpu | float | `0.5` |  |
| harness.platform.log-service.resources.limits.memory | string | `"1400Mi"` |  |
| harness.platform.log-service.resources.requests.cpu | float | `0.5` |  |
| harness.platform.log-service.resources.requests.memory | string | `"1400Mi"` |  |
| harness.platform.minio.defaultBuckets | string | `"logs"` |  |
| harness.platform.minio.fullnameOverride | string | `"minio"` |  |
| harness.platform.minio.mode | string | `"standalone"` |  |
| harness.platform.minio.persistence.size | string | `"10Gi"` |  |
| harness.platform.mongodb.args[0] | string | `"--wiredTigerCacheSizeGB=0.5"` |  |
| harness.platform.mongodb.persistence.size | string | `"20Gi"` |  |
| harness.platform.mongodb.replicaCount | int | `1` |  |
| harness.platform.mongodb.resources.limits.cpu | int | `2` |  |
| harness.platform.mongodb.resources.limits.memory | string | `"2048Mi"` |  |
| harness.platform.mongodb.resources.requests.cpu | int | `1` |  |
| harness.platform.mongodb.resources.requests.memory | string | `"2048Mi"` |  |
| harness.platform.next-gen-ui.autoscaling.enabled | bool | `false` |  |
| harness.platform.next-gen-ui.replicaCount | int | `1` |  |
| harness.platform.next-gen-ui.resources.limits.cpu | float | `0.2` |  |
| harness.platform.next-gen-ui.resources.limits.memory | string | `"200Mi"` |  |
| harness.platform.next-gen-ui.resources.requests.cpu | float | `0.2` |  |
| harness.platform.next-gen-ui.resources.requests.memory | string | `"200Mi"` |  |
| harness.platform.ng-auth-ui.autoscaling.enabled | bool | `false` |  |
| harness.platform.ng-auth-ui.replicaCount | int | `1` |  |
| harness.platform.ng-auth-ui.resources.limits.cpu | float | `0.2` |  |
| harness.platform.ng-auth-ui.resources.limits.memory | string | `"200Mi"` |  |
| harness.platform.ng-auth-ui.resources.requests.cpu | float | `0.2` |  |
| harness.platform.ng-auth-ui.resources.requests.memory | string | `"200Mi"` |  |
| harness.platform.ng-manager.autoscaling.enabled | bool | `false` |  |
| harness.platform.ng-manager.java.memory | string | `"4096m"` |  |
| harness.platform.ng-manager.replicaCount | int | `1` |  |
| harness.platform.ng-manager.resources.limits.cpu | float | `0.5` |  |
| harness.platform.ng-manager.resources.limits.memory | string | `"6144Mi"` |  |
| harness.platform.ng-manager.resources.requests.cpu | float | `0.5` |  |
| harness.platform.ng-manager.resources.requests.memory | string | `"6144Mi"` |  |
| harness.platform.pipeline-service.autoscaling.enabled | bool | `false` |  |
| harness.platform.pipeline-service.java.memory | string | `"1024m"` |  |
| harness.platform.pipeline-service.replicaCount | int | `1` |  |
| harness.platform.pipeline-service.resources.limits.cpu | float | `0.5` |  |
| harness.platform.pipeline-service.resources.limits.memory | string | `"1400Mi"` |  |
| harness.platform.pipeline-service.resources.requests.cpu | float | `0.5` |  |
| harness.platform.pipeline-service.resources.requests.memory | string | `"1400Mi"` |  |
| harness.platform.platform-service.autoscaling.enabled | bool | `false` |  |
| harness.platform.platform-service.java.memory | string | `"2048m"` |  |
| harness.platform.platform-service.replicaCount | int | `1` |  |
| harness.platform.platform-service.resources.limits.cpu | float | `0.5` |  |
| harness.platform.platform-service.resources.limits.memory | string | `"3000Mi"` |  |
| harness.platform.platform-service.resources.requests.cpu | float | `0.5` |  |
| harness.platform.platform-service.resources.requests.memory | string | `"3000Mi"` |  |
| harness.platform.redis.redis.resources.limits.cpu | int | `1` |  |
| harness.platform.redis.redis.resources.limits.memory | string | `"2048Mi"` |  |
| harness.platform.redis.redis.resources.requests.cpu | int | `1` |  |
| harness.platform.redis.redis.resources.requests.memory | string | `"2048Mi"` |  |
| harness.platform.redis.replicaCount | int | `3` |  |
| harness.platform.redis.sentinel.resources.limits.cpu | string | `"100m"` |  |
| harness.platform.redis.sentinel.resources.limits.memory | string | `"200Mi"` |  |
| harness.platform.redis.sentinel.resources.requests.cpu | string | `"100m"` |  |
| harness.platform.redis.sentinel.resources.requests.memory | string | `"200Mi"` |  |
| harness.platform.redis.useAntiAffinity | bool | `false` |  |
| harness.platform.redis.volumeClaimTemplate.resources.requests.storage | string | `"10Gi"` |  |
| harness.platform.scm-service.autoscaling.enabled | bool | `false` |  |
| harness.platform.scm-service.replicaCount | int | `1` |  |
| harness.platform.scm-service.resources.limits.cpu | float | `0.1` |  |
| harness.platform.scm-service.resources.limits.memory | string | `"512Mi"` |  |
| harness.platform.scm-service.resources.requests.cpu | float | `0.1` |  |
| harness.platform.scm-service.resources.requests.memory | string | `"512Mi"` |  |
| harness.platform.template-service.autoscaling.enabled | bool | `false` |  |
| harness.platform.template-service.java.memory | string | `"1024m"` |  |
| harness.platform.template-service.replicaCount | int | `1` |  |
| harness.platform.template-service.resources.limits.cpu | float | `0.5` |  |
| harness.platform.template-service.resources.limits.memory | string | `"1500Mi"` |  |
| harness.platform.template-service.resources.requests.cpu | float | `0.5` |  |
| harness.platform.template-service.resources.requests.memory | string | `"1500Mi"` |  |
| harness.platform.ti-service.autoscaling.enabled | bool | `false` |  |
| harness.platform.ti-service.jobresources.limits.cpu | float | `0.5` |  |
| harness.platform.ti-service.jobresources.limits.memory | string | `"1400Mi"` |  |
| harness.platform.ti-service.jobresources.requests.cpu | float | `0.5` |  |
| harness.platform.ti-service.jobresources.requests.memory | string | `"1400Mi"` |  |
| harness.platform.ti-service.replicaCount | int | `1` |  |
| harness.platform.ti-service.resources.limits.cpu | float | `0.5` |  |
| harness.platform.ti-service.resources.limits.memory | string | `"1400Mi"` |  |
| harness.platform.ti-service.resources.requests.cpu | float | `0.5` |  |
| harness.platform.ti-service.resources.requests.memory | string | `"1400Mi"` |  |
| harness.platform.timescaledb.autoscaling.enabled | bool | `false` |  |
| harness.platform.timescaledb.replicaCount | int | `1` |  |
| harness.platform.timescaledb.resources.limits.cpu | float | `0.3` |  |
| harness.platform.timescaledb.resources.limits.memory | string | `"512Mi"` |  |
| harness.platform.timescaledb.resources.requests.cpu | float | `0.3` |  |
| harness.platform.timescaledb.resources.requests.memory | string | `"512Mi"` |  |
| harness.platform.timescaledb.storage.capacity | string | `"10Gi"` |  |
| harness.sto.sto-core.autoscaling.enabled | bool | `false` |  |
| harness.sto.sto-core.replicaCount | int | `1` |  |
| harness.sto.sto-core.resources.limits.cpu | string | `"500m"` |  |
| harness.sto.sto-core.resources.limits.memory | string | `"500Mi"` |  |
| harness.sto.sto-core.resources.requests.cpu | string | `"500m"` |  |
| harness.sto.sto-core.resources.requests.memory | string | `"500Mi"` |  |
| harness.sto.sto-manager.autoscaling.enabled | bool | `false` |  |
| harness.sto.sto-manager.replicaCount | int | `1` |  |
| harness.sto.sto-manager.resources.limits.cpu | int | `1` |  |
| harness.sto.sto-manager.resources.limits.memory | string | `"3072Mi"` |  |
| harness.sto.sto-manager.resources.requests.cpu | int | `1` |  |
| harness.sto.sto-manager.resources.requests.memory | string | `"3072Mi"` |  |

