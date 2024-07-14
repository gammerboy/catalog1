{{- define "metallb.wait" }}
{{- $fullName := include "tc.common.names.fullname" . }}
---
apiVersion: batch/v1
kind: Job
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ $fullName }}-wait
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-1"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
spec:
  template:
    spec:
      serviceAccountName: {{ $fullName }}-wait
      containers:
        - name: {{ $fullName }}-wait
          image: {{ .Values.ubuntuImage.repository }}:{{ .Values.ubuntuImage.tag }}
          command:
            - "/bin/sh"
            - "-c"
            - |
              /bin/bash <<'EOF'
              kubectl wait --namespace metallb-system --for=condition=ready pod --selector=app=metallb --timeout=90s
              EOF
      restartPolicy: OnFailure
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ $fullName }}-wait
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-2"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
rules:
  - apiGroups:  ["*"]
    resources:  ["pods"]
    verbs:  ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: {{ $fullName }}-wait
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-2"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: {{ $fullName }}-wait
subjects:
  - kind: ServiceAccount
    name: {{ $fullName }}-wait
    namespace: {{ .Release.Namespace }}
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: {{ $fullName }}-wait
  namespace: {{ .Release.Namespace }}
  annotations:
    "helm.sh/hook": pre-install, pre-upgrade
    "helm.sh/hook-weight": "-2"
    "helm.sh/hook-delete-policy": hook-succeeded,before-hook-creation
{{- end }}
