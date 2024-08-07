{{- define "harness.harness-manager-image" -}}
{{- $deploy := (lookup "apps/v1" "Deployment" .Release.Namespace "harness-manager") }}
{{- if empty $deploy }}
    {{- printf "0" }}
{{- else -}}
    {{- $containers := get (get (get (get $deploy "spec") "template" ) "spec" ) "containers" }}
    {{- $image := get (index $containers 0) "image" -}}
    {{- $split := (mustRegexSplit ":" $image -1) -}}
    {{- $tag := (index $split 1) | int -}}
    {{- $shortTag := div $tag 100 -}}
    {{- printf "%d" $shortTag -}}
{{- end -}}
{{- end -}}

{{- define "common.compatibility.renderSecurityContext" -}}
{{- $adaptedContext := .secContext -}}
{{- if not .secContext.seLinuxOptions -}}
{{/* If it is an empty object, we remove it from the resulting context because it causes validation issues */}}
{{- $adaptedContext = omit $adaptedContext "seLinuxOptions" -}}
{{- end -}}
{{/* Remove fields that are disregarded when running the container in privileged mode */}}
{{- if $adaptedContext.privileged -}}
  {{- $adaptedContext = omit $adaptedContext "capabilities" "seLinuxOptions" -}}
{{- end -}}
{{- omit $adaptedContext "enabled" | toYaml -}}
{{- end -}}
