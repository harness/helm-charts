# code

![Version: 0.48.0](https://img.shields.io/badge/Version-0.48.0-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.25.0](https://img.shields.io/badge/AppVersion-1.25.0-informational?style=flat-square)

A Helm chart for Harness CODE

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | code-api | 1.106.2 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | code-githa | 1.106.0 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | code-gitrpc | 1.106.0 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | code-search | 1.106.0 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | code-ui | 1.80.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| code-api.autoai.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code-api.autoai.postgres.image.tag | string | `"14.20-debian"` |  |
| code-api.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code-api.postgres.image.tag | string | `"14.20-debian"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.GITNESS_REGISTRY_HTTP_SECRET | string | `"gitnessRegistryHttpSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.GITNESS_WEBHOOK_INTERNAL_SECRET | string | `"harnessCodeWebhookSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_JWT_BEARER_SECRET | string | `"jwtAuthSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_ACL_CLIENT_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_AIFOUNDATION_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_CDE_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_CIMANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_CODESEARCH_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_DEFAULT_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_GITHA_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_IACM_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_IAC_SERVER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_IDENTITY_JWT_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_IDP_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_IRO_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_NGMANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_OPA_CLIENT_JWT_SECRET | string | `"jwtAuthSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_REMOTEAUTH_JWT_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_RESOURCE_GROUP_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_SEMANTIC_SEARCH_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_SSCA_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_STO_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-api.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| code-githa.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code-githa.postgres.image.tag | string | `"14.20-debian"` |  |
| code-githa.secrets.smpSharedKubernetesSecrets[0].keys.GITHA_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-githa.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |
| code-gitrpc.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code-gitrpc.postgres.image.tag | string | `"14.20-debian"` |  |
| code-search.postgres.image.repository | string | `"harnesssecure/postgresql"` |  |
| code-search.postgres.image.tag | string | `"14.20-debian"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_CIMANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_CODESEARCH_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_CODE_API_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_IACM_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_IAC_SERVER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_IDENTITY_JWT_SECRET | string | `"jwtIdentityServiceSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_IDP_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_MANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_NGMANAGER_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_OPA_CLIENT_JWT_SECRET | string | `"jwtAuthSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_RESOURCE_GROUP_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_SEMANTIC_SEARCH_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].keys.HARNESS_SERVICES_STO_JWT_SECRET | string | `"jwtNextGenManagerSecret"` |  |
| code-search.secrets.smpSharedKubernetesSecrets[0].secretName | string | `"harness-shared-secrets"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
