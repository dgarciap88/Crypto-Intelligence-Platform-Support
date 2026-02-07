# PostgreSQL Kubernetes Manifests

Manifiestos para desplegar PostgreSQL optimizado para Crypto Intelligence Platform.

---

## 📦 Archivos

- **namespace.yaml** (en carpeta padre) - Crea namespace `crypto-intel`
- **configmap.yaml** - Configuración de PostgreSQL (tunning para JSONB, mem, WAL)
- **init-scripts-configmap.yaml** - Scripts SQL de inicialización (schema)
- **pvc.yaml** - PersistentVolumeClaim de 20GB
- **service.yaml** - Services (ClusterIP + Headless para StatefulSet)
- **statefulset.yaml** - StatefulSet de PostgreSQL con health checks
- **secret.yaml.example** - Plantilla para credenciales

---

## 🚀 Uso

### 1. Crear Secret

```bash
# Copiar ejemplo
cp secret.yaml.example secret.yaml

# Generar password en base64
echo -n 'tu_password_seguro_aqui' | base64

# Editar secret.yaml con el resultado
# IMPORTANTE: Añadir secret.yaml a .gitignore
```

### 2. Aplicar Manifiestos

```bash
# Desde la carpeta kubernetes/
kubectl apply -f ../namespace.yaml  # Si no existe
kubectl apply -f secret.yaml
kubectl apply -f configmap.yaml
kubectl apply -f init-scripts-configmap.yaml
kubectl apply -f pvc.yaml
kubectl apply -f service.yaml
kubectl apply -f statefulset.yaml
```

O todos a la vez:
```bash
kubectl apply -f postgres/
```

### 3. Verificar

```bash
# Ver estado del pod
kubectl get pods -n crypto-intel -l app=postgres

# Ver logs
kubectl logs -n crypto-intel -l app=postgres --tail=50

# Ver PVC
kubectl get pvc -n crypto-intel

# Ver services
kubectl get svc -n crypto-intel
```

---

## 🔧 Configuración

### Recursos

```yaml
requests:
  memory: 512Mi
  cpu: 500m
limits:
  memory: 2Gi
  cpu: 2000m
```

Ajustar según capacidad del cluster.

### Almacenamiento

- **Tamaño:** 20Gi (modificar en pvc.yaml)
- **AccessMode:** ReadWriteOnce
- **StorageClass:** Por defecto (ajustar según provider)

Ejemplos:
```yaml
# Azure
storageClassName: managed-premium

# AWS
storageClassName: gp3

# GCP
storageClassName: standard-rwo
```

### PostgreSQL Tunning

Ver `configmap.yaml` para parámetros optimizados:
- **shared_buffers:** 256MB
- **work_mem:** 16MB
- **JSONB optimization:** random_page_cost = 1.1
- **Autovacuum:** Habilitado con naptime de 1 min

---

## 🗄️ Acceso a la Base de Datos

### Desde Otro Pod

Usa el hostname del service: `postgres` o `postgres.crypto-intel.svc.cluster.local`

```yaml
env:
- name: DATABASE_URL
  value: postgresql://cip_user:password@postgres:5432/crypto_intel
```

### Port Forward (desarrollo)

```bash
kubectl port-forward -n crypto-intel svc/postgres 5432:5432

# En otra terminal
psql -h localhost -p 5432 -U cip_user -d crypto_intel
```

### Ejecutar SQL Dentro del Pod

```bash
kubectl exec -it -n crypto-intel statefulset/postgres -- \
  psql -U cip_user -d crypto_intel -c "SELECT COUNT(*) FROM projects;"
```

---

## 📊 Monitoring

### Health Checks

**Liveness Probe:**
```bash
pg_isready -U $POSTGRES_USER -d $POSTGRES_DB
```

**Readiness Probe:**
```bash
pg_isready -U $POSTGRES_USER -d $POSTGRES_DB
```

### Ver Métricas

```bash
# Uso de CPU y memoria
kubectl top pod -n crypto-intel -l app=postgres

# Eventos
kubectl get events -n crypto-intel --field-selector involvedObject.name=postgres-0
```

---

## 🛠️ Operaciones

### Backup

```bash
# Port forward
kubectl port-forward -n crypto-intel svc/postgres 5432:5432

# Dump
pg_dump -h localhost -p 5432 -U cip_user -d crypto_intel \
  | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### Restore

```bash
# Port forward
kubectl port-forward -n crypto-intel svc/postgres 5432:5432

# Restore
gunzip -c backup.sql.gz | psql -h localhost -p 5432 -U cip_user -d crypto_intel
```

### Escalar (no recomendado para StatefulSet con 1 réplica)

PostgreSQL en este setup es single-instance. Para HA, considera:
- PostgreSQL HA Operators (Zalando, Crunchy Data)
- Cloud managed services (Azure Database for PostgreSQL, RDS, Cloud SQL)

---

## 🔒 Seguridad

- ✅ Non-root user (UID 70)
- ✅ Passwords en Secret
- ✅ fsGroup para permisos de volumen
- ⚠️ **Recomendado:** Network Policies para limitar acceso

Ejemplo de Network Policy:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: postgres-networkpolicy
  namespace: crypto-intel
spec:
  podSelector:
    matchLabels:
      app: postgres
  policyTypes:
  - Ingress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: crypto-intel-app
    ports:
    - protocol: TCP
      port: 5432
```

---

## 🧹 Cleanup

⚠️ **CUIDADO:** Esto eliminará la base de datos y todos los datos.

```bash
# Eliminar StatefulSet y Service
kubectl delete -f statefulset.yaml
kubectl delete -f service.yaml

# Eliminar PVC (datos se perderán)
kubectl delete -f pvc.yaml

# Eliminar configuración
kubectl delete -f configmap.yaml
kubectl delete -f init-scripts-configmap.yaml
kubectl delete -f secret.yaml
```

---

## 📚 Referencias

- [PostgreSQL on Kubernetes](https://www.postgresql.org/docs/14/index.html)
- [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [Persistent Volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
