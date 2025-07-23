
# Descriptores para Clínica Alemana en OCI

Este repositorio contiene configuraciones, ejemplos y scripts para la gestión de recursos en Oracle Cloud Infrastructure (OCI) orientados a la Clínica Alemana.

## Estructura del Proyecto

- `oci/` - Configuraciones y scripts para despliegue en OCI
  - `bs/` - Clases de almacenamiento Block Storage
  - `fss/` - Clases de almacenamiento File Storage Service
  - `iam-policies/` - Políticas IAM para almacenamiento y Kubernetes
  - `ingress-controller/` - Scripts y valores para el controlador NGINX Ingress
- `samples/` - Ejemplos de recursos Kubernetes (ingress, PVC, etc.)

## Uso Rápido

1. Revise los archivos README en cada subdirectorio para instrucciones específicas.
2. Utilice los scripts de despliegue para instalar controladores y recursos en su clúster OKE.
3. Adapte los ejemplos de `samples/` según sus necesidades.

## Requisitos

- Acceso a un clúster Kubernetes en OCI (OKE)
- Permisos para crear recursos y políticas IAM
- Herramientas: `kubectl`, `helm`, `oci-cli`

## Referencias

- [Documentación oficial de OCI](https://docs.oracle.com/en-us/iaas/Content/home.htm)
- [Guía de Kubernetes en OCI](https://docs.oracle.com/en-us/iaas/Content/ContEng/Concepts/contengoverview.htm)

