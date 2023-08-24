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
{{- if gt (len $validationErrors) 0 }}
{{- $validationErrorHeading := printf "\n\n Validation Error: \n values/override.yaml files require changes to work with the new Harness Helm Charts structure \n\n" }}
{{- $validationErrorHeading = printf "%s In harness-0.9.x, Harness helm charts have been restructured and the following fields in provided values/override.yaml need to be migrated as follows:" $validationErrorHeading }}
{{- $validationErrors = printf "%s \n %s" $validationErrorHeading $validationErrors }}
{{- fail $validationErrors }}
{{- end -}}
{{- end -}}


