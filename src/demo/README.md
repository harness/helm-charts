# harness-demo

![Version: 0.2.9](https://img.shields.io/badge/Version-0.2.9-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 1.0.76019](https://img.shields.io/badge/AppVersion-1.0.76019-informational?style=flat-square)

Helm Chart for deploying Harness in Demo configuration

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| file://ci | ci | 0.1.x |
| file://platform | platform | 0.1.x |
| file://sto | sto | 0.1.x |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| ci.enabled | bool | `true` |  |
| global.airgap | string | `"false"` |  |
| global.ha | bool | `false` |  |
| global.imageRegistry | string | `""` |  |
| global.loadbalancerURL | string | `""` |  |
| global.mongoSSL | bool | `false` |  |
| global.storageClassName | string | `""` |  |
| istio.enabled | bool | `true` |  |
| istio.gateway.create | bool | `true` |  |
| istio.gateway.port | int | `443` |  |
| istio.gateway.protocol | string | `"HTTPS"` |  |
| istio.hosts[0] | string | `"*"` |  |
| istio.tls.credentialName | string | `nil` |  |
| istio.tls.minProtocolVersion | string | `"TLSV1_2"` |  |
| istio.tls.mode | string | `"SIMPLE"` |  |
| istio.virtualService.hosts[0] | string | `""` |  |
| platform.harness-manager.features | string | `"SECURITY,SECURITY_STAGE,STO_CI_PIPELINE_SECURITY,STO_API_V2,LDAP_SSO_PROVIDER,ASYNC_ARTIFACT_COLLECTION,JIRA_INTEGRATION,AUDIT_TRAIL_UI,GDS_TIME_SERIES_SAVE_PER_MINUTE,STACKDRIVER_SERVICEGUARD,BATCH_SECRET_DECRYPTION,TIME_SERIES_SERVICEGUARD_V2,TIME_SERIES_WORKFLOW_V2,CUSTOM_DASHBOARD,GRAPHQL,CV_FEEDBACKS,LOGS_V2_247,UPGRADE_JRE,CDNG_ENABLED,NEXT_GEN_ENABLED,LOG_STREAMING_INTEGRATION,CING_ENABLED,NG_HARNESS_APPROVAL,GIT_SYNC_NG,NG_SHOW_DELEGATE,NG_CG_TASK_ASSIGNMENT_ISOLATION,CI_OVERVIEW_PAGE,AZURE_CLOUD_PROVIDER_VALIDATION_ON_DELEGATE,TERRAFORM_AWS_CP_AUTHENTICATION,NG_TEMPLATES,NEW_DEPLOYMENT_FREEZE,HELM_CHART_AS_ARTIFACT,RESOLVE_DEPLOYMENT_TAGS_BEFORE_EXECUTION,WEBHOOK_TRIGGER_AUTHORIZATION,GITHUB_WEBHOOK_AUTHENTICATION,CUSTOM_MANIFEST,GIT_ACCOUNT_SUPPORT,AZURE_WEBAPP,PRUNE_KUBERNETES_RESOURCES,LDAP_GROUP_SYNC_JOB_ITERATOR,POLLING_INTERVAL_CONFIGURABLE,APPLICATION_DROPDOWN_MULTISELECT,USER_GROUP_AS_EXPRESSION,RESOURCE_CONSTRAINT_SCOPE_PIPELINE_ENABLED,ENABLE_DEFAULT_NG_EXPERIENCE_FOR_ONPREM"` |  |
| platform.harness-secrets.mongodb.password | string | `""` |  |
| platform.harness-secrets.postgresdb.adminPassword | string | `""` |  |
| platform.harness-secrets.sto.AppAuditJWTSecret | string | `""` |  |
| platform.harness-secrets.sto.appHarnessToken | string | `""` |  |
| platform.harness-secrets.timescaledb.adminPassword | string | `""` |  |
| platform.harness-secrets.timescaledb.postgresPassword | string | `""` |  |
| platform.harness-secrets.timescaledb.standbyPassword | string | `""` |  |
| platform.log-service.s3.accessKeyId | string | `""` |  |
| platform.log-service.s3.bucketName | string | `""` |  |
| platform.log-service.s3.endpoint | string | `""` |  |
| platform.log-service.s3.region | string | `""` |  |
| platform.log-service.s3.secretAccessKey | string | `""` |  |
| platform.minio.mode | string | `"standalone"` |  |
| platform.minio.rootPassword | string | `""` |  |
| platform.minio.rootUser | string | `""` |  |
| platform.mongo.secrets.ca_pem | string | `""` |  |
| platform.mongo.secrets.client_pem | string | `""` |  |
| platform.mongo.secrets.mongodb_pem | string | `""` |  |
| platform.platform-service.smtp.host | string | `""` |  |
| platform.platform-service.smtp.password | string | `""` |  |
| platform.platform-service.smtp.port | string | `""` |  |
| platform.platform-service.smtp.ssl | bool | `true` |  |
| platform.platform-service.smtp.user | string | `""` |  |
| sto.enabled | bool | `true` |  |

