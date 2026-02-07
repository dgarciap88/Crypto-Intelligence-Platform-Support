# 📐 Arquitectura de Proyectos - CIP

Estructura y separación de responsabilidades entre los dos proyectos del Crypto Intelligence Platform.

---

## 🎯 Filosofía de Separación

### **Crypto-Intelligence-Platform** (Aplicación)
Código de la aplicación, lógica de negocio, schema de datos.  
**Propósito:** Desarrollo de features, pipeline de datos, lógica de análisis.

### **Crypto-Intelligence-Platform-Support** (Infraestructura)
Docker production, Kubernetes, scripts de operaciones, configuraciones optimizadas.  
**Propósito:** Deployment, operaciones, infraestructura, devops.

---

## 📁 Estructura Detallada

### Crypto-Intelligence-Platform (Aplicación)

```
Crypto-Intelligence-Platform/
├── ingestion/              # Scripts de ingesta
│   ├── github/            # GitHub data
│   ├── normalize.py       # Normalización
│   └── generate_insights.py
├── db/                    # Database schema
│   └── create_tables.sql  # Schema inicial
├── docs/                  # Documentación de aplicación
│   ├── pipeline.md        # Pipeline de datos
│   ├── db-schema.md       # Esquema de base de datos
│   ├── project-schema.md  # Formato de projects
│   ├── SETUP.md           # Setup local
│   ├── DOCKER.md          # 🐳 Docker para desarrollo
│   └── IMPLEMENTATION.md
├── Dockerfile             # 🐳 App container (dev/prod)
├── docker-compose.yml     # 🐳 Stack simple para desarrollo
├── .dockerignore
├── project.yaml           # Config de proyecto ejemplo
├── requirements.txt       # Dependencies Python
├── run_pipeline.py        # Orquestador del pipeline
├── query_insights.py      # Query de resultados
├── add_project.py         # Helper para añadir projects
└── README.md             # Documentación principal
```

**Responsabilidades:**
- ✅ Código Python de la aplicación
- ✅ Schema de base de datos (SQL)
- ✅ Pipeline de datos (ingest → normalize → insights)
- ✅ Dockerfile de la app
- ✅ docker-compose.yml **simple para desarrollo local**
- ✅ Documentación de features y uso
- ✅ Tests unitarios (futuro)

---

### Crypto-Intelligence-Platform-Support (Infraestructura)

```
Crypto-Intelligence-Platform-Support/
├── database/               # 🐳 PostgreSQL Stack
│   ├── Dockerfile         # PostgreSQL optimizado
│   ├── docker-compose.yml # DB standalone
│   ├── postgresql.conf    # Config tuneada (JSONB, memoria, WAL)
│   ├── init/
│   │   └── 00_init.sql   # Extensiones, usuarios, permisos
│   ├── .env.example
│   └── README.md          # DB setup guide
│
├── kubernetes/            # ☸️ K8s Manifests
│   ├── namespace.yaml
│   ├── postgres/         # StatefulSet, PVC, Service
│   ├── app/              # Deployment, ConfigMap, Secret
│   └── README.md         # K8s deployment guide
│
├── scripts/              # 🛠️ Operaciones
│   ├── backup.sh         # Backup automático
│   ├── backup.bat        # Backup Windows
│   ├── restore.sh        # Restore de backups
│   ├── deploy.sh         # Deploy automatizado
│   └── README.md         # Scripts guide
│
├── docs/                 # 📚 Docs de infraestructura
│   └── DOCKER-PRODUCTION.md  # 🐳 Guía completa producción
│
├── docker-compose.prod.yml   # 🐳 Stack completo producción
├── .env.prod.example          # Variables de producción
├── .gitignore                 # Protección de secrets
└── README.md                  # Overview de infraestructura
```

**Responsabilidades:**
- ✅ Dockerfile de PostgreSQL optimizado
- ✅ docker-compose.yml **de producción** (stack completo)
- ✅ DB standalone para desarrollo externo
- ✅ Configuraciones de PostgreSQL (performance tuning)
- ✅ Manifiestos de Kubernetes
- ✅ Scripts de backup/restore/deploy
- ✅ Documentación de infraestructura y operaciones
- ✅ Templates de CI/CD (futuro)
- ✅ Monitoring setup (Prometheus, Grafana) (futuro)

---

## 🔄 Workflows

### Desarrollo Local (Developer)

