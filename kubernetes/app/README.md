# Application Kubernetes Manifests

Manifiestos para desplegar la aplicación Crypto Intelligence Platform.

---

## 📦 Archivos

- **configmap.yaml** - Variables de entorno no sensibles
- **secret.yaml.example** - Plantilla para credenciales (DB, OpenAI API)
- **deployment.yaml** - Deployment con 2 réplicas y health checks
- **service.yaml** - Service ClusterIP
- **cronjob.yaml** - CronJob para ejecutar pipeline periódicamente

---

## 🚀 Uso

### 1. Build y Push de Imagen

```bash
# Desde Crypto-Intelligence-Platform/
docker build -t your-registry.azurecr.io/crypto-intel-app:latest .
docker push your-registry.azurecr.io/crypto-intel-app:latest
```

O para minikube:
```bash
eval $(minikube docker-env)
docker build -t crypto-intel-app:latest .
```

### 2. Crear Secret

```bash
# Copiar ejemplo
cp secret.yaml.example secret.yaml

# Generar valores en base64
echo -n 'cip_user' | base64
echo -n 'tu_password_db' | base64
echo -n 'sk-your-openai-key' | base64

# Editar secret.yaml con los resultados
# IMPORTANTE: Añadir secret.yaml a .gitignore
```

### 3. Aplicar Manifiestos

```bash
# Desde kubernetes/
kubectl apply -f app/secret.yaml
kubectl apply -f app/configmap.yaml
kubectl apply -f app/deployment.yaml
kubectl apply -f app/service.yaml

# Opcional: Pipeline automático
kubectl apply -f app/cronjob.yaml
```

O todos a la vez:
```bash
kubectl apply -f app/
```

### 4. Verificar

```bash
# Ver pods
kubectl get pods -n crypto-intel -l app=crypto-intel-app

# Ver logs
kubectl logs -n crypto-intel -l app=crypto-intel-app --tail=50 -f

# Ver deployment
kubectl describe deployment crypto-intel-app -n crypto-intel
```

---

## 🔧 Configuración

### Variables de Entorno (ConfigMap)

- `APP_LOG_LEVEL`: INFO, DEBUG, WARNING, ERROR
- `DB_HOST`: postgres
- `DB_PORT`: 5432
- `DB_NAME`: crypto_intel
- `PIPELINE_BATCH_SIZE`: Tamaño de batch (default: 100)
- `INSIGHT_COOLDOWN_HOURS`: Horas antes de regenerar insights (default: 12)

### Secrets (Base64 Encoded)

- `DB_USER`: Usuario de PostgreSQL
- `DB_PASSWORD`: Contraseña de PostgreSQL
- `OPENAI_API_KEY`: API key de OpenAI (obligatorio)
- `GITHUB_TOKEN`: Token de GitHub (opcional, mejora rate limits)

### Recursos

```yaml
requests:
  memory: 256Mi
  cpu: 250m
limits:
  memory: 1Gi
  cpu: 1000m
```

Ajustar según necesidades.

---

## 🔄 CronJob (Pipeline Automático)

El CronJob ejecuta el pipeline periódicamente:

- **Schedule:** Cada 6 horas (`0 */6 * * *`)
- **Comando:** `python run_pipeline.py --days 7 --all-projects`
- **Concurrency:** Forbid (no overlap)

Modificar en `cronjob.yaml`:
```yaml
spec:
  schedule: "0 */4 * * *"  # Cada 4 horas
```

### Ver Jobs del CronJob

```bash
# Listar jobs
kubectl get jobs -n crypto-intel -l component=pipeline

# Ver logs del último job
kubectl logs -n crypto-intel -l component=pipeline --tail=100
```

---

## 🛠️ Operaciones

### Escalar Aplicación

```bash
# Cambiar réplicas
kubectl scale deployment crypto-intel-app -n crypto-intel --replicas=3

# Ver estado
kubectl get pods -n crypto-intel -l app=crypto-intel-app
```

### Ejecutar Pipeline Manualmente

