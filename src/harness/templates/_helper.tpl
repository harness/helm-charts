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