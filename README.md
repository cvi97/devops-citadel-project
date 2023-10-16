## Challenge 1

Se han realizado los añadidos necesarios a los ficheros template, deployment.yml y al values.yml. A continuación se explican estos cambios.

### Isolate Specific Node Groups Forbidding the Pods Scheduling in These Node Groups

```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
          - key: {{ .Values.nodeAffinity.key }}
            operator: NotIn
            values:
            - {{ .Values.nodeAffinity.value }}
