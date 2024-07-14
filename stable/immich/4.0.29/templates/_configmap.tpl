{{/* Define the configmap */}}
{{- define "immich.config" -}}

{{- $serverConfigName := printf "%s-server-config" (include "tc.common.names.fullname" .) -}}
{{- $commonConfigName := printf "%s-common-config" (include "tc.common.names.fullname" .) -}}
{{- $proxyConfigName := printf "%s-proxy-config" (include "tc.common.names.fullname" .) }}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $serverConfigName }}
  labels:
    {{- include "tc.common.labels" . | nindent 4 }}
data:
  DB_HOSTNAME: {{ printf "%v-%v" .Release.Name "postgresql" }}
  DB_USERNAME: {{ .Values.postgresql.postgresqlUsername }}
  DB_DATABASE_NAME: {{ .Values.postgresql.postgresqlDatabase }}
  DB_PORT: "5432"
  REDIS_HOSTNAME: {{ printf "%v-%v" .Release.Name "redis" }}
  REDIS_PORT: "6379"
  REDIS_DBINDEX: "0"
  {{/* User Defined */}}
  DISABLE_REVERSE_GEOCODING: {{ .Values.immich.disable_reverse_geocoding | quote }}
  REVERSE_GEOCODING_PRECISION: {{ .Values.immich.reverse_geocoding_precision | quote }}
  ENABLE_MAPBOX: {{ .Values.immich.mapbox_enable | quote }}

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ $commonConfigName }}
  labels:
    {{- include "tc.common.labels" . | nindent 4 }}
data:
  IMMICH_WEB_URL: http://localhost:3000
  IMMICH_SERVER_URL: http://localhost:3001
  IMMICH_MACHINE_LEARNING_URL: http://localhost:3003
  {{/*
  It's unclear where this URL is being used, but poking in their code, seems to be used internally?
  It's set to the value of IMMICH_SERVER_URL on their compose. If something doesn't work remotely,
  This is the place to start looking
  https://github.com/immich-app/immich/blob/b5d75e20167b92de12cc50a816da214779cb0807/web/src/api/api.ts#L55
  */}}
  PUBLIC_IMMICH_SERVER_URL: http://localhost:3001
  NODE_ENV: production
  {{/* User Defined */}}
  {{- with .Values.immich.public_login_page_message }}
  PUBLIC_LOGIN_PAGE_MESSAGE: {{ . }}
  {{- end }}
  LOG_LEVEL: {{ .Values.immich.log_level }}
{{- end -}}
