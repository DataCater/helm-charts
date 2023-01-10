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
- name: PIPELINE_REGISTRY
  valueFrom:
    configMapKeyRef:
        name: datacater-platform-config
        key: pipeline_registry
{{- end }}

{{/* Helper function for envFrom
*/}}

{{- define "datacater.platform-secrets.envFrom" }}
- secretRef:
      name: datacater-mailer
- secretRef:
      name: datacater-db-secret
- secretRef:
      name: datacater-docker
- secretRef:
      name: datacater
{{- end }}

{{/* This is a adjusted example from https://helm.sh/docs/howto/charts_tips_and_tricks/#creating-image-pull-secrets.
*/}}
{{- define "datacater.registry.imagePullSecret" }}
{{- with .Values.datacater.image }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

  DOCKER_REGISTRY_USER: {{ .Values.datacater.docker.user | quote }}
  DOCKER_REGISTRY_PASSWORD: {{ .Values.datacater.docker.password | quote }}
  DOCKER_REGISTRY_URI: {{ .Values.datacater.uri | quote }}

{{- define "datacater.registry.secret" }}
{{- with .Values.datacater.image }}
{{- printf "{\"docker_registry_user\":\"%s\", \"docker_registry_password\":\"%s\", \"docker_registry_uri\":\"%s\"" .username .password .registry (printf "%s:%s" .username .password | b64enc) | b64enc }}
{{- end }}
{{- end }}

{{/* This is a adjusted example from https://helm.sh/docs/howto/charts_tips_and_tricks/#creating-image-pull-secrets.
*/}}
{{- define "datacater.pipeline.imagePullSecret" }}
{{- with .Values.datacater.pipeline }}
{{- printf "{\"auths\":{\"%s\":{\"username\":\"%s\",\"password\":\"%s\",\"email\":\"%s\",\"auth\":\"%s\"}}}" .registry .username .password .email (printf "%s:%s" .username .password | b64enc) | b64enc }}
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
