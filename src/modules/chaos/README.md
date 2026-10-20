## Harness Chaos Chart

A Helm chart for harness chaos module

![Version: 0.48.0](https://img.shields.io/badge/Version-0.48.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.6.0](https://img.shields.io/badge/AppVersion-0.6.0-informational?style=flat-square)

## Usage

Use the following dependency to add this chart repository to your Helm installation:

```
dependencies:
    - name: harness-chaos
      repository: https://harness.github.io/helm-chaos
      version: <no value>
```

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| chaos-k8s-ifs.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_K8S_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-k8s-ifs.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-k8s-ifs.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| chaos-k8s-ifs.secrets.smpSharedKubernetesSecrets[0].keys.JWT_SECRET | string | `"jwtAuthSecret"` |  |
| chaos-k8s-ifs.secrets.smpSharedKubernetesSecrets[0].keys.LOAD_TEST_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-k8s-ifs.secrets.smpSharedKubernetesSecrets[0].keys.LOG_SERVICE_TOKEN | string | `"logServiceToken"` |  |
| chaos-k8s-ifs.secrets.smpSharedKubernetesSecrets[0].keys.NG_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-k8s-ifs.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| chaos-linux-ifc.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_LINUX_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-linux-ifc.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-linux-ifc.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| chaos-linux-ifc.secrets.smpSharedKubernetesSecrets[0].keys.JWT_SECRET | string | `"jwtAuthSecret"` |  |
| chaos-linux-ifc.secrets.smpSharedKubernetesSecrets[0].keys.LOG_SERVICE_TOKEN | string | `"logServiceToken"` |  |
| chaos-linux-ifc.secrets.smpSharedKubernetesSecrets[0].keys.NG_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-linux-ifc.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| chaos-linux-ifs.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_LINUX_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-linux-ifs.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| chaos-linux-ifs.secrets.smpSharedKubernetesSecrets[0].keys.JWT_SECRET | string | `"jwtAuthSecret"` |  |
| chaos-linux-ifs.secrets.smpSharedKubernetesSecrets[0].keys.LOG_SERVICE_TOKEN | string | `"logServiceToken"` |  |
| chaos-linux-ifs.secrets.smpSharedKubernetesSecrets[0].keys.NG_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-linux-ifs.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| chaos-machine-ifc.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MACHINE_IFC_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-machine-ifc.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MACHINE_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-machine-ifc.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-machine-ifc.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| chaos-machine-ifc.secrets.smpSharedKubernetesSecrets[0].keys.JWT_SECRET | string | `"jwtAuthSecret"` |  |
| chaos-machine-ifc.secrets.smpSharedKubernetesSecrets[0].keys.LOG_SERVICE_TOKEN | string | `"logServiceToken"` |  |
| chaos-machine-ifc.secrets.smpSharedKubernetesSecrets[0].keys.NG_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-machine-ifc.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| chaos-machine-ifs.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MACHINE_IFC_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-machine-ifs.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MACHINE_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-machine-ifs.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| chaos-machine-ifs.secrets.smpSharedKubernetesSecrets[0].keys.JWT_SECRET | string | `"jwtAuthSecret"` |  |
| chaos-machine-ifs.secrets.smpSharedKubernetesSecrets[0].keys.LOG_SERVICE_TOKEN | string | `"logServiceToken"` |  |
| chaos-machine-ifs.secrets.smpSharedKubernetesSecrets[0].keys.NG_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-machine-ifs.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_K8S_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_LINUX_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MACHINE_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.JWT_SECRET | string | `"jwtAuthSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.LOG_SERVICE_TOKEN | string | `"logServiceToken"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.NG_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.PIPELINE_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.RT_AGENT_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].keys.SERVICE_DISCOVERY_TOKEN | string | `"jwtNextGenManagerSecret"` |  |
| chaos-manager.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_K8S_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_LINUX_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MACHINE_IFS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.JWT_SECRET | string | `"jwtAuthSecret"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.LOAD_TEST_MANAGER_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.LOG_SERVICE_TOKEN | string | `"logServiceToken"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.NG_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].keys.PIPELINE_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| load-test-manager.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| rt-agent.secrets.smpSharedKubernetesSecrets[0].keys.AI_AGENT_GATEWAY_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| rt-agent.secrets.smpSharedKubernetesSecrets[0].keys.CHAOS_MANAGER_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| rt-agent.secrets.smpSharedKubernetesSecrets[0].keys.LOG_SERVICE_TOKEN | string | `"logServiceToken"` |  |
| rt-agent.secrets.smpSharedKubernetesSecrets[0].keys.PIPELINE_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| rt-agent.secrets.smpSharedKubernetesSecrets[0].keys.SERVICE_DISCOVERY_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| rt-agent.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
