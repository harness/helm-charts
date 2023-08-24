{{- define "validateRestructuredValues" -}}
{{- $validationErrors := "" }}
{{/* platform */}}
{{/* ti-service */}}
{{- if index .Values "platform" "ti-service" }} }}
{{- $validationErrors = printf "%s \n %s" $validationErrors "ti-service has been migrated from platform.ti-service to ci.ti-service" }}
{{- end }}
{{/* cv-nextgen */}}
{{- if index .Values "platform" "cv-nextgen" }} }}
{{- $validationErrors = printf "%s \n %s" $validationErrors "cv-nextgen has been migrated from platform.cv-nextgen to srm.cv-nextgen" }}
{{- end }}
{{/* verification-svc */}}
{{- if index .Values "platform" "verification-svc" }} }}
{{- $validationErrors = printf "%s \n %s" $validationErrors "verification-svc has been migrated from platform.verification-svc to srm.verification-svc" }}
{{- end }}
{{/* le-nextgen */}}
{{- if index .Values "platform" "le-nextgen" }} }}
{{- $validationErrors = printf "%s \n %s" $validationErrors "le-nextgen has been migrated from platform.le-nextgen to srm.le-nextgen" }}
{{- end }}
{{/* harness-secrets */}}
{{- if index .Values "platform" "harness-secrets" }} }}
{{- $validationErrors = printf "%s \n %s" $validationErrors "harness-secrets has been migrated from platform.harness-secrets to platform.bootstrap.harness-secrets" }}
{{- end }}
{{/* minio */}}
{{- if index .Values "platform" "minio" }} }}
{{- $validationErrors = printf "%s \n %s" $validationErrors "minio has been migrated from platform.minio to platform.bootstrap.database.minio" }}
{{- end }}
{{/* mongo */}}
{{- if index .Values "platform" "mongo" }} }}
{{- $validationErrors = printf "%s \n %s" $validationErrors "mongo has been migrated from platform.mongodb to platform.bootstrap.database.mongodb" }}
{{- end }}
{{/* redis */}}
{{- if index .Values "platform" "redis" }} }}
{{- $validationErrors = printf "%s \n %s" $validationErrors "redis has been migrated from platform.redis to platform.bootstrap.database.redis" }}
{{- end }}
{{/* timescaledb */}}
{{- if index .Values "platform" "timescaledb" }} }}
{{- $validationErrors = printf "%s \n %s" $validationErrors "timescaledb has been migrated from platform.timescaledb to platform.bootstrap.database.timescaledb" }}
{{- end }}
{{- if gt (len $validationErrors) 0}}
{{- fail $validationErrors }}
{{- end }}
{{- end }}

{{- define "restructuredValuesValidationMessage" -}}
{{- printf "%s \n %s" $validationErrors "redis has been migrated from platform.redis to platform.bootstrap.database.redis" -}}
{{- end }}
