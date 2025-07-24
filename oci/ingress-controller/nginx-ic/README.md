# Controlador NGINX Ingress para OCI/OKE

Este directorio contiene scripts y configuraciones para desplegar el controlador NGINX Ingress en Oracle Cloud Infrastructure (OCI) con Kubernetes Engine (OKE).

## Características

- **Autocontenida**: Sin dependencias externas
- **Idempotente**: Seguro para ejecutar múltiples veces
- **Optimizado para OCI**: Configuración específica para balanceadores de carga de OCI
- **Listo para producción**: Incluye límites de recursos, chequeos de salud y monitoreo

## Archivos

- `deploy.sh` - Despliega el controlador NGINX Ingress
- `undeploy.sh` - Elimina el controlador y limpia recursos
- `values.yaml` - Configuración de valores para Helm
- `../samples/nginx-ingress-rules.yaml` - Ejemplos de reglas Ingress para NGINX

## Inicio Rápido

### Prerrequisitos

Asegúrese de tener:
- `kubectl` configurado y conectado a su clúster OKE
- `helm` instalado (v3.x)
- Permisos RBAC para crear namespaces y recursos

### Despliegue

```bash
# Despliegue básico con configuración por defecto
./deploy.sh

# O con configuración personalizada
NAMESPACE=mi-ingress CHART_NAME=mi-nginx ./deploy.sh
```

### Eliminación

```bash
# Eliminación interactiva (solicita confirmación)
./undeploy.sh

# Eliminación forzada (sin confirmación)
FORCE=true ./undeploy.sh
```

## Configuración

Toda la configuración está centralizada en `values.yaml`. Los valores clave incluyen:


```yaml
# Configuración básica
config:
  chart_name: "nginx-ingress"
  chart_version: "4.11.3"
  namespace: "nginx-ingress"

# Configuración del balanceador de carga OCI
loadbalancer:
  shape: "flexible"
  shape_min: "10"
  shape_max: "100"

# Configuración del controlador NGINX
nginx:
  replica_count: 2
  enable_metrics: true
  set_as_default: false
```


## Variables de Entorno

Ambos scripts soportan sobrescritura de variables de entorno:

- `CHART_NAME` - Nombre del release Helm (por defecto: nginx-ingress)
- `CHART_VERSION` - Versión del chart (por defecto: 4.11.3)
- `NAMESPACE` - Namespace de Kubernetes (por defecto: nginx-ingress)
- `CHART_REPO` - Repositorio Helm (por defecto: https://kubernetes.github.io/ingress-nginx)
- `VALUES_FILE` - Ruta del archivo de valores (por defecto: values.yaml)
- `TIMEOUT` - Tiempo de espera para despliegue (por defecto: 600s)
- `FORCE` - Omitir confirmación en eliminación (por defecto: false)

## Ejemplos de Uso

### Despliegue con namespace personalizado
```bash
NAMESPACE=ingress-produccion ./deploy.sh
```

### Despliegue con versión personalizada del chart
```bash
CHART_VERSION=4.10.1 ./deploy.sh
```

### Eliminación forzada sin confirmación
```bash
FORCE=true ./undeploy.sh
```

## Uso de Ingress

Después del despliegue, cree recursos Ingress usando:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: mi-app-ingress
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx  # Importante: usar la clase nginx
  rules:
    - host: mi-app.ejemplo.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: mi-app-service
                port:
                  number: 80
  tls:
    - hosts:
        - mi-app.ejemplo.com
      secretName: mi-tls-secret
```

Consulte `../samples/nginx-ingress-rules.yaml` para ejemplos más completos.

## Características específicas de OCI

- **Balanceador flexible**: Escala automáticamente el ancho de banda según el tráfico
- **Optimización de conexión**: Optimizado para el rendimiento de red en OCI
- **Chequeos de salud**: Health checks nativos de Kubernetes
- **Etiquetado de recursos**: Gestión adecuada para facturación en OCI

## Monitoreo

El despliegue incluye:
- Endpoint de métricas Prometheus en el puerto 10254
- Chequeos de salud (liveness/readiness probes)
- Monitoreo de recursos vía kubectl

Verifique el estado del despliegue:
```bash
kubectl get pods -n nginx-ingress
kubectl get svc -n nginx-ingress
kubectl get ingressclass nginx
```

## Solución de Problemas

### Ver logs
```bash
kubectl logs -n nginx-ingress -l app.kubernetes.io/component=controller
```

### Verificar el controlador ingress
```bash
kubectl get pods -n nginx-ingress
kubectl describe ingressclass nginx
```

### Probar ingress
```bash
kubectl get ingress --all-namespaces
kubectl describe ingress <nombre-ingress> -n <namespace>
```

### Problemas comunes

1. **LoadBalancer pendiente**: Verifique cuotas y límites de servicio en OCI
2. **Problemas SSL**: Verifique que el secreto TLS exista en el namespace correcto
3. **Errores 502/503**: Verifique endpoints y salud de los servicios backend

## Consideraciones de Seguridad

- El controlador se ejecuta como usuario no root
- Capacidades mínimas requeridas
- Límites de recursos aplicados
- Compatible con políticas de red
- RBAC con privilegios mínimos

## Migración desde Contour

Principales diferencias al migrar desde Contour:

1. **IngressClass**: Cambiar de `contour` a `nginx`
2. **Anotaciones**: Reemplazar `projectcontour.io/*` por `nginx.ingress.kubernetes.io/*`
3. **Tipos de path**: Considere cambiar de `ImplementationSpecific` a `Prefix`
4. **Características**: Algunas funciones específicas de Contour pueden requerir equivalentes en NGINX

Consulte los archivos de ejemplo para migraciones específicas.
