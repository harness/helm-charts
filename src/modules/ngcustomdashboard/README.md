## Harness Dashboards Chart

A Helm chart for custom dashboards

![Version: 0.7.3](https://img.shields.io/badge/Version-0.7.3-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.76620](https://img.shields.io/badge/AppVersion-1.0.76620-informational?style=flat-square)

## Usage

Use the following dependency to add this chart repository to your Helm installation:

```
dependencies:
    - name: ng-custom-dashboards
      repository: https://harness.github.io/helm-dashboards
      version: 0.7.3
```

## Required setup
Our Dashboards application uses a 3rd party application called Looker, Looker must have it's own domain name to work.

A DNS CNAME entry must be created for Looker, it is recommended to use `looker.existing-dns-name.tld` as the domain name.

The Looker CNAME should be setup to point at the existing A record for your installation.

## Configuration
To enable dashboards the following is the minimum configuration required.
```yaml
global:
  ngcustomdashboard:
    enabled: true

ng-custom-dashboards:
  config:
    lookerPubDomain: 'looker.domain.tld'

looker:
  secrets:
    lookerLicenseKey: XXXXXXXXXXXXXXXXXXXX
```

### Airgapped (Offline) install
To install dashboards in an airgapped system an additional offline license key must be provided.
```yaml
looker:
  secrets:
    lookerLicenseKey: XXXXXXXXXXXXXXXXXXXX
    lookerLicenseFile: |
      xxxxxxx
      yyyyyyy
      zzzzzzz
```

## Configuration Examples
Since Looker must have it's own domain name the ingress/istio configuration is slightly different to other Harness Charts.

The following examples show only the additional config required for this Chart, you will need to merge this with your existing installations values.yaml overrides. Please take special care when merging the `global` sections.

The following examples all have TLS enabled, to ensure your `looker.domain.tld` domain works correctly you should update your TLS certificates to include this domain. Another option is to create a separate certificate and reference that secret below.

### Ingress
```yaml
global:
  ngcustomdashboard:
    enabled: true

ng-custom-dashboards:
  config:
    lookerPubDomain: 'looker.domain.tld'

looker:
  ingress:
    hosts:
      - 'looker.domain.tld'
    tls:
      secretName: 'looker-tls'

  secrets:
    lookerLicenseKey: XXXXXXXXXXXXXXXXXXXX
```

### Istio
Istio has two potential configuration options
1. Where the Istio gateway is create by the customer.
2. Where the Istio gateway is create by Harness at a global level.
3. Where the Istio gateway is create by this Chart.

#### Istio - gateway created by customer
In this scenario the customer will have to manually update their gateway configuration to route the `looker.domain.tld` domain.
```yaml
global:
  istio:
    virtualService:
      gateways:
      - istio-namespace/gateway-name
  ngcustomdashboard:
    enabled: true

ng-custom-dashboards:
  config:
    lookerPubDomain: 'looker.domain.tld'

looker:
  istio:
    gateway:
      create: false
    virtualService:
      enabled: true
      hosts:
        - looker.domain.tld

  secrets:
    lookerLicenseKey: XXXXXXXXXXXXXXXXXXXX
```

#### Istio - gateway created by Harness
In this case, you can simply add the Looker domain to the list of hosts in your existing `global.istio` configuration.
```yaml
global:
  istio:
    gateway:
      create: true
    hosts:
    - looker.domain.tld
  ngcustomdashboard:
    enabled: true

ng-custom-dashboards:
  config:
    lookerPubDomain: 'looker.domain.tld'

looker:
  istio:
    gateway:
      create: false
    virtualService:
      enabled: true
      hosts:
        - looker.domain.tld

  secrets:
    lookerLicenseKey: XXXXXXXXXXXXXXXXXXXX
```

#### Istio - gateway created by this Chart
In this scenario the gateway configuration is provided here in the values.yaml override.
```yaml
global:
  ngcustomdashboard:
    enabled: true

ng-custom-dashboards:
  config:
    lookerPubDomain: 'looker.domain.tld'

looker:
  istio:
    gateway:
      create: true
      port: 443
      protocol: HTTPS
    hosts:
      - looker.domain.tld
    tls:
      mode: SIMPLE
      credentialName: 'looker-tls'
    virtualService:
      enabled: true
      hosts:
        - looker.domain.tld

  secrets:
    lookerLicenseKey: XXXXXXXXXXXXXXXXXXXX
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.airgap | string | `"false"` |  |
| global.ha | bool | `false` |  |
| global.imagePullSecrets | list | `[]` |  |
| global.ingress.className | string | `""` |  |
| global.ingress.enabled | bool | `false` |  |
| global.ingress.hosts | list | `[]` |  |
| global.ingress.tls.enabled | bool | `false` |  |
| global.ingress.tls.secretName | string | `""` |  |
| global.istio.enabled | bool | `false` |  |
| global.istio.gateway.create | bool | `false` |  |
| global.istio.virtualService.gateways | string | `nil` |  |
| global.istio.virtualService.hosts | string | `nil` |  |
| global.loadbalancerURL | string | `""` |  |
| looker.affinity | object | `{}` |  |
| looker.clickhouseSecrets.password.key | string | `"admin-password"` | name of secret containing the clickhouse password |
| looker.clickhouseSecrets.password.name | string | `"clickhouse"` |  |
| looker.config.clickhouseConnectionName | string | `"smp-clickhouse"` | clickhouse connection name for CCM, must match model connection name |
| looker.config.clickhouseDatabase | string | `"ccm"` | clickhouse database name |
| looker.config.clickhouseHost | string | `"clickhouse"` | clickhouse hostname |
| looker.config.clickhousePort | string | `"8123"` | clickhouse port |
| looker.config.clickhouseUser | string | `"default"` | clickhouse user |
| looker.config.email | string | `"harnessSupport@harness.io"` | email address of the support user, required for initial signup and support |
| looker.config.ffConnectionName | string | `"smp-timescale-cf"` | timescale connection name for feature flags, must match model connection name |
| looker.config.ffDatabase | string | `"harness_ff"` | timescale database name for feature flags |
| looker.config.firstName | string | `"Harness"` | name of the user who performs setup and support tasks |
| looker.config.lastName | string | `"Support"` | last name of the user who performs setup and support tasks |
| looker.config.projectName | string | `"Harness"` | name of the looker project which will be created |
| looker.config.stoConnectionName | string | `"smp-postgres"` | postgres connection name for STO, must match model connection name |
| looker.config.stoDatabase | string | `"harness_sto"` | postgres database name for STO |
| looker.config.timescaleConnectionName | string | `"smp-timescale"` | timescale connection name, must match model connection name |
| looker.config.timescaleDatabase | string | `"harness"` | timescale database name |
| looker.config.timescaleHost | string | `"timescaledb-single-chart.harness"` | timescale hostname |
| looker.config.timescalePort | string | `"5432"` | timescale port |
| looker.config.timescaleUser | string | `"postgres"` | timescale user |
| looker.fullnameOverride | string | `""` |  |
| looker.image.digest | string | `""` |  |
| looker.image.imagePullSecrets | list | `[]` |  |
| looker.image.pullPolicy | string | `"IfNotPresent"` |  |
| looker.image.registry | string | `"docker.io"` |  |
| looker.image.repository | string | `"harness/looker-signed"` |  |
| looker.image.tag | string | `"23.10.36"` |  |
| looker.ingress.hosts | list | `[]` | Required if ingress is enabled, Looker requires a separate DNS domain name to function |
| looker.ingress.tls.secretName | string | `""` |  |
| looker.lookerSecrets.clientId.key | string | `"lookerClientId"` | name of secret containing the id used for API authentication, generate a 20-byte key, e.g. openssl rand -hex 10 |
| looker.lookerSecrets.clientId.name | string | `"harness-looker-secrets"` |  |
| looker.lookerSecrets.clientSecret.key | string | `"lookerClientSecret"` | name of secret containing the client secret used for API authentication, generate a 24-byte key, e.g. openssl rand -hex 12 |
| looker.lookerSecrets.clientSecret.name | string | `"harness-looker-secrets"` |  |
| looker.lookerSecrets.licenseKey.key | string | `"lookerLicenseKey"` | name of secret containing the looker license key which will be provided by Harness |
| looker.lookerSecrets.licenseKey.name | string | `"looker-secrets"` |  |
| looker.lookerSecrets.masterKey.key | string | `"lookerMasterKey"` | name of secret containing the key used for at rest encryption by looker, generate a Base64, 32-byte key, e.g. openssl rand -base64 32 |
| looker.lookerSecrets.masterKey.name | string | `"looker-secrets"` |  |
| looker.maxSurge | int | `1` |  |
| looker.maxUnavailable | int | `0` |  |
| looker.modelsDirectory | string | `"/mnt/lookerfiles"` | directory where Looker models volume will be mounted |
| looker.mysql.database | string | `"looker"` |  |
| looker.mysql.port | string | `"3306"` |  |
| looker.mysql.user | string | `"looker"` |  |
| looker.nameOverride | string | `""` |  |
| looker.nodeSelector | object | `{}` |  |
| looker.persistentVolume.accessMode | string | `"ReadWriteOnce"` |  |
| looker.persistentVolume.storage.database | string | `"20Gi"` | size of volume where Looker stores database |
| looker.persistentVolume.storage.models | string | `"2Gi"` | size of volume where Looker stores model files |
| looker.podAnnotations | object | `{}` |  |
| looker.podSecurityContext | object | `{}` |  |
| looker.resources.limits.cpu | int | `4` |  |
| looker.resources.limits.memory | string | `"8192Mi"` | minimum of 6GiB recommended |
| looker.resources.requests.cpu | int | `2` |  |
| looker.resources.requests.memory | string | `"4096Mi"` |  |
| looker.secrets.lookerLicenseKey | string | `""` | Required: Looker license key |
| looker.securityContext.runAsNonRoot | bool | `true` |  |
| looker.securityContext.runAsUser | int | `1001` |  |
| looker.service.port.api | int | `19999` |  |
| looker.service.port.web | int | `9999` |  |
| looker.service.type | string | `"ClusterIP"` |  |
| looker.serviceAccount.annotations | object | `{}` |  |
| looker.serviceAccount.create | bool | `true` |  |
| looker.serviceAccount.name | string | `"harness-looker"` |  |
| looker.timescaleSecrets.password.key | string | `"timescaledbPostgresPassword"` | name of secret containing the timescale password |
| looker.timescaleSecrets.password.name | string | `"harness-secrets"` |  |
| looker.tolerations | list | `[]` |  |
| ng-custom-dashboards.affinity | object | `{}` |  |
| ng-custom-dashboards.autoscaling.enabled | bool | `false` |  |
| ng-custom-dashboards.autoscaling.maxReplicas | int | `100` |  |
| ng-custom-dashboards.autoscaling.minReplicas | int | `1` |  |
| ng-custom-dashboards.autoscaling.targetCPU | string | `""` |  |
| ng-custom-dashboards.autoscaling.targetMemory | string | `""` |  |
| ng-custom-dashboards.config.cacheReloadFrequency | string | `"600"` | time in seconds between cache reloads |
| ng-custom-dashboards.config.customerFolderId | string | `"6"` | folder ID of the 'CUSTOMER' folder in looker |
| ng-custom-dashboards.config.lookerApiVersion | string | `"4.0"` | looker sdk param |
| ng-custom-dashboards.config.lookerHost | string | `"hrns-looker-api"` | hostname of your looker install |
| ng-custom-dashboards.config.lookerPort | string | `"19999"` | port of your looker install |
| ng-custom-dashboards.config.lookerPubDomain | string | `""` | Required: domain name of your looker instance, this must be accessible by users in your organisation |
| ng-custom-dashboards.config.lookerPubScheme | string | `"https"` | Required: HTTP scheme used, either http or https |
| ng-custom-dashboards.config.lookerScheme | string | `"http"` | scheme used for your looker install, http or https |
| ng-custom-dashboards.config.lookerTimeout | string | `"120"` | looker sdk param |
| ng-custom-dashboards.config.lookerVerifySsl | string | `"false"` | looker sdk param |
| ng-custom-dashboards.config.modelPrefix | string | `"SMP_"` | if you have configured Looker models with a prefix enter it here |
| ng-custom-dashboards.config.ootbFolderId | string | `"7"` | folder ID of the 'OOTB' folder in looker |
| ng-custom-dashboards.config.redisHost | string | `"harness-redis-master"` | hostname of your redis install |
| ng-custom-dashboards.config.redisLockTimeout | string | `"570"` | time in seconds before cache reload locks are automatically released |
| ng-custom-dashboards.config.redisPort | string | `"6379"` | port of your redis install |
| ng-custom-dashboards.config.redisSentinel | string | `"true"` | used to enable Redis Sentinel support |
| ng-custom-dashboards.config.redisSentinelMasterName | string | `"harness-redis"` | name of the Redis Sentinel master |
| ng-custom-dashboards.config.redisSentinelUrls | string | `""` | list of sentinel URLs, example host:port,host:port |
| ng-custom-dashboards.fullnameOverride | string | `""` |  |
| ng-custom-dashboards.image.digest | string | `""` |  |
| ng-custom-dashboards.image.imagePullSecrets | list | `[]` |  |
| ng-custom-dashboards.image.pullPolicy | string | `"IfNotPresent"` |  |
| ng-custom-dashboards.image.registry | string | `"docker.io"` |  |
| ng-custom-dashboards.image.repository | string | `"harness/dashboard-service-signed"` |  |
| ng-custom-dashboards.image.tag | string | `"v1.53.8.0"` |  |
| ng-custom-dashboards.lookerSecrets.clientId.key | string | `"lookerClientId"` |  |
| ng-custom-dashboards.lookerSecrets.clientId.name | string | `"harness-looker-secrets"` |  |
| ng-custom-dashboards.lookerSecrets.clientSecret.key | string | `"lookerClientSecret"` |  |
| ng-custom-dashboards.lookerSecrets.clientSecret.name | string | `"harness-looker-secrets"` |  |
| ng-custom-dashboards.lookerSecrets.secret.key | string | `"lookerEmbedSecret"` |  |
| ng-custom-dashboards.lookerSecrets.secret.name | string | `"harness-looker-secrets"` |  |
| ng-custom-dashboards.maxSurge | int | `1` |  |
| ng-custom-dashboards.maxUnavailable | int | `0` |  |
| ng-custom-dashboards.nameOverride | string | `""` |  |
| ng-custom-dashboards.nodeSelector | object | `{}` |  |
| ng-custom-dashboards.podAnnotations | object | `{}` |  |
| ng-custom-dashboards.podSecurityContext | object | `{}` |  |
| ng-custom-dashboards.replicaCount | int | `1` |  |
| ng-custom-dashboards.resources.limits.cpu | int | `1` |  |
| ng-custom-dashboards.resources.limits.memory | string | `"1536Mi"` |  |
| ng-custom-dashboards.resources.requests.cpu | int | `1` |  |
| ng-custom-dashboards.resources.requests.memory | string | `"768Mi"` |  |
| ng-custom-dashboards.securityContext.runAsNonRoot | bool | `true` |  |
| ng-custom-dashboards.securityContext.runAsUser | int | `65534` |  |
| ng-custom-dashboards.service.port | int | `5000` |  |
| ng-custom-dashboards.service.type | string | `"ClusterIP"` |  |
| ng-custom-dashboards.serviceAccount.annotations | object | `{}` |  |
| ng-custom-dashboards.serviceAccount.create | bool | `false` |  |
| ng-custom-dashboards.serviceAccount.name | string | `"harness-default"` |  |
| ng-custom-dashboards.tolerations | list | `[]` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.11.0](https://github.com/norwoodj/helm-docs/releases/v1.11.0)
