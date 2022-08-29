## Harness Helm Charts

Helm Chart for deploying Harness in Prod configuration

![Version: 0.2.20](https://img.shields.io/badge/Version-0.2.20-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.76019](https://img.shields.io/badge/AppVersion-1.0.76019-informational?style=flat-square)

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
$ helm repo add harness https://harness.github.io/helm-charts
```
## Requirements
* Istio installed within kubernetes, for reference: https://istio.io/latest/docs/setup/getting-started/

## Installing the chart
Create a namespace for your installation
```
$ kubectl create namespace <namespace>
```

Create your override.yaml file with your envirionment settings:

```
## Global Settings
global:
  # -- Enable for complete airgap environment
  airgap: false
  ha: true
  # -- Global Docker image registry
  imageRegistry: ""
  # -- Fully qualified URL of your loadbalancer (ex: https://www.foo.com)
  loadbalancerURL: ""
  mongoSSL: false
  storageClassName: ""

## Platform Settings
harness:
  platform:
    # -- Feature list to enable within platform.  Contact Harness for value
    access-control:
      autoscaling:
        enabled: true
        minReplicas: 2
      appLogLevel: INFO
      java:
        memory: 512m
      resources:
        limits:
          cpu: 1
          memory: 4096Mi
        requests:
          cpu: 1
          memory: 4096Mi

    change-data-capture:
      appLogLevel: INFO
      java:
        memory: 2048
      resources:
        limits:
          cpu: 1
          memory: 2880Mi
        requests:
          cpu: 1
          memory: 2880Mi
      autoscaling:
        enabled: false
        minReplicas: 2

    cv-nextgen:
      java:
        memory: 2048
      resources:
        limits:
          cpu: 1
          memory: 3000Mi
        requests:
          cpu: 1
          memory: 3000Mi
      autoscaling:
        enabled: true
        minReplicas: 2

    delegate-proxy:
      resources:
        limits:
          cpu: 200m
          memory: 100Mi
        requests:
          cpu: 200m
          memory: 100Mi
      autoscaling:
        enabled: false
      replicaCount: 1

    gateway:
      java:
        memory: 2048
      resources:
        limits:
          cpu: 0.5
          memory: 3072Mi
        requests:
          cpu: 0.5
          memory: 3072Mi
      autoscaling:
        enabled: true
        minReplicas: 2

    harness-manager:
      external_graphql_rate_limit: "500"
      autoscaling:
        enabled: true
        minReplicas: 2
      java:
        memory: "2048"
      resources:
        limits:
          cpu: 2
          memory: 3000Mi
        requests:
          cpu: 2
          memory: 3000Mi

    le-nextgen:
      autoscaling:
        enabled: true
        minReplicas: 2
      resources:
        limits:
          cpu: 4
          memory: 6132Mi
        requests:
          cpu: 4
          memory: 6132Mi

    log-service:
      autoscaling:
        enabled: false
      replicaCount: 1
      resources:
        limits:
          cpu: 1
          memory: 3072Mi
        requests:
          cpu: 1
          memory: 3072Mi
    minio:
      fullnameOverride: "minio"
      mode: standalone
      defaultBuckets: "logs"
      persistence:
        size: 200Gi

    mongodb:
      replicaCount: 3
      resources:
        limits:
          cpu: 4
          memory: 8192Mi
        requests:
          cpu: 4
          memory: 8192Mi
      persistence:
        size: 200Gi

    next-gen-ui:
      autoscaling:
        enabled: true
        minReplicas: 2
      resources:
        limits:
          cpu: 0.5
          memory: 512Mi
        requests:
          cpu: 0.5
          memory: 512Mi

    ng-auth-ui:
      autoscaling:
        enabled: true
        minReplicas: 2
      resources:
        limits:
          cpu: 0.5
          memory: 512Mi
        requests:
          cpu: 0.5
          memory: 512Mi

    ng-manager:
      autoscaling:
        enabled: true
        minReplicas: 2
      java:
        memory: "4096m"
      resources:
        limits:
          cpu: 2
          memory: 6144Mi
        requests:
          cpu: 2
          memory: 6144Mi

    pipeline-service:
      autoscaling:
        enabled: true
        minReplicas: 2
      java:
        memory: "4096m"
      resources:
        limits:
          cpu: 1
          memory: 6144Mi
        requests:
          cpu: 1
          memory: 6144Mi

    platform-service:
      autoscaling:
        enabled: true
        minReplicas: 2
      java:
        memory: "3072m"
      resources:
        limits:
          cpu: 1
          memory: 4096Mi
        requests:
          cpu: 1
          memory: 4096Mi

    redis:
      redis:
        resources:
          limits:
            cpu: 1
            memory: 2048Mi
          requests:
            cpu: 1
            memory: 2048Mi
      replicaCount: 3
      sentinel:
        resources:
          limits:
            cpu: 100m
            memory: 200Mi
          requests:
            cpu: 100m
            memory: 200Mi
      volumeClaimTemplate:
        resources:
          requests:
            storage: 10Gi

    scm-service:
      autoscaling:
        enabled: false
      replicaCount: 1
      resources:
        limits:
          cpu: 0.1
          memory: 512Mi
        requests:
          cpu: 0.1
          memory: 512Mi

    template-service:
      autoscaling:
        enabled: true
        minReplicas: 2
      java:
        memory: "2048m"
      replicaCount: 1
      resources:
        limits:
          cpu: 0.5
          memory: 3000Mi
        requests:
          cpu: 0.5
          memory: 3000Mi

    ti-service:
      autoscaling:
        enabled: true
        minReplicas: 2
      jobresources:
        limits:
          cpu: 1
          memory: 3072Mi
        requests:
          cpu: 1
          memory: 3072Mi
      resources:
        limits:
          cpu: 1
          memory: 3072Mi
        requests:
          cpu: 1
          memory: 3072Mi

    timescaledb:
      autoscaling:
        enabled: false
      replicaCount: 2
      resources:
        limits:
          cpu: 1
          memory: 2048Mi
        requests:
          cpu: 1
          memory: 2048Mi
      storage:
        capacity: 120Gi

  ci:
  # -- Enable to install CI
    enabled: true
    ci-manager:
      autoscaling:
        enabled: true
        minReplicas: 2
      java:
        memory: "4096m"
      resources:
        limits:
          cpu: 1
          memory: 6192Mi
        requests:
          cpu: 1
          memory: 6192Mi

  sto:
  # -- Enable to install STO
    enabled: true
    sto-core:
      autoscaling:
        enabled: true
        minReplicas: 2
      resources:
        limits:
          cpu: 500m
          memory: 500Mi
        requests:
          cpu: 500m
          memory: 500Mi
    sto-manager:
      autoscaling:
        enabled: true
        minReplicas: 2
      resources:
        limits:
          cpu: 1
          memory: 3072Mi
        requests:
          cpu: 1
          memory: 3072Mi

istio:
  enabled: true
  gateway:
    # -- Enable to create istio-system gateway
    create: true
    port: 443
    protocol: HTTPS
  hosts:
    - '*'
  tls:
    credentialName:
    minProtocolVersion: TLSV1_2
    mode: SIMPLE
  virtualService:
    gateways:
      - ""
    hosts:
      - ""

```

Installing the helm chart
```
$  helm install my-release harness/harness-prod -n <namespace> -f override.yaml
```

### Accessing the application
Please refer the following documentation: https://docs.harness.io/article/gqoqinkhck-install-harness-self-managed-enterprise-edition-with-helm#create_your_harness_account
## Upgrading the chart
Find out the release-name using
```
$ helm ls -n <namespace>
```
Get the data from previous release
```
$ helm get values my-release > old_values.yaml
```
Then change the fields in old_values.yaml file as required. Now update the chart using
Helm Upgrade
```
$ helm upgrade my-release harness/harness-demo -n <namespace> -f old_values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm uninstall my-release -n <namespace>
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| global.airgap | bool | `false` | Enable for complete airgap environment |
| global.ha | bool | `true` |  |
| global.imageRegistry | string | `""` | Global Docker image registry |
| global.loadbalancerURL | string | `""` | Fully qualified URL of your loadbalancer (ex: https://www.foo.com) |
| global.mongoSSL | bool | `false` |  |
| global.storageClassName | string | `""` |  |
| harness.ci.ci-manager.autoscaling.enabled | bool | `true` |  |
| harness.ci.ci-manager.autoscaling.minReplicas | int | `2` |  |
| harness.ci.ci-manager.java.memory | string | `"4096m"` |  |
| harness.ci.ci-manager.resources.limits.cpu | int | `1` |  |
| harness.ci.ci-manager.resources.limits.memory | string | `"6192Mi"` |  |
| harness.ci.ci-manager.resources.requests.cpu | int | `1` |  |
| harness.ci.ci-manager.resources.requests.memory | string | `"6192Mi"` |  |
| harness.ci.enabled | bool | `true` | Enable to install CI |
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
| harness.platform.template-service.replicaCount | int | `1` |  |
| harness.platform.template-service.resources.limits.cpu | float | `0.5` |  |
| harness.platform.template-service.resources.limits.memory | string | `"3000Mi"` |  |
| harness.platform.template-service.resources.requests.cpu | float | `0.5` |  |
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
| harness.platform.timescaledb.replicaCount | int | `2` |  |
| harness.platform.timescaledb.resources.limits.cpu | int | `1` |  |
| harness.platform.timescaledb.resources.limits.memory | string | `"2048Mi"` |  |
| harness.platform.timescaledb.resources.requests.cpu | int | `1` |  |
| harness.platform.timescaledb.resources.requests.memory | string | `"2048Mi"` |  |
| harness.platform.timescaledb.storage.capacity | string | `"120Gi"` |  |
| harness.sto.enabled | bool | `true` | Enable to install STO |
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
| istio.enabled | bool | `true` |  |
| istio.gateway.create | bool | `true` | Enable to create istio-system gateway |
| istio.gateway.port | int | `443` |  |
| istio.gateway.protocol | string | `"HTTPS"` |  |
| istio.hosts[0] | string | `"*"` |  |
| istio.tls.credentialName | string | `nil` |  |
| istio.tls.minProtocolVersion | string | `"TLSV1_2"` |  |
| istio.tls.mode | string | `"SIMPLE"` |  |
| istio.virtualService.gateways[0] | string | `""` |  |
| istio.virtualService.hosts[0] | string | `""` |  |