```bash
# Trabajar en código de la app
cd Crypto-Intelligence-Platform

# Opción 1: Todo en Docker (recomendado)
docker-compose up -d
docker-compose logs -f
docker-compose exec app python query_insights.py --project-id arbitrum

# Opción 2: Solo DB en Docker, app local
docker-compose up -d postgres
source venv/bin/activate
export DATABASE_URL="postgresql://cip_user:cip_password@localhost:5432/crypto_intel"
python run_pipeline.py --project-id arbitrum
```

**Usa:** `Crypto-Intelligence-Platform/docker-compose.yml`

---

### Producción (DevOps)

```bash
# Deployment en servidor/cloud
cd Crypto-Intelligence-Platform-Support

# Configurar secrets de producción
cp .env.prod.example .env
# Editar .env con valores reales y fuertes

# Deploy con docker-compose
docker-compose -f docker-compose.prod.yml up -d

# O usar script automatizado
cd scripts
./deploy.sh

# Backups automáticos (cron)
crontab -e
# 0 2 * * * cd /path/to/Support/scripts && ./backup.sh
```

**Usa:** `Crypto-Intelligence-Platform-Support/docker-compose.prod.yml`

---

### Kubernetes (K8s Cluster)

```bash
cd Crypto-Intelligence-Platform-Support/kubernetes

# Crear secrets
kubectl create secret generic cip-secrets \
  --from-literal=postgres-password=xxx \
  --from-literal=github-token=xxx \
  --from-literal=openai-api-key=xxx \
  -n cip

# Deploy
kubectl apply -f namespace.yaml
kubectl apply -f postgres/
kubectl apply -f app/

# Verificar
kubectl get all -n cip
```

**Usa:** `Crypto-Intelligence-Platform-Support/kubernetes/`

---

## 🔗 Relaciones entre Proyectos

### Development → Production

```
┌─────────────────────────────────────┐
│  Crypto-Intelligence-Platform       │
│  (Desarrollo)                       │
│                                     │
│  • Código Python                   │
│  • Schema SQL                       │
│  • docker-compose.yml (simple)      │
│  • Dockerfile de app               │
└──────────────┬──────────────────────┘
               │
               │ git push
               ▼
┌─────────────────────────────────────┐
│  Crypto-Intelligence-Platform       │
│  (Git Repo - main branch)           │
└──────────────┬──────────────────────┘
               │
               │ docker build
               │ (en producción)
               ▼
┌─────────────────────────────────────┐
│  Crypto-Intelligence-Platform-      │
│  Support (Infraestructura)          │
│                                     │
│  • docker-compose.prod.yml          │
│  • Dockerfile PostgreSQL optimizado│
│  • Kubernetes manifests            │
│  • Scripts de ops                  │
└─────────────────────────────────────┘
               │
               ▼
        🚀 PRODUCCIÓN
```

### Referencias en Docker Compose

En `Support/docker-compose.prod.yml`:

```yaml
app:
  build:
    context: ../../Crypto-Intelligence-Platform  # ← Referencia al proyecto de app
    dockerfile: Dockerfile
  volumes:
    - ../../Crypto-Intelligence-Platform/project.yaml:/app/project.yaml:ro

postgres:
  volumes:
    - ../../Crypto-Intelligence-Platform/db/create_tables.sql:/docker-entrypoint-initdb.d/02_schema.sql:ro
                                          # ← Usa schema del proyecto de app
```

---

## 📋 Guía de Ubicación de Archivos

### ¿Dónde va cada archivo?