```bash
# Opción 1: Dentro de un pod existente
kubectl exec -it -n crypto-intel deployment/crypto-intel-app -- \
  python run_pipeline.py --project-id arbitrum --days 7

# Opción 2: Job ad-hoc (basado en el deployment)
kubectl create job --from=cronjob/crypto-intel-pipeline manual-run-1 -n crypto-intel
```

### Ver Insights

```bash
kubectl exec -it -n crypto-intel deployment/crypto-intel-app -- \
  python query_insights.py --project-id arbitrum
```

### Añadir Proyecto

```bash
kubectl exec -it -n crypto-intel deployment/crypto-intel-app -- \
  python add_project.py --project-file /path/to/project.yaml
```

### Rolling Update

```bash
# Actualizar imagen
kubectl set image deployment/crypto-intel-app -n crypto-intel \
  app=your-registry.azurecr.io/crypto-intel-app:v2.0

# Ver progreso
kubectl rollout status deployment/crypto-intel-app -n crypto-intel

# Rollback si hay problemas
kubectl rollout undo deployment/crypto-intel-app -n crypto-intel
```

---

## 📊 Monitoring

### Health Checks

**Liveness Probe:**
- Verifica conexión a DB cada 30s
- Falla después de 3 intentos fallidos

**Readiness Probe:**
- Ejecuta query simple a DB cada 10s
- Pod no recibe tráfico si falla

### Logs

```bash
# Todos los pods de app
kubectl logs -n crypto-intel -l app=crypto-intel-app --tail=100 -f

# Pod específico
kubectl logs -n crypto-intel <pod-name> --tail=100 -f

# Logs de inicialización
kubectl logs -n crypto-intel <pod-name> -c wait-for-postgres
```

### Métricas

```bash
# Uso de recursos
kubectl top pod -n crypto-intel -l app=crypto-intel-app

# Eventos
kubectl get events -n crypto-intel --sort-by='.lastTimestamp'
```

---

## 🌐 Exponer Externamente

### Opción 1: Port Forward (desarrollo)

```bash
kubectl port-forward -n crypto-intel svc/crypto-intel-app 8000:8000

# Acceso en http://localhost:8000
```

### Opción 2: LoadBalancer (cloud)

Modifica `service.yaml`:
```yaml
spec:
  type: LoadBalancer
  ports:
  - name: http
    port: 80
    targetPort: 8000
```

### Opción 3: Ingress (recomendado)

Crea `ingress.yaml`:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: crypto-intel-ingress
  namespace: crypto-intel
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - api.crypto-intel.yourdomain.com
    secretName: crypto-intel-tls
  rules:
  - host: api.crypto-intel.yourdomain.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: crypto-intel-app
            port:
              number: 8000
```

---

## 🔒 Seguridad

- ✅ Non-root user (UID 1000)
- ✅ Secrets separados de config
- ✅ fsGroup para permisos
- ⚠️ **Recomendado:** Network Policies

Ejemplo de Network Policy:
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: app-networkpolicy
  namespace: crypto-intel
spec:
  podSelector:
    matchLabels:
      app: crypto-intel-app
  policyTypes:
  - Egress
  egress:
  - to:
    - podSelector:
        matchLabels:
          app: postgres
    ports:
    - protocol: TCP
      port: 5432
  - to:
    - namespaceSelector: {}
    ports:
    - protocol: TCP
      port: 443  # HTTPS para OpenAI API
```

---

## 🧹 Cleanup

```bash
# Eliminar CronJob
kubectl delete -f cronjob.yaml

# Eliminar Deployment y Service
kubectl delete -f deployment.yaml
kubectl delete -f service.yaml

# Eliminar configuración
kubectl delete -f configmap.yaml
kubectl delete -f secret.yaml
```

---

## 📚 Referencias

- [Deployments](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/)
- [ConfigMaps](https://kubernetes.io/docs/concepts/configuration/configmap/)
- [Secrets](https://kubernetes.io/docs/concepts/configuration/secret/)
- [CronJobs](https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/)
