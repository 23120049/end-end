{{/* Expand the name of the chart. */}}
{{- define "nginx-page.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Create a release-qualified resource name. */}}
{{- define "nginx-page.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := include "nginx-page.name" . }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* Standard labels shared by all chart resources. */}}
{{- define "nginx-page.labels" -}}
helm.sh/chart: {{ include "nginx-page.chart" . }}
{{ include "nginx-page.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/* Labels used by the Deployment selector and Service selector. */}}
{{- define "nginx-page.selectorLabels" -}}
app.kubernetes.io/name: {{ include "nginx-page.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/* Chart name and version for labels. */}}
{{- define "nginx-page.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Name of the ServiceAccount used by the Pod. */}}
{{- define "nginx-page.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "nginx-page.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
