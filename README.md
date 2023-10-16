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

Como no tenía claro a qué grupo de nodos se refiere, añado este apartado en la template “deployment.yaml”, para poder añadir en “values.yaml” el grupo de nodos a evitar.

```yaml
nodeAffinity:
  key: "nombreDeLaEtiqueta"
  value: "valorDeLaEtiqueta"
