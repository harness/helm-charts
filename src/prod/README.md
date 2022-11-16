## Harness Helm Charts

This readme provides the basic instructions you need to deploy Harness using a Helm chart. The Helm chart deploys Harness in a production configuration.

Helm Chart for deploying Harness in Production environment

![Version: 0.2.79](https://img.shields.io/badge/Version-0.2.79-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.77125](https://img.shields.io/badge/AppVersion-1.0.77125-informational?style=flat-square)

## Usage

Harness Helm charts require the installation of [Helm](https://helm.sh). To download and get started with Helm, see the [Helm documentation](https://helm.sh/docs/).

Use the following command to add the Harness chart repository to your Helm installation:

```console
$ helm repo add harness https://harness.github.io/helm-charts
```
## Requirements
* [Istio](https://isio/io). This Helm chart includes Istio service mesh as an optional dependency and requires its installation. For information about how to download and install Istio into your Kubernetes clusters, see https://istio.io/latest/docs/setup/getting-started/

## Install the chart
Use the following process to install the Helm chart.
1. Create a namespace for your installation.
```
$ kubectl create namespace <namespace>
```

2. Create the override.yaml file using your envirionment settings:

```
global:
  airgap: "false"
  ha: true

  # -- This private Docker image registry will override any registries that are defined in subcharts.
  imageRegistry: ""

  loadbalancerURL: https://myhostname.example.com
  mongoSSL: false
  storageClassName: ""

  cd:
    enabled: true
  # -- Enabled will deploy CI to your cluster(GA)
  ci:
    enabled: true
  # -- Enabled will deploy STO to your cluster(GA)
  sto:
    enabled: true

  # -- Enabled will deploy SRM to your cluster(Beta)
  srm:
    enabled: true

  # -- Enabled will deploy NG Customer Dashboards(Beta)
  ngcustomdashboard:
    enabled: true

  # -- Enabled will deploy Feature Flags Component(Beta)
  ff:
    enabled: true

  # --  Enabled will not send invites to email and autoaccepts
  saml:
    autoaccept: false

  ## !! Enable Istio or ingress; do not enable both. If `istio.enabled` is true, `ingress.enabled` must not be.
  # --- Set `ingress.enabled` to `true` to create Kubernetes *Ingress* objects for Nginx.
  ingress:
    enabled: true
    loadBalancerIP: '0.0.0.0'
    loadBalancerEnabled: false
    className: "harness"
    useSelfSignedCert: false
    hosts:
      - 'myhost.example.com'
    tls:
      enabled: true
      secretName: harness-cert

    nginx:
      # -- Create Nginx Controller.  True will deploy a controller into your cluster
      create: false
      controller:
        # -- annotations to be addded to ingress Controller
        annotations: {}
      objects:
        # -- annotations to be added to ingress Objects
        annotations: {}

    defaultbackend:
      # -- Create will deploy a default backend into your cluster
      create: false

  # -- Istio Ingress Settings
  istio:
    enabled: false
    strict: false
    gateway:
      create: true
      port: 443
      protocol: HTTPS
    hosts:
      - '*'
    tls:
      credentialName: harness-cert
      minProtocolVersion: TLSV1_2
      mode: SIMPLE
    virtualService:
      hosts:
        - "myhostname.example.com"

harness:
  ci:

    ci-manager:
      affinity: {}
      nodeSelector: {}
      tolerations: []

  sto:
    sto-core:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    sto-manager:
      affinity: {}
      nodeSelector: {}
      tolerations: []

  srm:
    enable-receivers: false

    et-service:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    et-collector:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    et-receiver-decompile:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    et-receiver-hit:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    et-receiver-sql:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    et-receiver-agent:
      affinity: {}
      nodeSelector: {}
      tolerations: []

  ngcustomdashboard:
    looker:
      affinity: {}
      nodeSelector: {}
      tolerations: []
    ng-custom-dashboards:
      affinity: {}
      nodeSelector: {}
      tolerations: []

  platform:
    # -- Access control settings (taints, tolerations, and so on)
    access-control:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    # -- change-data-capture settings (taints, tolerations, and so on)
    change-data-capture:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    # -- cv-nextgen settings (taints, tolerations, and so on)
    cv-nextgen:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    # -- delegate proxy settings (taints, tolerations, and so on)
    delegate-proxy:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    # -- gateway settings (taints, tolerations, and so on)
    gateway:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    # -- harness-manager (taints, tolerations, and so on)
    harness-manager:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    # -- le-nextgen (taints, tolerations, and so on)
    le-nextgen:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    # -- log-service (taints, tolerations, and so on)
    log-service:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    # -- minio (taints, tolerations, and so on)
    minio:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    mongodb:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    next-gen-ui:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    ng-auth-ui:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    ng-manager:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    pipeline-service:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    platform-service:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    redis:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    scm-service:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    template-service:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    ti-service:
      affinity: {}
      nodeSelector: {}
      tolerations: []

    timescaledb:
      affinity: {}
      nodeSelector: {}
      tolerations: []

```

Install the Helm chart:
```
$  helm install my-release harness/harness-prod -n <namespace> -f override.yaml
```

### Access the application
Verify your installation by accessing the Harness application and creating your Harness account. For basic instructions, see https://docs.harness.io/article/gqoqinkhck-install-harness-self-managed-enterprise-edition-with-helm#create_your_harness_account.

## Upgrade the chart
Use the following instructions to upgrade Harness Helm chart to a later version.

1. Obtain the `release-name` that identifies the installed release:
```
$ helm ls -n <namespace>
```
2. Retrieve configuration information for the installed release from the old-values.yaml file:
```
$ helm get values my-release > old_values.yaml
```
3. Modify the values of the old_values.yaml file as your configuration requires.

4. Use the `helm upgrade` command to update the chart:

Helm Upgrade
```
$ helm upgrade my-release harness/harness-demo -n <namespace> -f old_values.yaml
```

## Uninstall the chart

The following process uninstalls the Helm chart and removes your Harness deployment.

Uninstall and delete the `my-release` deployment:

```console
$ helm uninstall my-release -n <namespace>
```

This command removes the Kubernetes components that are associated with the chart and deletes the release.

## Images for disconnected networks

If your cluster is in an air-gapped environment, your deployment requires the following images:

```
docker.io/bitnami/minio:2022.8.22-debian-11-r0
docker.io/bitnami/mongodb:4.2.19
docker.io/bitnami/nginx-ingress-controller:1.4.0-debian-11-r2
docker.io/bitnami/nginx:1.22.0-debian-11-r44
docker.io/bitnami/postgresql:14.4.0-debian-11-r9
docker.io/harness/accesscontrol-service-signed:76800
docker.io/harness/cdcdata-signed:77026
docker.io/harness/ci-manager-signed:904
docker.io/harness/ci-scm-signed:release-87-ubi
docker.io/harness/cv-nextgen-signed:77026
docker.io/harness/dashboard-service-signed:v1.52.24
docker.io/harness/delegate-proxy-signed:76818_2
docker.io/harness/error-tracking-signed:5.5.2
docker.io/harness/et-collector-signed:5.5.0
docker.io/harness/ff-pushpin-signed:1.0.3
docker.io/harness/ff-pushpin-worker-signed:1.666.0
docker.io/harness/ff-server-signed:1.666.0
docker.io/harness/gateway-signed:200089
docker.io/harness/helm-init-container:latest
docker.io/harness/le-nextgen-signed:67102
docker.io/harness/looker-signed:22.16.46.0
docker.io/harness/manager-signed:77030
docker.io/harness/stocore-signed:v1.7.2
docker.io/harness/stomanager-signed:77300-000
docker.io/harness/ti-service-signed:release-87
docker.io/harness/template-service-signed:77026
docker.io/harness/ff-postgres-migration-signed:1.666.0
docker.io/harness/ff-timescale-migration-signed:1.666.0
docker.io/harness/helm-init-container:latest
docker.io/harness/log-service-signed:release-18
docker.io/harness/nextgenui-signed:0.322.11
docker.io/harness/ng-auth-ui-signed:0.42.2
docker.io/harness/ng-manager-signed:77030
docker.io/harness/pipeline-service-signed:1.11.1
docker.io/harness/platform-service-signed:77000
docker.io/harness/redis:6.2.7-alpine
docker.io/harness/ti-service-signed:release-87
docker.io/timescale/timescaledb-ha:pg13-ts2.6-oss-latest
docker.io/harness/ci-addon:1.14.7
docker.io/plugins/artifactory:1.1.0
docker.io/harness/delegate:latest
docker.io/plugins/kaniko:1.6.0
docker.io/plugins/kaniko-ecr:1.6.0
docker.io/plugins/kaniko-gcr:1.6.0
docker.io/plugins/cache:1.4.0
docker.io/plugins/gcs:1.3.0
docker.io/harness/drone-git:1.2.0-rootless
docker.io/harness/ci-lite-engine:1.14.7
docker.io/plugins/cache:1.4.0
docker.io/bewithaman/s3:latest
docker.io/plugins/s3:1.1.0
docker.io/harness/sto-plugin:latest
docker.io/curlimages/curl:latest

```
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.airgap | bool | `false` | Enable for complete airgap environment |
| global.cd.enabled | bool | `true` | Enable to install CD |
| global.ci.enabled | bool | `true` | Enable to install CI |
| global.ff.enabled | bool | `false` | Enabled will deploy Feature Flags Component |
| global.ha | bool | `true` |  |
| global.imageRegistry | string | `""` | Global Docker image registry |
| global.ingress.annotations | object | `{}` |  |
| global.ingress.className | string | `"harness"` |  |
| global.ingress.defaultbackend.create | bool | `false` | Create will deploy a default backend into your cluster |
| global.ingress.defaultbackend.image.digest | string | `""` |  |
| global.ingress.defaultbackend.image.pullPolicy | string | `"IfNotPresent"` |  |
| global.ingress.defaultbackend.image.registry | string | `"k8s.gcr.io"` |  |
| global.ingress.defaultbackend.image.repository | string | `"defaultbackend-amd64"` |  |
| global.ingress.defaultbackend.image.tag | string | `"1.5"` |  |
| global.ingress.enabled | bool | `false` | - Enable Nginx ingress controller gateway |
| global.ingress.hosts[0] | string | `"my-host.example.org"` |  |
| global.ingress.loadBalancerEnabled | bool | `false` |  |
| global.ingress.loadBalancerIP | string | `"0.0.0.0"` |  |
| global.ingress.nginx.controller.annotations | object | `{}` | annotations to be addded to ingress Controller |
| global.ingress.nginx.create | bool | `false` | Create Nginx Controller.  True will deploy a controller into your cluster |
| global.ingress.nginx.image | object | `{"digest":"","pullPolicy":"IfNotPresent","registry":"us.gcr.io","repository":"k8s-artifacts-prod/ingress-nginx/controller","tag":"v1.0.0-alpha.2"}` | docker image to be used |
| global.ingress.nginx.objects.annotations | object | `{}` | annotations to be added to ingress Objects |
| global.ingress.tls.enabled | bool | `false` |  |
| global.ingress.tls.secretName | string | `"harness-cert"` |  |
| global.ingress.useSelfSignedCert | bool | `false` |  |
| global.istio | object | `{"enabled":false,"gateway":{"create":true,"port":443,"protocol":"HTTPS"},"hosts":["*"],"strict":false,"tls":{"credentialName":null,"minProtocolVersion":"TLSV1_2","mode":"SIMPLE"},"virtualService":{"gateways":[""],"hosts":[""]}}` | - Enable Istio Gateway |
| global.istio.gateway.create | bool | `true` | Enable to create istio-system gateway |
| global.loadbalancerURL | string | `""` | Fully qualified URL of your loadbalancer (ex: https://www.foo.com) |
| global.mongoSSL | bool | `false` |  |
| global.ngcustomdashboard.enabled | bool | `false` | Enabled will deploy NG Customer Dashboards |
| global.saml.autoaccept | bool | `false` | Enabled will not send invites to email and autoaccepts |
| global.srm.enabled | bool | `false` | Enable to install SRM |
| global.sto.enabled | bool | `false` | Enable to install STO |
| global.storageClassName | string | `""` |  |
| harness.ci.ci-manager.autoscaling.enabled | bool | `true` |  |
| harness.ci.ci-manager.autoscaling.minReplicas | int | `2` |  |
| harness.ci.ci-manager.java.memory | string | `"4096m"` |  |
| harness.ci.ci-manager.resources.limits.cpu | int | `1` |  |
| harness.ci.ci-manager.resources.limits.memory | string | `"6192Mi"` |  |
| harness.ci.ci-manager.resources.requests.cpu | int | `1` |  |
| harness.ci.ci-manager.resources.requests.memory | string | `"6192Mi"` |  |
| harness.infra.postgresql.primary.persistence.size | string | `"200Gi"` |  |
| harness.infra.postgresql.primary.resources.limits.cpu | int | `4` |  |
| harness.infra.postgresql.primary.resources.limits.memory | string | `"8192Mi"` |  |
| harness.infra.postgresql.primary.resources.requests.cpu | int | `4` |  |
| harness.infra.postgresql.primary.resources.requests.memory | string | `"8192Mi"` |  |
| harness.ngcustomdashboard.looker.config.email | string | `"harnessSupport@harness.io"` | email address of the support user, required for initial signup and support |
| harness.ngcustomdashboard.looker.ingress.host | string | `""` | Required if ingress is enabled, Looker requires a separate DNS domain name to function |
| harness.ngcustomdashboard.looker.ingress.tls.secretName | string | `""` |  |
| harness.ngcustomdashboard.looker.resources.limits.cpu | int | `4` |  |
| harness.ngcustomdashboard.looker.resources.limits.memory | string | `"10Gi"` |  |
| harness.ngcustomdashboard.looker.resources.requests.cpu | int | `2` |  |
| harness.ngcustomdashboard.looker.resources.requests.memory | string | `"4Gi"` |  |
| harness.ngcustomdashboard.ng-custom-dashboards.config.lookerHost | string | `""` | hostname of your looker install |
| harness.ngcustomdashboard.ng-custom-dashboards.config.lookerPort | string | `"80"` | port of your looker install |
| harness.ngcustomdashboard.ng-custom-dashboards.config.lookerScheme | string | `"https"` | scheme used for your looker install, http or https |
| harness.ngcustomdashboard.ng-custom-dashboards.resources.limits.cpu | int | `2` |  |
| harness.ngcustomdashboard.ng-custom-dashboards.resources.limits.memory | string | `"1Gi"` |  |
| harness.ngcustomdashboard.ng-custom-dashboards.resources.requests.cpu | int | `1` |  |
| harness.ngcustomdashboard.ng-custom-dashboards.resources.requests.memory | string | `"500Mi"` |  |
| harness.platform.access-control | object | `{"appLogLevel":"INFO","autoscaling":{"enabled":true,"minReplicas":2},"java":{"memory":"512m"},"resources":{"limits":{"cpu":1,"memory":"4096Mi"},"requests":{"cpu":1,"memory":"4096Mi"}}}` | Feature list to enable within platform.  Contact Harness for value |
| harness.platform.change-data-capture.appLogLevel | string | `"INFO"` |  |
| harness.platform.change-data-capture.autoscaling.enabled | bool | `false` |  |
| harness.platform.change-data-capture.autoscaling.minReplicas | int | `2` |  |
| harness.platform.change-data-capture.java.memory | int | `2048` |  |
| harness.platform.change-data-capture.resources.limits.cpu | int | `1` |  |
| harness.platform.change-data-capture.resources.limits.memory | string | `"2880Mi"` |  |
| harness.platform.change-data-capture.resources.requests.cpu | int | `1` |  |
| harness.platform.change-data-capture.resources.requests.memory | string | `"2880Mi"` |  |
| harness.platform.cv-nextgen.autoscaling.enabled | bool | `true` |  |
| harness.platform.cv-nextgen.autoscaling.minReplicas | int | `2` |  |
| harness.platform.cv-nextgen.java.memory | int | `2048` |  |
| harness.platform.cv-nextgen.resources.limits.cpu | int | `1` |  |
| harness.platform.cv-nextgen.resources.limits.memory | string | `"3000Mi"` |  |
| harness.platform.cv-nextgen.resources.requests.cpu | int | `1` |  |
| harness.platform.cv-nextgen.resources.requests.memory | string | `"3000Mi"` |  |
| harness.platform.delegate-proxy.autoscaling.enabled | bool | `false` |  |
| harness.platform.delegate-proxy.replicaCount | int | `1` |  |
| harness.platform.delegate-proxy.resources.limits.cpu | string | `"200m"` |  |
| harness.platform.delegate-proxy.resources.limits.memory | string | `"100Mi"` |  |
| harness.platform.delegate-proxy.resources.requests.cpu | string | `"200m"` |  |
| harness.platform.delegate-proxy.resources.requests.memory | string | `"100Mi"` |  |
| harness.platform.gateway.autoscaling.enabled | bool | `true` |  |
| harness.platform.gateway.autoscaling.minReplicas | int | `2` |  |
| harness.platform.gateway.java.memory | int | `2048` |  |
| harness.platform.gateway.resources.limits.cpu | float | `0.5` |  |
| harness.platform.gateway.resources.limits.memory | string | `"3072Mi"` |  |
| harness.platform.gateway.resources.requests.cpu | float | `0.5` |  |
| harness.platform.gateway.resources.requests.memory | string | `"3072Mi"` |  |
| harness.platform.harness-manager.autoscaling.enabled | bool | `true` |  |
| harness.platform.harness-manager.autoscaling.minReplicas | int | `2` |  |
| harness.platform.harness-manager.external_graphql_rate_limit | string | `"500"` |  |
| harness.platform.harness-manager.java.memory | string | `"2048"` |  |
| harness.platform.harness-manager.resources.limits.cpu | int | `2` |  |
| harness.platform.harness-manager.resources.limits.memory | string | `"3000Mi"` |  |
| harness.platform.harness-manager.resources.requests.cpu | int | `2` |  |
| harness.platform.harness-manager.resources.requests.memory | string | `"3000Mi"` |  |
| harness.platform.le-nextgen.autoscaling.enabled | bool | `true` |  |
| harness.platform.le-nextgen.autoscaling.minReplicas | int | `2` |  |
| harness.platform.le-nextgen.resources.limits.cpu | int | `4` |  |
| harness.platform.le-nextgen.resources.limits.memory | string | `"6132Mi"` |  |
| harness.platform.le-nextgen.resources.requests.cpu | int | `4` |  |
| harness.platform.le-nextgen.resources.requests.memory | string | `"6132Mi"` |  |
| harness.platform.log-service.autoscaling.enabled | bool | `false` |  |
| harness.platform.log-service.replicaCount | int | `1` |  |
| harness.platform.log-service.resources.limits.cpu | int | `1` |  |
| harness.platform.log-service.resources.limits.memory | string | `"3072Mi"` |  |
| harness.platform.log-service.resources.requests.cpu | int | `1` |  |
| harness.platform.log-service.resources.requests.memory | string | `"3072Mi"` |  |
| harness.platform.minio.defaultBuckets | string | `"logs"` |  |
| harness.platform.minio.fullnameOverride | string | `"minio"` |  |
| harness.platform.minio.mode | string | `"standalone"` |  |
| harness.platform.minio.persistence.size | string | `"200Gi"` |  |
| harness.platform.mongodb.args[0] | string | `"--wiredTigerCacheSizeGB=3"` |  |
| harness.platform.mongodb.persistence.size | string | `"200Gi"` |  |
| harness.platform.mongodb.replicaCount | int | `3` |  |
| harness.platform.mongodb.resources.limits.cpu | int | `4` |  |
| harness.platform.mongodb.resources.limits.memory | string | `"8192Mi"` |  |
| harness.platform.mongodb.resources.requests.cpu | int | `4` |  |
| harness.platform.mongodb.resources.requests.memory | string | `"8192Mi"` |  |
| harness.platform.next-gen-ui.autoscaling.enabled | bool | `true` |  |
| harness.platform.next-gen-ui.autoscaling.minReplicas | int | `2` |  |
| harness.platform.next-gen-ui.resources.limits.cpu | float | `0.5` |  |
| harness.platform.next-gen-ui.resources.limits.memory | string | `"512Mi"` |  |
| harness.platform.next-gen-ui.resources.requests.cpu | float | `0.5` |  |
| harness.platform.next-gen-ui.resources.requests.memory | string | `"512Mi"` |  |
| harness.platform.ng-auth-ui.autoscaling.enabled | bool | `true` |  |
| harness.platform.ng-auth-ui.autoscaling.minReplicas | int | `2` |  |
| harness.platform.ng-auth-ui.resources.limits.cpu | float | `0.5` |  |
| harness.platform.ng-auth-ui.resources.limits.memory | string | `"512Mi"` |  |
| harness.platform.ng-auth-ui.resources.requests.cpu | float | `0.5` |  |
| harness.platform.ng-auth-ui.resources.requests.memory | string | `"512Mi"` |  |
| harness.platform.ng-manager.autoscaling.enabled | bool | `true` |  |
| harness.platform.ng-manager.autoscaling.minReplicas | int | `2` |  |
| harness.platform.ng-manager.java.memory | string | `"4096m"` |  |
| harness.platform.ng-manager.resources.limits.cpu | int | `2` |  |
| harness.platform.ng-manager.resources.limits.memory | string | `"6144Mi"` |  |
| harness.platform.ng-manager.resources.requests.cpu | int | `2` |  |
| harness.platform.ng-manager.resources.requests.memory | string | `"6144Mi"` |  |
| harness.platform.pipeline-service.autoscaling.enabled | bool | `true` |  |
| harness.platform.pipeline-service.autoscaling.minReplicas | int | `2` |  |
| harness.platform.pipeline-service.java.memory | string | `"4096m"` |  |
| harness.platform.pipeline-service.resources.limits.cpu | int | `1` |  |
| harness.platform.pipeline-service.resources.limits.memory | string | `"6144Mi"` |  |
| harness.platform.pipeline-service.resources.requests.cpu | int | `1` |  |
| harness.platform.pipeline-service.resources.requests.memory | string | `"6144Mi"` |  |
| harness.platform.platform-service.autoscaling.enabled | bool | `true` |  |
| harness.platform.platform-service.autoscaling.minReplicas | int | `2` |  |
| harness.platform.platform-service.java.memory | string | `"3072m"` |  |
| harness.platform.platform-service.resources.limits.cpu | int | `1` |  |
| harness.platform.platform-service.resources.limits.memory | string | `"4096Mi"` |  |
| harness.platform.platform-service.resources.requests.cpu | int | `1` |  |
| harness.platform.platform-service.resources.requests.memory | string | `"4096Mi"` |  |
| harness.platform.redis.redis.resources.limits.cpu | int | `1` |  |
| harness.platform.redis.redis.resources.limits.memory | string | `"2048Mi"` |  |
| harness.platform.redis.redis.resources.requests.cpu | int | `1` |  |
| harness.platform.redis.redis.resources.requests.memory | string | `"2048Mi"` |  |
| harness.platform.redis.replicaCount | int | `3` |  |
| harness.platform.redis.sentinel.resources.limits.cpu | string | `"100m"` |  |
| harness.platform.redis.sentinel.resources.limits.memory | string | `"200Mi"` |  |
| harness.platform.redis.sentinel.resources.requests.cpu | string | `"100m"` |  |
| harness.platform.redis.sentinel.resources.requests.memory | string | `"200Mi"` |  |
| harness.platform.redis.volumeClaimTemplate.resources.requests.storage | string | `"10Gi"` |  |
| harness.platform.scm-service.autoscaling.enabled | bool | `false` |  |
| harness.platform.scm-service.replicaCount | int | `1` |  |
| harness.platform.scm-service.resources.limits.cpu | float | `0.1` |  |
| harness.platform.scm-service.resources.limits.memory | string | `"512Mi"` |  |
| harness.platform.scm-service.resources.requests.cpu | float | `0.1` |  |
| harness.platform.scm-service.resources.requests.memory | string | `"512Mi"` |  |
| harness.platform.template-service.autoscaling.enabled | bool | `true` |  |
| harness.platform.template-service.autoscaling.minReplicas | int | `2` |  |
| harness.platform.template-service.java.memory | string | `"2048m"` |  |
| harness.platform.template-service.resources.limits.cpu | int | `1` |  |
| harness.platform.template-service.resources.limits.memory | string | `"3000Mi"` |  |
| harness.platform.template-service.resources.requests.cpu | float | `0.7` |  |
| harness.platform.template-service.resources.requests.memory | string | `"3000Mi"` |  |
| harness.platform.ti-service.autoscaling.enabled | bool | `true` |  |
| harness.platform.ti-service.autoscaling.minReplicas | int | `2` |  |
| harness.platform.ti-service.jobresources.limits.cpu | int | `1` |  |
| harness.platform.ti-service.jobresources.limits.memory | string | `"3072Mi"` |  |
| harness.platform.ti-service.jobresources.requests.cpu | int | `1` |  |
| harness.platform.ti-service.jobresources.requests.memory | string | `"3072Mi"` |  |
| harness.platform.ti-service.resources.limits.cpu | int | `1` |  |
| harness.platform.ti-service.resources.limits.memory | string | `"3072Mi"` |  |
| harness.platform.ti-service.resources.requests.cpu | int | `1` |  |
| harness.platform.ti-service.resources.requests.memory | string | `"3072Mi"` |  |
| harness.platform.timescaledb.autoscaling.enabled | bool | `false` |  |
| harness.platform.timescaledb.enabled | bool | `true` |  |
| harness.platform.timescaledb.replicaCount | int | `2` |  |
| harness.platform.timescaledb.resources.limits.cpu | int | `1` |  |
| harness.platform.timescaledb.resources.limits.memory | string | `"2048Mi"` |  |
| harness.platform.timescaledb.resources.requests.cpu | int | `1` |  |
| harness.platform.timescaledb.resources.requests.memory | string | `"2048Mi"` |  |
| harness.platform.timescaledb.storage.capacity | string | `"120Gi"` |  |
| harness.srm.enable-receivers | bool | `true` |  |
| harness.srm.et-collector.autoscaling.enabled | bool | `true` |  |
| harness.srm.et-collector.autoscaling.maxReplicas | int | `3` |  |
| harness.srm.et-collector.et.java.heapSize | string | `"1600m"` |  |
| harness.srm.et-collector.et.redis.enabled | bool | `true` |  |
| harness.srm.et-collector.replicaCount | int | `1` |  |
| harness.srm.et-collector.resources.limits.cpu | int | `1` |  |
| harness.srm.et-collector.resources.limits.memory | string | `"2Gi"` |  |
| harness.srm.et-collector.resources.requests.cpu | string | `"100m"` |  |
| harness.srm.et-collector.resources.requests.memory | string | `"2Gi"` |  |
| harness.srm.et-receiver-agent.autoscaling.enabled | bool | `true` |  |
| harness.srm.et-receiver-agent.autoscaling.maxReplicas | int | `3` |  |
| harness.srm.et-receiver-agent.et.java.heapSize | string | `"1600m"` |  |
| harness.srm.et-receiver-agent.et.redisQueue.type | string | `"agent"` |  |
| harness.srm.et-receiver-agent.name | string | `"et-receiver-agent"` |  |
| harness.srm.et-receiver-agent.replicaCount | int | `1` |  |
| harness.srm.et-receiver-agent.resources.limits.cpu | int | `1` |  |
| harness.srm.et-receiver-agent.resources.limits.memory | string | `"2Gi"` |  |
| harness.srm.et-receiver-agent.resources.requests.cpu | string | `"100m"` |  |
| harness.srm.et-receiver-agent.resources.requests.memory | string | `"2Gi"` |  |
| harness.srm.et-receiver-decompile.autoscaling.enabled | bool | `true` |  |
| harness.srm.et-receiver-decompile.autoscaling.maxReplicas | int | `3` |  |
| harness.srm.et-receiver-decompile.et.java.heapSize | string | `"1600m"` |  |
| harness.srm.et-receiver-decompile.et.redisQueue.type | string | `"decompile"` |  |
| harness.srm.et-receiver-decompile.name | string | `"et-receiver-decompile"` |  |
| harness.srm.et-receiver-decompile.replicaCount | int | `1` |  |
| harness.srm.et-receiver-decompile.resources.limits.cpu | int | `2` |  |
| harness.srm.et-receiver-decompile.resources.limits.memory | string | `"2Gi"` |  |
| harness.srm.et-receiver-decompile.resources.requests.cpu | string | `"100m"` |  |
| harness.srm.et-receiver-decompile.resources.requests.memory | string | `"2Gi"` |  |
| harness.srm.et-receiver-hit.autoscaling.enabled | bool | `true` |  |
| harness.srm.et-receiver-hit.autoscaling.maxReplicas | int | `3` |  |
| harness.srm.et-receiver-hit.et.java.heapSize | string | `"1600m"` |  |
| harness.srm.et-receiver-hit.et.redisQueue.type | string | `"hit"` |  |
| harness.srm.et-receiver-hit.name | string | `"et-receiver-hit"` |  |
| harness.srm.et-receiver-hit.replicaCount | int | `1` |  |
| harness.srm.et-receiver-hit.resources.limits.cpu | int | `1` |  |
| harness.srm.et-receiver-hit.resources.limits.memory | string | `"2Gi"` |  |
| harness.srm.et-receiver-hit.resources.requests.cpu | string | `"100m"` |  |
| harness.srm.et-receiver-hit.resources.requests.memory | string | `"2Gi"` |  |
| harness.srm.et-receiver-sql.autoscaling.enabled | bool | `true` |  |
| harness.srm.et-receiver-sql.autoscaling.maxReplicas | int | `3` |  |
| harness.srm.et-receiver-sql.et.java.heapSize | string | `"1600m"` |  |
| harness.srm.et-receiver-sql.et.redisQueue.type | string | `"sql"` |  |
| harness.srm.et-receiver-sql.name | string | `"et-receiver-sql"` |  |
| harness.srm.et-receiver-sql.replicaCount | int | `1` |  |
| harness.srm.et-receiver-sql.resources.limits.cpu | int | `1` |  |
| harness.srm.et-receiver-sql.resources.limits.memory | string | `"2Gi"` |  |
| harness.srm.et-receiver-sql.resources.requests.cpu | string | `"100m"` |  |
| harness.srm.et-receiver-sql.resources.requests.memory | string | `"2Gi"` |  |
| harness.srm.et-service.et.java.heapSize | string | `"6400m"` |  |
| harness.srm.et-service.et.redis.enabled | bool | `true` |  |
| harness.srm.et-service.replicaCount | int | `1` |  |
| harness.srm.et-service.resources.limits.cpu | int | `2` |  |
| harness.srm.et-service.resources.limits.memory | string | `"8Gi"` |  |
| harness.srm.et-service.resources.requests.cpu | string | `"500m"` |  |
| harness.srm.et-service.resources.requests.memory | string | `"8Gi"` |  |
| harness.sto.sto-core.autoscaling.enabled | bool | `true` |  |
| harness.sto.sto-core.autoscaling.minReplicas | int | `2` |  |
| harness.sto.sto-core.resources.limits.cpu | string | `"500m"` |  |
| harness.sto.sto-core.resources.limits.memory | string | `"500Mi"` |  |
| harness.sto.sto-core.resources.requests.cpu | string | `"500m"` |  |
| harness.sto.sto-core.resources.requests.memory | string | `"500Mi"` |  |
| harness.sto.sto-manager.autoscaling.enabled | bool | `true` |  |
| harness.sto.sto-manager.autoscaling.minReplicas | int | `2` |  |
| harness.sto.sto-manager.resources.limits.cpu | int | `1` |  |
| harness.sto.sto-manager.resources.limits.memory | string | `"3072Mi"` |  |
| harness.sto.sto-manager.resources.requests.cpu | int | `1` |  |
| harness.sto.sto-manager.resources.requests.memory | string | `"3072Mi"` |  |

