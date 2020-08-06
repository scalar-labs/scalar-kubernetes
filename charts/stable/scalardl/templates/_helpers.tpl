{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "scalardl.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "scalardl.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "scalardl.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels envoy
*/}}
{{- define "scalardl-envoy.labels" -}}
helm.sh/chart: {{ include "scalardl.chart" . }}
{{ include "scalardl-envoy.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Common labels ledger
*/}}
{{- define "scalardl-ledger.labels" -}}
helm.sh/chart: {{ include "scalardl.chart" . }}
{{ include "scalardl-ledger.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels envoy
*/}}
{{- define "scalardl-envoy.selectorLabels" -}}
app.kubernetes.io/name: {{ include "scalardl.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/app: envoy
{{- end }}

{{/*
Selector labels ledger
*/}}
{{- define "scalardl-ledger.selectorLabels" -}}
app.kubernetes.io/name: {{ include "scalardl.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/app: ledger
{{- end }}
