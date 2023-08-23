{{- define "validateRestructuredValues" -}}
    {{/* platform */}}
    {{/* ti-service */}}
    {{- if index .Values.platform "ti-service" }} }}
    {{-  fail "ti-service has been migrated from x to y. Please use migration script to perform the migration" }}
    {{- end }}

    {{/* ci-service */}}
    {{- if index .Values.platform "ti-service" }} }}
    {{-  fail "ti-service has been migrated from x to y. Please use migration script to perform the migration" }}
    {{- end }}
{{- end }}