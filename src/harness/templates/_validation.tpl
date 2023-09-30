{{/* Generates validation error message for restructured values/override
{{ include "restructuredValuesValidationErrMessage" (dict "serviceName" "foo" "srcLocation" "bar1.foo" "destLocation" "bar2.foo") }}
*/}}
{{- define "restructuredValuesValidationErrMessage" -}}
{{- printf "%s : %s --> %s" .serviceName .srcLocation .destLocation -}}
{{- end -}}

{{- define "validateRestructuredValues" -}}
{{- $validationErrors := "" }}
{{/* platform */}}
{{/* ti-service */}}
{{- if and (index .Values "platform") (index .Values "platform" "ti-service") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "ti-service" "srcLocation" "platform.ti-service" "destLocation" "ci.ti-service")) }}
{{- end }}
{{/* cv-nextgen */}}
{{- if and (index .Values "platform") (index .Values "platform" "cv-nextgen") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "cv-nextgen" "srcLocation" "platform.cv-nextgen" "destLocation" "srm.cv-nextgen")) }}
{{- end }}
{{/* verification-svc */}}
{{- if and (index .Values "platform") (index .Values "platform" "verification-svc") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "verification-svc" "srcLocation" "platform.verification-svc" "destLocation" "srm.verification-svc")) }}
{{- end }}
{{/* le-nextgen */}}
{{- if and (index .Values "platform") (index .Values "platform" "le-nextgen") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "le-nextgen" "srcLocation" "platform.le-nextgen" "destLocation" "srm.le-nextgen")) }}
{{- end }}
{{/* harness-secrets */}}
{{- if and (index .Values "platform") (index .Values "platform" "harness-secrets") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "harness-secrets" "srcLocation" "platform.harness-secrets" "destLocation" "platform.bootstrap.harness-secrets")) }}
{{- end }}
{{/* minio */}}
{{- if and (index .Values "platform") (index .Values "platform" "minio") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "minio" "srcLocation" "platform.minio" "destLocation" "platform.bootstrap.database.minio")) }}
{{- end }}
{{/* mongo */}}
{{- if and (index .Values "platform") (index .Values "platform" "mongo") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "mongo" "srcLocation" "platform.mongodb" "destLocation" "platform.bootstrap.database.mongodb")) }}
{{- end }}
{{/* redis */}}
{{- if and (index .Values "platform") (index .Values "platform" "timescaledb") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "redis" "srcLocation" "platform.redis" "destLocation" "platform.bootstrap.database.redis")) }}
{{- end }}
{{/* timescaledb */}}
{{- if and (index .Values "platform") (index .Values "platform" "timescaledb") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "timescaledb" "srcLocation" "platform.timescaledb" "destLocation" "platform.bootstrap.database.timescaledb")) }}
{{- end }}
{{/* infra */}}
{{/* postgresql */}}
{{- if and (index .Values "infra") (index .Values "infra" "postgresql") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "postgresql" "srcLocation" "infra.postgresql" "destLocation" "platform.bootstrap.database.postgresql")) }}
{{- end }}
{{/* gitops */}}
{{- if index .Values "gitops" }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "gitops" "srcLocation" "gitops" "destLocation" "cd.gitops")) }}
{{- end }}
{{/* ccm */}}
{{/* clickhouse */}}
{{- if and (index .Values "ccm") (index .Values "ccm" "clickhouse") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "clickhouse" "srcLocation" "ccm.clickhouse" "destLocation" "global.database.clickhouse")) }}
{{- end }}
{{/* nextgen-ce */}}
{{- if and (index .Values "ccm") (index .Values "ccm" "nextgen-ce") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "nextgen-ce" "srcLocation" "ccm.nextgen-ce" "destLocation" "global.database.ce-nextgen")) }}
{{- end }}
{{/* ngcustomdashboard */}}
{{/* ng-custom-dashboards */}}
{{- if and (index .Values "ngcustomdashboard") (index .Values "ngcustomdashboard" "ng-custom-dashboards") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "ng-custom-dashboards" "srcLocation" "ngcustomdashboard.ng-custom-dashboards" "destLocation" "platform.ng-custom-dashboards")) }}
{{- end }}
{{/* looker */}}
{{- if and (index .Values "ngcustomdashboard") (index .Values "ngcustomdashboard" "looker") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "looker" "srcLocation" "ngcustomdashboard.looker" "destLocation" "platform.looker")) }}
{{- end }}
{{/* policy-mgmt */}}
{{- if and (index .Values "policy-mgmt") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "policy-mgmt" "srcLocation" "policy-mgmts" "destLocation" "platform.policy-mgmt")) }}
{{- end }}
{{/* cet */}}
{{/* enable-receivers */}}
{{- if and (index .Values "srm") (index .Values "srm" "enable-receivers") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "enable-receivers" "srcLocation" "srm.enable-receivers" "destLocation" "cet.enable-receivers")) }}
{{- end }}
{{/* et-service */}}
{{- if and (index .Values "srm") (index .Values "srm" "et-service") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "et-service" "srcLocation" "srm.et-service" "destLocation" "cet.et-service")) }}
{{- end }}
{{/* et-collector */}}
{{- if and (index .Values "srm") (index .Values "srm" "et-collector") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "et-collector" "srcLocation" "srm.et-collector" "destLocation" "cet.et-collector")) }}
{{- end }}
{{/* et-receiver-decompile */}}
{{- if and (index .Values "srm") (index .Values "srm" "et-receiver-decompile") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "et-receiver-decompile" "srcLocation" "srm.et-receiver-decompile" "destLocation" "cet.et-receiver-decompile")) }}
{{- end }}
{{/* et-receiver-hit */}}
{{- if and (index .Values "srm") (index .Values "srm" "et-receiver-hit") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "et-receiver-hit" "srcLocation" "srm.et-receiver-hit" "destLocation" "cet.et-receiver-hit")) }}
{{- end }}
{{/* et-receiver-sql */}}
{{- if and (index .Values "srm") (index .Values "srm" "et-receiver-sql") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "et-receiver-sql" "srcLocation" "srm.et-receiver-sql" "destLocation" "cet.et-receiver-sql")) }}
{{- end }}
{{/* et-receiver-agent */}}
{{- if and (index .Values "srm") (index .Values "srm" "et-receiver-agent") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "et-receiver-agent" "srcLocation" "srm.et-receiver-agent" "destLocation" "cet.et-receiver-agent")) }}
{{- end }}
{{/* chaos */}}
{{/* chaos-driver */}}
{{- if and (index .Values "chaos") (index .Values "chaos" "chaos-driver") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "chaos-driver" "srcLocation" "chaos.chaos-driver" "destLocation" "")) }}
{{- end }}
{{/* global */}}
{{/* nginx */}}
{{- if and (index .Values "global") (index .Values "global" "ingress") (index .Values "global" "ingress" "nginx") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "nginx" "srcLocation" "global.ingress.nginx" "destLocation" "platform.bootstrap.networking.nginx")) }}
{{- end }}
{{/* defaultbackend */}}
{{- if and (index .Values "global") (index .Values "global" "ingress") (index .Values "global" "ingress" "defaultbackend") }}
{{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "defaultbackend" "srcLocation" "global.ingress.defaultbackend" "destLocation" "platform.bootstrap.networking.defaultbackend")) }}
{{- end }}
{{- if gt (len $validationErrors) 0 }}
{{- $validationErrorHeading := printf "\n\n Validation Error: \n values/override.yaml files require changes to work with the new Harness Helm Charts structure \n\n" }}
{{- $validationErrorHeading = printf "%s In harness-0.9.x, Harness helm charts have been restructured and the impacted fields in provided values/override.yaml need to be migrated by following the steps below \n\n" $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s Steps: \n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s 1. Download 'migrate-values-0.9.x.sh' script by navigating to the below URL:\n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s    https://github.com/harness/helm-charts/blob/release/0.9.0/src/harness/scripts/migrate-values-0.9.x.sh\n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s    Note: migrate-values-0.9.x.sh script requires 'yq' to be installed \n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s 2. Get values from the installed harness release:\n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s    helm get values my-release -n <namespace> > old_values.yaml \n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s 3. Change permission of 'migrate-values-0.9.x.sh' \n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s    chmod +x migrate-values-0.9.x.sh \n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s 4. Run 'migrate-values-0.9.x.sh' script with the old_values.yaml as input to restrucutre it to work with the new Harness Helm Charts structure  \n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s    ./migrate-values-0.9.x.sh -f old_values.yaml  \n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s 5. A new values file with 'migrated' suffix will be created: old_values-migrated.yaml  \n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s 6. Upgrade Harness using the migrated values file as follows:  \n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%s    helm upgrade my-release harness/harness -n <namespace> -f old_values-migrated.yaml  \n\n\n " $validationErrorHeading }}
{{- $validationErrorHeading = printf "%sImpacted fields/values: " $validationErrorHeading }}
{{- $validationErrors = printf "%s \n %s" $validationErrorHeading $validationErrors }}
{{- fail $validationErrors }}
{{- end -}}
{{- end -}}