| Archivo/Directorio | Ubicación | Razón |
|-------------------|-----------|-------|
| Código Python (.py) | **App** | Lógica de aplicación |
| requirements.txt | **App** | Dependencies de Python |
| db/create_tables.sql | **App** | Schema es parte de la app |
| Dockerfile (app) | **App** | Build de la aplicación |
| docker-compose.yml (dev) | **App** | Desarrollo rápido |
| Dockerfile (postgres) | **Support** | Optimizado para producción |
| docker-compose.prod.yml | **Support** | Stack de producción |
| postgresql.conf | **Support** | Tuning de infraestructura |
| kubernetes/* | **Support** | Deployment de infra |
| scripts/backup.sh | **Support** | Operaciones |
| docs/pipeline.md | **App** | Docs de features |
| docs/DOCKER-PRODUCTION.md | **Support** | Docs de infraestructura |

---

## 🎨 Casos de Uso

### Caso 1: Desarrollador añade nueva feature

```bash
cd Crypto-Intelligence-Platform

# 1. Crear rama
git checkout -b feature/twitter-ingestion

# 2. Desarrollar (usar docker-compose local)
docker-compose up -d
# Desarrollar ingestion/twitter/...

# 3. Test
docker-compose exec app python -m pytest tests/

# 4. Commit y push
git commit -am "Add Twitter ingestion"
git push origin feature/twitter-ingestion

# 5. PR y merge a main
```

**No toca Support.**

---

### Caso 2: DevOps optimiza PostgreSQL

```bash
cd Crypto-Intelligence-Platform-Support

# 1. Editar configuración
vim database/postgresql.conf
# Ajustar shared_buffers, work_mem, etc.

# 2. Rebuild
cd database
docker-compose build

# 3. Test localmente
docker-compose up -d
# Verificar performance

# 4. Deploy en producción
cd ..
docker-compose -f docker-compose.prod.yml build postgres
docker-compose -f docker-compose.prod.yml up -d postgres

# 5. Commit cambios
git commit -am "Optimize PostgreSQL config for JSONB queries"
```

**No toca App.**

---

### Caso 3: Añadir columna en DB

```bash
cd Crypto-Intelligence-Platform

# 1. Crear migración SQL
vim db/migrations/002_add_insights_metadata.sql

# 2. Actualizar create_tables.sql si es necesario

# 3. Test en desarrollo
docker-compose down -v
docker-compose up -d
docker-compose exec postgres psql -U cip_user -d crypto_intel < db/migrations/002_add_insights_metadata.sql

# 4. Commit
git commit -am "Add metadata column to insights table"
```

**Support no necesita cambios** (usa schema de App).

---

## 🔐 Secrets Management

### Desarrollo (App)
```bash
# .env (commiteable con valores dummy)
POSTGRES_PASSWORD=cip_password  # OK para dev
GITHUB_TOKEN=ghp_xxx            # Personal dev token
```

### Producción (Support)
```bash
# .env (NUNCA commitear)
POSTGRES_PASSWORD=XyZ$tr0ng_P@ssw0rd_32Chars  # Fuerte y aleatorio
GITHUB_TOKEN=ghp_prod_token                    # Token de producción
OPENAI_API_KEY=sk-prod_key                     # Key de producción
```

**Archivo `.gitignore` en Support:**
```
.env
.env.prod
*.sql
*.sql.gz
backups/
```

---

## 🚀 CI/CD Pipeline (Futuro)

```yaml
# .github/workflows/ci-cd.yml (en App repo)

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run tests
        run: |
          docker-compose up -d postgres
          pip install -r requirements.txt
          pytest tests/
  
  build:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - name: Build and push image
        run: |
          docker build -t myregistry/cip-app:${{ github.sha }} .
          docker push myregistry/cip-app:${{ github.sha }}
  
  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to production
        run: |
          # SSH a servidor de producción
          # cd Crypto-Intelligence-Platform-Support
          # docker-compose -f docker-compose.prod.yml pull
          # docker-compose -f docker-compose.prod.yml up -d
```

---

## 📚 Documentación por Audiencia

### Desarrolladores (Features)
- [App/README.md](../Crypto-Intelligence-Platform/README.md)
- [App/docs/pipeline.md](../Crypto-Intelligence-Platform/docs/pipeline.md)
- [App/docs/SETUP.md](../Crypto-Intelligence-Platform/docs/SETUP.md)
- [App/docs/DOCKER.md](../Crypto-Intelligence-Platform/docs/DOCKER.md) ← Desarrollo local

### DevOps/SRE (Infraestructura)
- [Support/README.md](README.md)
- [Support/docs/DOCKER-PRODUCTION.md](docs/DOCKER-PRODUCTION.md) ← Producción
- [Support/database/README.md](database/README.md)
- [Support/kubernetes/README.md](kubernetes/README.md)
- [Support/scripts/README.md](scripts/README.md)

---

## ✅ Resumen

| Aspecto | Proyecto App | Proyecto Support |
|---------|-------------|------------------|
| **Propósito** | Código de aplicación | Infraestructura y ops |
| **Audiencia** | Developers | DevOps/SRE |
| **Docker Compose** | Simple (dev local) | Completo (producción) |
| **PostgreSQL** | Básico (imagen alpine) | Optimizado (Dockerfile custom) |
| **Documentación** | Features y uso | Deployment y operaciones |
| **CI/CD** | Tests y build | Deploy |
| **Secrets** | Dev/dummy | Producción/fuertes |
| **Updates** | Frecuentes (features) | Esporádicos (infra) |

---

**Separación limpia = Mejor mantenimiento** ✨
