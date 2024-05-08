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
{{- if (index .Values "platform") }}
    {{- if (index .Values "platform" "ti-service") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "ti-service" "srcLocation" "platform.ti-service" "destLocation" "ci.ti-service")) }}
    {{- end }}
{{- end }}
{{/* cv-nextgen */}}
{{- if (index .Values "platform") }}
    {{- if (index .Values "platform" "cv-nextgen") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "cv-nextgen" "srcLocation" "platform.cv-nextgen" "destLocation" "srm.cv-nextgen")) }}
    {{- end }}
{{- end }}
{{/* verification-svc */}}
{{- if (index .Values "platform") }}
    {{- if (index .Values "platform" "verification-svc") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "verification-svc" "srcLocation" "platform.verification-svc" "destLocation" "srm.verification-svc")) }}
    {{- end }}
{{- end }}
{{/* le-nextgen */}}
{{- if (index .Values "platform") }}
    {{- if (index .Values "platform" "le-nextgen") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "le-nextgen" "srcLocation" "platform.le-nextgen" "destLocation" "srm.le-nextgen")) }}
    {{- end }}
{{- end }}
{{/* harness-secrets */}}
{{- if (index .Values "platform") }}
    {{- if (index .Values "platform" "harness-secrets") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "harness-secrets" "srcLocation" "platform.harness-secrets" "destLocation" "platform.bootstrap.harness-secrets")) }}
    {{- end }}
{{- end }}
{{/* minio */}}
{{- if (index .Values "platform") }}
    {{- if (index .Values "platform" "minio") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "minio" "srcLocation" "platform.minio" "destLocation" "platform.bootstrap.database.minio")) }}
    {{- end }}
{{- end }}
{{/* mongo */}}
{{- if (index .Values "platform") }}
    {{- if (index .Values "platform" "mongo") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "mongo" "srcLocation" "platform.mongodb" "destLocation" "platform.bootstrap.database.mongodb")) }}
    {{- end }}
{{- end }}
{{/* redis */}}
{{- if (index .Values "platform") }}
    {{- if (index .Values "platform" "timescaledb") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "redis" "srcLocation" "platform.redis" "destLocation" "platform.bootstrap.database.redis")) }}
    {{- end }}
{{- end }}
{{/* timescaledb */}}
{{- if (index .Values "platform") }}
    {{- if (index .Values "platform" "timescaledb") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "timescaledb" "srcLocation" "platform.timescaledb" "destLocation" "platform.bootstrap.database.timescaledb")) }}
    {{- end }}
{{- end }}
{{/* infra */}}
{{/* postgresql */}}
{{- if (index .Values "infra") }}
    {{- if (index .Values "infra" "postgresql") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "postgresql" "srcLocation" "infra.postgresql" "destLocation" "platform.bootstrap.database.postgresql")) }}
    {{- end }}
{{- end }}
{{/* gitops */}}
{{- if (index .Values "gitops") }}
    {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "gitops" "srcLocation" "gitops" "destLocation" "cd.gitops")) }}
{{- end }}
{{/* ccm */}}
{{/* clickhouse */}}
{{- if (index .Values "ccm") }}
    {{- if (index .Values "ccm" "clickhouse") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "clickhouse" "srcLocation" "ccm.clickhouse" "destLocation" "global.database.clickhouse")) }}
    {{- end }}
{{- end }}
{{/* nextgen-ce */}}
{{- if (index .Values "ccm") }}
    {{- if (index .Values "ccm" "nextgen-ce") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "nextgen-ce" "srcLocation" "ccm.nextgen-ce" "destLocation" "global.database.ce-nextgen")) }}
    {{- end }}
{{- end }}
{{/* ngcustomdashboard */}}
{{/* ng-custom-dashboards */}}
{{- if (index .Values "ngcustomdashboard") }}
    {{- if (index .Values "ngcustomdashboard" "ng-custom-dashboards") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "ng-custom-dashboards" "srcLocation" "ngcustomdashboard.ng-custom-dashboards" "destLocation" "platform.ng-custom-dashboards")) }}
    {{- end }}
{{- end }}
{{/* looker */}}
{{- if (index .Values "ngcustomdashboard") }}
    {{- if (index .Values "ngcustomdashboard" "looker") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "looker" "srcLocation" "ngcustomdashboard.looker" "destLocation" "platform.looker")) }}
    {{- end }}
{{- end }}
{{/* policy-mgmt */}}
{{- if (index .Values "policy-mgmt") }}
    {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "policy-mgmt" "srcLocation" "policy-mgmts" "destLocation" "platform.policy-mgmt")) }}
{{- end }}
{{/* chaos */}}
{{/* chaos-driver */}}
{{- if (index .Values "chaos") }}
    {{- if (index .Values "chaos" "chaos-driver") }}
        {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "chaos-driver" "srcLocation" "chaos.chaos-driver" "destLocation" "")) }}
    {{- end }}
{{- end }}

{{/* global */}}
{{/* nginx */}}
{{- if (index .Values "global") }}
    {{- if (index .Values "global" "ingress") }}
        {{- if (index .Values "global" "ingress" "nginx") }}
            {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "nginx" "srcLocation" "global.ingress.nginx" "destLocation" "platform.bootstrap.networking.nginx")) }}
        {{- end }}
    {{- end }}
{{- end }}

{{/* defaultbackend */}}
{{- if (index .Values "global") }}
    {{- if (index .Values "global" "ingress") }}
        {{- if (index .Values "global" "ingress" "defaultbackend") }}
            {{- $validationErrors = printf "%s \n %s" $validationErrors (include "restructuredValuesValidationErrMessage" (dict "serviceName" "defaultbackend" "srcLocation" "global.ingress.defaultbackend" "destLocation" "platform.bootstrap.networking.defaultbackend")) }}
        {{- end }}
    {{- end }}
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


