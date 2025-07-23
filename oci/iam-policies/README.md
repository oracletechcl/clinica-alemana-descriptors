
# Políticas IAM para Clases de Almacenamiento Kubernetes en OCI

Este directorio contiene todas las políticas IAM necesarias para que Block Storage (BS) y File Storage Service (FSS) de OCI funcionen con las clases de almacenamiento de Kubernetes.

## Descripción General

Las políticas están diseñadas para permitir que los nodos de Kubernetes gestionen recursos de almacenamiento en OCI siguiendo el principio de privilegio mínimo.

## Estructura de Archivos

- `block-storage-policies.json` - Políticas para el driver CSI de Block Storage
- `file-storage-policies.json` - Políticas para el driver CSI de File Storage Service
- `dynamic-groups.json` - Definición de grupo dinámico para los nodos de Kubernetes
- `create-policies.sh` - Script para crear todas las políticas usando OCI CLI

## Políticas Requeridas

### Políticas de Block Storage
1. **k8s-block-storage-management-policy** - Permisos principales para operaciones de volúmenes de bloque
   - Gestionar volúmenes, adjuntos de volúmenes e instancias
   - Leer compartimentos y dominios de disponibilidad
   - Usar recursos de red (subnets, VNICs, NSGs)

2. **k8s-block-storage-backup-policy** - Operaciones de respaldo y restauración
   - Gestionar respaldos de volúmenes y políticas de respaldo

### Políticas de File Storage
1. **k8s-file-storage-management-policy** - Permisos principales para operaciones de FSS
   - Gestionar sistemas de archivos, puntos de montaje y conjuntos de exportación
   - Leer compartimentos y dominios de disponibilidad
   - Usar recursos de red

2. **k8s-file-storage-snapshot-policy** - Operaciones de snapshots
   - Gestionar snapshots de sistemas de archivos

### Grupo Dinámico
- **k8s-nodes** - Agrupa todos los nodos del clúster de Kubernetes para asignación de políticas

## Prerrequisitos

1. Tener OCI CLI instalado y configurado
2. Permisos adecuados para crear políticas IAM y grupos dinámicos
3. OCID de compartimento válido (actualizar en los archivos si es diferente)

## Despliegue

### Opción 1: Usando OCI CLI (Recomendado)
```bash
chmod +x create-policies.sh
./create-policies.sh
```

### Opción 2: Usando la Consola de OCI
1. Navegar a Identidad y Seguridad > Políticas
2. Crear cada política manualmente usando las sentencias de los archivos JSON
3. Crear el grupo dinámico usando las reglas de `dynamic-groups.json`

### Opción 3: Usando Terraform
Utilizar los archivos JSON como referencia para crear recursos de Terraform para el despliegue automatizado.

## Notas Importantes

1. **OCID de Compartimento**: Actualizar el OCID de compartimento en todos los archivos para que coincida con su entorno:
   ```
   ocid1.compartment.oc1..aaaaaaaa5vmhhu4nckq2zwmsznj7ytticdkvrghfon56sepq6mkkz72y4mva
   ```

2. **Coincidencia de Grupo Dinámico**: El grupo dinámico coincide con instancias en el compartimento especificado. Ajuste las reglas si sus nodos de Kubernetes siguen una convención de nombres diferente.

3. **Seguridad de Red**: Las políticas incluyen permisos para grupos de seguridad de red y VNICs, que pueden ser necesarios según la configuración de su clúster.

4. **Políticas de Respaldo**: Las políticas de respaldo son opcionales si no planea usar las funciones de respaldo de OCI.

## Solución de Problemas

### Problemas Comunes
1. **Permiso Denegado**: Verifique que el grupo dinámico coincida correctamente con sus nodos de Kubernetes
2. **Recurso No Encontrado**: Verifique que los OCIDs de compartimento sean correctos
3. **Problemas de Red**: Asegúrese de que los permisos de subred y VNIC sean suficientes para la configuración de su clúster

### Verificación
Después de crear las políticas, verifique su funcionamiento:
1. Cree un PVC usando las clases de almacenamiento
2. Verifique que los volúmenes se aprovisionen correctamente
3. Pruebe la conexión de volúmenes a los pods

## Consideraciones de Seguridad

- Las políticas están limitadas al compartimento específico
- Se utilizan grupos dinámicos en lugar de políticas basadas en usuarios para mayor seguridad
- Se sigue el principio de privilegio mínimo
- Los permisos de red están limitados a los recursos necesarios

## Referencias

- [Documentación del driver CSI de Block Volume en OCI](https://github.com/oracle/oci-cloud-controller-manager/blob/master/docs/tutorial.md)
- [Documentación del driver CSI de File Storage en OCI](https://github.com/oracle/oci-cloud-controller-manager/blob/master/docs/fss.md)
- [Documentación de Políticas IAM en OCI](https://docs.oracle.com/en-us/iaas/Content/Identity/Concepts/policies.htm)
