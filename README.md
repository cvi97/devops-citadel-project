## Challenge 1

Se han realizado los añadidos necesarios a los ficheros template, deployment.yml y al values.yml. A continuación se explican estos cambios.

### Isolate Specific Node Groups Forbidding the Pods Scheduling in These Node Groups
Como no tenía claro a qué grupo de nodos se refiere, añado este apartado en la template “deployment.yaml”, para poder añadir en “values.yaml” el grupo de nodos a evitar.
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
```


```yaml
## En values.yaml:
nodeAffinity:
  key: "nombreDeLaEtiqueta"
  value: "valorDeLaEtiqueta"
```

### Ensure that a pod will not be scheduled on a node that already has a pod of the same type
```yaml
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchExpressions:
        - key: app
          operator: In
          values:
          - {{ include "ping.fullname" . }}
      topologyKey: "kubernetes.io/hostname"
