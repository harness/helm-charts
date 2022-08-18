# Helm Charts for Harness
This repository consists of Harness Helm charts for On-premise Customers.

## Usage

[Helm](https://helm.sh) must be installed to use the charts.
Please refer to Helm's [documentation](https://helm.sh/docs/) to get started.

Once Helm is set up properly, add the repo as follows:

```console
$ helm repo add harness https://harness.github.io/helm-charts
```

## Installing the chart
Create a namespace for your installation
```
kubectl create namespace <namespace>
```
Download the override.yaml file from https://github.com/harness/helm-charts/override.yaml and put relevant configurations in it.

Installing the helm chart
```
$  helm install my-release harness/harness-demo -n test -f override.yaml 
```
### Accessing the application
Please refer the following documentation: https://docs.harness.io/article/gqoqinkhck-install-harness-self-managed-enterprise-edition-with-helm#create_your_harness_account 
## Upgrading the chart
Find out the release-name using
```
helm ls -n <namespace>
```
Get the data from previous release
```
helm get values my-release > old_values.yaml
```
Then change the fields in old_values.yaml file as required. Now update the chart using
Helm Upgrade
```
$ helm upgrade my-release demo/ -n <namespace> -f old_values.yaml
```

## Uninstalling the Chart

To uninstall/delete the `my-release` deployment:

```console
$ helm uninstall my-release -n <namespace>
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Parameters

### Global parameters

| Name                      | Description                                     | Value |
| ------------------------- | ----------------------------------------------- | ----- |
| `global.airgap`  | Settings for Airgapped customer                          | `boolean` |
| `global.ha`    | Settings for High Availability                             | `boolean`  |
| `global.imageRegistry`    | Global Docker image registry                    | `""`  |
| `global.loadbalancerURL`  | Fully qualified name of cluster                 | `""`  |
| `global.mongoSSL` | Global setting for mongoSSL                             | `[]`  |
| `global.storageClassName` | Global StorageClass for Persistent Volume(s)    | `""`  |


