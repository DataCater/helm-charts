{{/*
Expand the name of the chart.
*/}}
{{- define "datacater-chart.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "datacater-chart.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Helper function for getting env variables for platform
*/}}
{{- define "datacater.platform.env" }}
- name: DC_MAILER_FROM_ADDRESS
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: dc_mailer_from_address
- name: DC_KEEP_DEFAULT_USER
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: dc_keep_default_user
- name: DC_DEFAULT_USER
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: dc_default_user
- name: DC_MAILER_FROM_NAME
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: dc_mailer_from_name
- name: MAILER_TLS
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: mailer_tls
- name: MAILER_SSL
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: mailer_ssl
- name:  DC_PUBLIC_URI
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key:  dc_public_uri
- name: DC_UDF_RUNNER_HOSTNAME
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: dc_udf_runner_hostname
- name:  DC_UDF_RUNNER_PORT
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: dc_udf_runner_port
- name: DEPLOYMENT_TYPE
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: deployment_type
- name: ELASTICSEARCH_HOST
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: elasticsearch_host
- name: ELASTICSEARCH_PORT
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: elasticsearch_port
- name: KAFKA_CONNECT_HOST
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: kafka_connect_host
- name: KAFKA_CONNECT_PORT
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: kafka_connect_port
- name: KAFKA_HOST
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: kafka_host
- name: KAFKA_PORT
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: kafka_port
- name: PG_DATABASE_NAME
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: pg_database_name
- name: PG_HOST
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: pg_host
- name: PIPELINE_REGISTRY
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: pipeline_registry
{{- end }}

{{/*
Helper function loading secrets to as env variables
*/}}
{{- define "datacater.platform-secrets.env" }}
{{- range $key, $val := .Values.dataCaterSecretMappings.mailerSecrets }}
- name: {{ $key | upper }}
  valueFrom:
      secretKeyRef:
        name: {{ $.Values.dataCaterSecretMappings.mailerSecretName }}
        key: {{ $val }}
{{- end }}
{{- range $key, $val := .Values.dataCaterSecretMappings.pgSecrets }}
- name: {{ $val | upper }}
  valueFrom:
      secretKeyRef:
        name: {{ $.Values.dataCaterSecretMappings.pgSecretName }}
        key: {{ $val }}
{{- end }}
{{- range $key, $val := .Values.dataCaterSecretMappings.dockerSecrets }}
- name: {{ $val | upper }}
  valueFrom:
      secretKeyRef:
        name: {{ $.Values.dataCaterSecretMappings.dockerLoginSecret }}
        key: {{ $val }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "datacater-chart.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "datacater-chart.labels" -}}
helm.sh/chart: {{ include "datacater-chart.chart" . }}
{{ include "datacater-chart.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}


{{- define "datacater-platform.labels" -}}
helm.sh/chart: {{ include "datacater-chart.chart" . }}
{{ include "datacater-platform.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}-platform
{{- end }}


{{/*
Create the name of the service account to use
*/}}
{{- define "datacater.serviceAccountName" -}}
{{- if .Values.datacater.serviceAccount.name }}
{{- default (include "datacater-chart.fullname" .) .Values.datacater.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.datacater.serviceAccount.name }}
{{- end }}
{{- end }}
