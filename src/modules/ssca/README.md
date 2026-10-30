# ssca

![Version: 0.48.0](https://img.shields.io/badge/Version-0.48.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.16.0](https://img.shields.io/badge/AppVersion-1.16.0-informational?style=flat-square)

A Helm chart for Harness SSCA

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | component-analysis-service | 1.21.1 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | component-service | 1.23.2 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | ssca-manager | 1.74.5 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | ssca-ui | 0.60.2 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].keys.COMPONENT_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].keys.GENAI_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_CODE_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].keys.JWT_AUTH_SECRET | string | `"jwtAuthSecret"` |  |
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].keys.NG_MANAGER_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].keys.POLICY_MGMT_SERVICE_SECRET | string | `"jwtAuthSecret"` |  |
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].keys.SECRET_CONNECTOR_SERVICE_SECRET | string | `"secretConnectorServiceSecret"` |  |
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].keys.SSCA_MANAGER_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| component-analysis-service.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| component-service.config.EOL_DISABLE_MAVEN_EOL | string | `"true"` |  |
| component-service.secrets.smpSharedKubernetesSecrets[0].keys.JWT_AUTH_SECRET | string | `"jwtAuthSecret"` |  |
| component-service.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| component-service.secrets.smpSharedKubernetesSecrets[0].keys.NG_MANAGER_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| component-service.secrets.smpSharedKubernetesSecrets[0].keys.POLICY_MGMT_SERVICE_SECRET | string | `"jwtAuthSecret"` |  |
| component-service.secrets.smpSharedKubernetesSecrets[0].keys.SSCA_MANAGER_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| component-service.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| ssca-manager.config.RHS_ENABLED | string | `"false"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.ACCESS_CONTROL_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.COMPONENT_ANALYSIS_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.COMPONENT_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.GENAI_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_CODE_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.JWT_AUTH_SECRET | string | `"jwtAuthSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.JWT_IDENTITY_SERVICE_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.NG_MANAGER_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.PIPELINE_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.PLATFORM_CONFIG_SERVICE_SECRET | string | `"platformConfigServiceSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.POLICY_MGMT_SERVICE_SECRET | string | `"jwtAuthSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.RESOURCE_HIERARCHY_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.SECRET_CONNECTOR_SERVICE_SECRET | string | `"secretConnectorServiceSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].keys.SSCA_MANAGER_SERVICE_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| ssca-manager.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
