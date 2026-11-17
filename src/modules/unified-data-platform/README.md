# unified-data-platform

![Version: 0.47.5](https://img.shields.io/badge/Version-0.47.5-informational?style=flat-square) ![Type: application](https://img.shields.io/badge/Type-application-informational?style=flat-square) ![AppVersion: 0.1.0](https://img.shields.io/badge/AppVersion-0.1.0-informational?style=flat-square)

A Helm chart for Harness Unified Data Platform (UDP) services

## Requirements

| Repository | Name | Version |
|------------|------|---------|
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | config-service | 0.1.170 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | dashboard-ui | 1.89.0 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | onboarding-service | 0.14.214 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | query-service | 0.75.3 |
| oci://us-west1-docker.pkg.dev/gcr-prod/harness-helm-artifacts | schema-service | 0.23.0 |

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| config-service.configService.kafka.enabled | bool | `false` |  |
| config-service.configService.kafka.tlsTruststoreSecret | string | `""` |  |
| config-service.configService.kafka.tlsUserSecret | string | `""` |  |
| config-service.createSmpSecret | bool | `true` |  |
| config-service.image.imagePullSecrets | list | `[]` |  |
| config-service.secretValues.AUTHZ_SERVICE_SECRET | string | `"IC04LYMBf1lDP5oeY4hupxd4HJhLmN6azUku3xEbeE3SUx5G3ZYzhbiwVtK4i7AmqyU9OZkwB4v8E9qM"` |  |
| config-service.secretValues.UDP_INTERNAL_SECRET | string | `"x6ee13sGJdtzccBJhgHfMXtMTE37EBJ9wIrXH01OUrOcRfbwPLo5oaSdplXnGlAq"` |  |
| dashboard-ui.image.imagePullSecrets | list | `[]` |  |
| onboarding-service.createSmpSecret | bool | `true` |  |
| onboarding-service.image.imagePullSecrets | list | `[]` |  |
| onboarding-service.onboardingService.appConfig.onboarding-service.provider-groups.include[0].name | string | `"02_smp"` |  |
| onboarding-service.onboardingService.kafka.enabled | bool | `false` |  |
| onboarding-service.onboardingService.kafka.tlsTruststoreSecret | string | `""` |  |
| onboarding-service.onboardingService.kafka.tlsUserSecret | string | `""` |  |
| onboarding-service.onboardingService.serviceAccount.create | bool | `true` |  |
| onboarding-service.onboardingService.serviceAccount.name | string | `"onboarding-service"` |  |
| onboarding-service.secretValues.UDP_INTERNAL_SECRET | string | `"x6ee13sGJdtzccBJhgHfMXtMTE37EBJ9wIrXH01OUrOcRfbwPLo5oaSdplXnGlAq"` |  |
| query-service.createSmpSecret | bool | `true` |  |
| query-service.image.imagePullSecrets | list | `[]` |  |
| query-service.queryService.appConfig.grpcClients.config-service.cache-duration | string | `"15m"` |  |
| query-service.queryService.appConfig.grpcClients.schema-service.cache-duration | string | `"15m"` |  |
| query-service.queryService.appConfig.queryService.data.connections | list | `[]` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[0].data-kind | string | `"*"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[0].data-type | string | `"sei*"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[10].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[10].data-type | string | `"ccm:unit_cost"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[11].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[11].data-type | string | `"udp:ccm:bq:cluster_data"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[12].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[12].data-type | string | `"ccm:cluster_data"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[13].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[13].data-type | string | `"ccm:cluster_data_labels"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[14].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[14].data-type | string | `"udp:ccm:bq:cloud_provider_entity_tags"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[15].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[15].data-type | string | `"ccm:cloud_provider_entity_tags_labels"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[16].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[16].data-type | string | `"udp:ccm:bq:aws_ebs_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[17].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[17].data-type | string | `"ccm:aws_ebs_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[18].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[18].data-type | string | `"udp:ccm:bq:aws_ebs_inventory_metrics"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[19].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[19].data-type | string | `"ccm:aws_ebs_inventory_metrics"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[1].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[1].data-type | string | `"licensing:billing_metrics_config"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[20].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[20].data-type | string | `"udp:ccm:bq:aws_ec2_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[21].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[21].data-type | string | `"ccm:aws_ec2_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[22].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[22].data-type | string | `"udp:ccm:bq:aws_ec2_inventory_metric"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[23].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[23].data-type | string | `"ccm:aws_ec2_inventory_metric"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[24].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[24].data-type | string | `"udp:ccm:bq:aws_rds_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[25].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[25].data-type | string | `"ccm:aws_rds_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[26].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[26].data-type | string | `"udp:ccm:bq:aws_rds_inventory_metric"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[27].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[27].data-type | string | `"ccm:aws_rds_inventory_metric"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[28].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[28].data-type | string | `"udp:ccm:bq:azure_vm_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[29].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[29].data-type | string | `"ccm:azure_vm_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[2].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[2].data-type | string | `"udp:ccm:bq:unified_table"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[30].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[30].data-type | string | `"udp:ccm:bq:azure_vm_inventory_metric"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[31].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[31].data-type | string | `"ccm:azure_vm_inventory_metric"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[32].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[32].data-type | string | `"udp:ccm:bq:gcp_disk_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[33].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[33].data-type | string | `"ccm:gcp_disk_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[34].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[34].data-type | string | `"udp:ccm:bq:gcp_instance_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[35].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[35].data-type | string | `"ccm:gcp_instance_inventory"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[36].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[36].data-type | string | `"ccm:object_storage"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[37].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[37].data-type | string | `"ssca:component_metadata"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[38].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[38].data-type | string | `"ssca:component_vulnerability"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[39].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[39].data-type | string | `"ssca:component_malicious_report"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[3].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[3].data-type | string | `"ccm:unified"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[40].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[40].data-type | string | `"sto:cve"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[41].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[41].data-type | string | `"sto:product"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[42].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[42].data-type | string | `"iacm:provider_connector"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[43].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[43].data-type | string | `"platform:user_metadata"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[44].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[44].data-type | string | `"licensing:billing_job_checkpoint"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[45].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[45].data-type | string | `"licensing:billing_metric_details"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[46].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[46].data-type | string | `"platform:ng_user"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[47].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[47].data-type | string | `"platform:ng_users"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[48].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[48].data-type | string | `"l:udp_native:cd:cd_stage_execution"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[49].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[49].data-type | string | `"cd:cd_stage_execution_info"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[4].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[4].data-type | string | `"udp:ccm:bq:unified_table_monthly"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[50].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[50].data-type | string | `"l:udp_native:ssca:component_enrichment"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[51].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[51].data-type | string | `"view:ssca:smp_component_enrichment"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[52].data-kind | string | `"DATA_KIND_ENTITY"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[52].data-type | string | `"ci:gradle_cache_metrics_raw"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[53].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[53].data-type | string | `"ci:gradle_cache_metrics"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[5].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[5].data-type | string | `"ccm:unified_aggregated"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[6].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[6].data-type | string | `"udp:ccm:bq:asset_governance"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[7].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[7].data-type | string | `"ccm:asset_governance"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[8].data-kind | string | `"DATA_KIND_EVENT"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[8].data-type | string | `"udp:ccm:bq:unit_cost_metric"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[9].data-kind | string | `"DATA_KIND_VIEW"` |  |
| query-service.queryService.appConfig.queryService.features.tenant-filter.tenant-filter-exclusions[9].data-type | string | `"ccm:unit_cost_metric"` |  |
| query-service.queryService.appConfig.queryService.kafka.enabled | bool | `false` |  |
| query-service.queryService.appConfig.queryService.kafka.tlsTruststoreSecret | string | `""` |  |
| query-service.queryService.appConfig.queryService.kafka.tlsUserSecret | string | `""` |  |
| query-service.queryService.connectionSecrets | list | `[]` |  |
| query-service.queryService.serviceAccount.name | string | `"default"` |  |
| query-service.secretValues.AUTHZ_SERVICE_SECRET | string | `"IC04LYMBf1lDP5oeY4hupxd4HJhLmN6azUku3xEbeE3SUx5G3ZYzhbiwVtK4i7AmqyU9OZkwB4v8E9qM"` |  |
| query-service.secretValues.UDP_INTERNAL_SECRET | string | `"x6ee13sGJdtzccBJhgHfMXtMTE37EBJ9wIrXH01OUrOcRfbwPLo5oaSdplXnGlAq"` |  |
| schema-service.createSmpSecret | bool | `true` |  |
| schema-service.image.imagePullSecrets | list | `[]` |  |
| schema-service.schemaService.kafka.enabled | bool | `false` |  |
| schema-service.schemaService.kafka.tlsTruststoreSecret | string | `""` |  |
| schema-service.schemaService.kafka.tlsUserSecret | string | `""` |  |
| schema-service.secretValues.AUTHZ_SERVICE_SECRET | string | `"IC04LYMBf1lDP5oeY4hupxd4HJhLmN6azUku3xEbeE3SUx5G3ZYzhbiwVtK4i7AmqyU9OZkwB4v8E9qM"` |  |
| schema-service.secretValues.UDP_INTERNAL_SECRET | string | `"x6ee13sGJdtzccBJhgHfMXtMTE37EBJ9wIrXH01OUrOcRfbwPLo5oaSdplXnGlAq"` |  |

----------------------------------------------
Autogenerated from chart metadata using [helm-docs v1.14.2](https://github.com/norwoodj/helm-docs/releases/v1.14.2)
