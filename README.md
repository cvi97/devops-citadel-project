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
Se adjunta una carpeta con tres ficheros:
#### `my-terraform-module/`
```plaintext
│-- main.tf
│-- variables.tf
│-- outputs.tf (opcional)
```

#### `variables.tf`
Este archivo contiene todas las variables que se utilizarán en el módulo. Aquí es donde se definen las variables como el servidor ACR, la suscripción, las credenciales y otros detalles necesarios para la operación.

#### `main.tf`
Este archivo contiene la lógica principal para copiar los charts del ACR de origen al ACR de destino y luego instalarlos en el clúster AKS usando Helm.

#### `outputs.tf`
Este archivo, aunque opcional, define el mensaje que emite Terraform cuando termina de ejecutarse, en este caso el nombre de los Helm Chart instalados.

#### Un ejemplo de como referenciar este módulo para usarlo
```hcl
module "chart" {
  source = "./my-terraform-module"  # Path del modulo

  acr_server = "instance.azurecr.io"
  acr_server_subscription = "c9e7611c-d508-4fbf-aede-0bedfabc1560"
  source_acr_client_id = "1b2f651e-b99c-4720-9ff1-ede324b8ae30"
  source_acr_client_secret = "Zrrr8~5~F2Xiaaaa7eS.S85SXXAAfTYizZEF1cRp"
  source_acr_server = "reference.azurecr.io"
  
  charts = [
    # Charts a instalar
  ]
}
```

## Challenge 3
### Create a Github workflow to allow installing helm chart from Challenge #1 using module from Challenge #2, into an AKS cluster (considering a preexisting resource group and cluster name)


La pipeline necesitará hacer lo siguiente:

1. **Chequear el código fuente del repositorio:** Asegurarse de que el código fuente esté actualizado y listo para ser desplegado.

2. **Configurar un ambiente de ejecución con Terraform y kubectl:** Preparar el entorno donde se ejecutará Terraform y kubectl para gestionar los recursos de Kubernetes y Azure.

3. **Configurar la autenticación con Azure:** Establecer las credenciales y permisos necesarios para interactuar con los recursos de Azure.

4. **Inicializar Terraform:** Preparar Terraform para la ejecución, inicializando los plugins y módulos necesarios.

5. **Aplicar la configuración de Terraform para instalar el Helm chart en tu clúster AKS:** Ejecutar Terraform apply para desplegar los recursos definidos en los archivos de configuración de Terraform.

Al igual que en las pruebas anteriores, adjunto el fichero YAML “deploy-helm-chart.yml” con un ejemplo de cómo pueden realizarse los pasos necesarios de Github Workflow.
