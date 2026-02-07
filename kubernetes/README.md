# Kubernetes Deployment para Crypto Intelligence Platform

Esta carpeta contiene los manifiestos de Kubernetes para desplegar el Crypto Intelligence Platform.

Ver documentación específica en:
- [postgres/README.md](postgres/README.md) - PostgreSQL StatefulSet
- [app/README.md](app/README.md) - Application Deployment y CronJob

---

## 📁 Estructura

```
kubernetes/
├── namespace.yaml              # Namespace crypto-intel
├── postgres/                   # PostgreSQL StatefulSet
│   ├── configmap.yaml         # Configuración
│   ├── init-scripts-configmap.yaml  # Scripts SQL
│   ├── pvc.yaml               # PersistentVolumeClaim (20GB)
│   ├── service.yaml           # Services
│   ├── statefulset.yaml       # StatefulSet
│   ├── secret.yaml.example    # Ejemplo de secret
│   └── README.md              # Docs PostgreSQL
└── app/                        # Aplicación Python
    ├── configmap.yaml         # Configuración
    ├── deployment.yaml        # Deployment (2 réplicas)
    ├── service.yaml           # Service
    ├── cronjob.yaml           # Pipeline periódico
    ├── secret.yaml.example    # Ejemplo de secret
    └── README.md              # Docs App
```

---

## 📁 Estructura

```
kubernetes/
├── namespace.yaml
├── postgres/
│   ├── configmap.yaml
│   ├── secret.yaml
│   ├── pvc.yaml
│   ├── statefulset.yaml
│   └── service.yaml
└── app/
    ├── configmap.yaml
    ├── secret.yaml
    ├── deployment.yaml
    └── service.yaml
```

## 🚀 Despliegue Rápido

### 1. Prerrequisitos

- Kubernetes cluster (minikube, AKS, EKS, GKE)
- `kubectl` configurado
- Registry de imágenes Docker

### 2. Crear Secrets

⚠️ **Nunca commitees secrets reales**

```bash
# PostgreSQL
cp postgres/secret.yaml.example postgres/secret.yaml
# Edita con: echo -n 'password' | base64

# App
cp app/secret.yaml.example app/secret.yaml
# Edita con credentials en base64
```

### 3. Aplicar Manifiestos

```bash
# Namespace
kubectl apply -f namespace.yaml

# PostgreSQL
kubectl apply -f postgres/secret.yaml
kubectl apply -f postgres/

# App
kubectl apply -f app/secret.yaml
kubectl apply -f app/
```

### 4. Verificar

```bash
kubectl get all -n crypto-intel
kubectl logs -n crypto-intel -l app=postgres
kubectl logs -n crypto-intel -l app=crypto-intel-app
```
---

## 🔧 Operaciones Comunes

Ver documentación detallada en [postgres/README.md](postgres/README.md) y [app/README.md](app/README.md).

### Escalar App

```bash
kubectl scale deployment crypto-intel-app -n crypto-intel --replicas=3
```

### Ver Logs

```bash
kubectl logs -n crypto-intel -l app=crypto-intel-app --tail=100 -f
kubectl logs -n crypto-intel -l app=postgres --tail=100 -f
```

### Ejecutar Pipeline

```bash
kubectl exec -it -n crypto-intel deployment/crypto-intel-app -- \
  python run_pipeline.py --project-id arbitrum --days 7
```

### Port Forward

```bash
kubectl port-forward -n crypto-intel svc/postgres 5432:5432
kubectl port-forward -n crypto-intel svc/crypto-intel-app 8000:8000
```

### Backup DB

```bash
kubectl port-forward -n crypto-intel svc/postgres 5432:5432
pg_dump -h localhost -U cip_user crypto_intel | gzip > backup.sql.gz
```

---       kubectl apply -f kubernetes/
```

## 🧪 Testing en Minikube

```bash
# Iniciar minikube
minikube start --cpus 4 --memory 8192

# Usar Docker de minikube
eval $(minikube docker-env)

# Build imagen
cd ../../Crypto-Intelligence-Platform
docker build -t crypto-intel-app:latest .
cd ../Crypto-Intelligence-Platform-Support/kubernetes/

# Aplicar manifiestos
kubectl apply -f namespace.yaml
kubectl apply -f postgres/secret.yaml
kubectl apply -f postgres/
kubectl apply -f app/secret.yaml
kubectl apply -f app/

# Ver estado
kubectl get all -n crypto-intel
```

---

## 📚 Referencias

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [StatefulSets](https://kubernetes.io/docs/concepts/workloads/controllers/statefulset/)
- [postgres/README.md](postgres/README.md) - Docs PostgreSQL
- [app/README.md](app/README.md) - Docs App

---

## 🔗 Proyectos Relacionados

- [Crypto-Intelligence-Platform](../../Crypto-Intelligence-Platform/) - Código de aplicación
- [../docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md) - Arquitectura de proyectos
- [../docker-compose.prod.yml](../docker-compose.prod.yml) - Docker Compose para prod

