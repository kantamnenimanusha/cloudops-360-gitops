{{- define "app.selector" -}}
app.kubernetes.io/name: {{ .Release.Name }}
{{- end -}}

{{- define "app.labels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/part-of: cloudops-360
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}
