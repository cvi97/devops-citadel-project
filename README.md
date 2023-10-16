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
Se pueden añadir las condiciones siguientes para que solo tenga en cuenta el bloque affinity si están definidos los valores:
```yaml
{{- if and .Values.nodeAffinity.key .Values.nodeAffinity.value }}
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
```
La configuración asegura que los pods que tienen la misma etiqueta "app" con un valor que coincide con el nombre completo del release de Helm no se programarán en el mismo nodo. Esto es útil para garantizar que los pods se distribuyan entre diferentes nodos para mejorar la disponibilidad y la tolerancia a fallos de la aplicación.

### Pods are deployed across different availability zones
```yaml
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: app
              operator: In
              values:
              - {{ include "ping.fullname" . }}
          topologyKey: "failure-domain.beta.kubernetes.io/zone"
```
Esta configuración intenta asegurar que los pods se programen preferiblemente en nodos que estén en diferentes zonas de disponibilidad, pero que ya tengan al menos un pod de la misma aplicación (basado en la etiqueta "app"). Esto ayuda a distribuir la carga y aumentar la disponibilidad de la aplicación en caso de fallo de una zona.

## Challenge 2 
### You need to implement the reusable module. It should pass validations provided by the terraform fmt and terraform validate commands
