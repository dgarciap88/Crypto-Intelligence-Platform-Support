# Crypto Intelligence Platform - Support

Este es el repositorio de **infraestructura compartida** para el Crypto Intelligence Platform.

## 🎯 Propósito

Proporcionar **artefactos no ejecutables** compartidos entre proyectos:
- ✅ Esquemas de base de datos (única fuente de verdad)
- ✅ Templates de configuración (para copiar a proyectos)
- ✅ Documentación compartida (API specs, arquitectura)
- ✅ Scripts de utilidades de DB (SQL, backups, migrations)

## ⚠️ Principio Arquitectónico

**Cada proyecto (Platform, API, Web) es independiente y autónomo.**

- ❌ **NO compartir código ejecutable** entre proyectos
- ❌ **NO crear dependencias de código** entre proyectos
- ✅ **Cada proyecto gestiona su propio código**
- ✅ **Support solo contiene artefactos de referencia**

Ver [`docs/SHARED_CODE_ANALYSIS.md`](docs/SHARED_CODE_ANALYSIS.md) para detalles.

---

## 📁 Estructura del Proyecto

```
Crypto-Intelligence-Platform-Support/
├── docker-compose.dev.yml       # 🚀 FULL STACK (Platform + API + Web)
├── .env.example                 # Ejemplo de variables de entorno
│
├── db/                          # 📊 Schemas de base de datos compartidos
│   ├── create_tables.sql       # Schema PostgreSQL (única fuente de verdad)
│   └── README.md               # Documentación del schema
│
├── templates/                   # 📋 Templates de configuración
│   ├── .dockerignore-python    # Template para proyectos Python
│   ├── .dockerignore-node      # Template para proyectos Node
│   ├── .gitignore-python       # Template .gitignore Python
│   ├── .gitignore-node         # Template .gitignore Node
│   └── .env.shared.example     # Referencia de variables comunes
│
├── docs/                        # 📖 Documentación compartida
│   ├── SHARED_CODE_ANALYSIS.md # Análisis de arquitectura
│   └── DATABASE_SCHEMA.md      # (TODO) Documentación detallada del schema
│
├── database/                    # Stack de PostgreSQL
│   ├── Dockerfile              # PostgreSQL optimizado
│   ├── docker-compose.yml      # Compose standalone
│   ├── postgresql.conf         # Configuración optimizada
│   ├── init/                   # Scripts de inicialización
│   │   └── 00_init.sql
│   └── README.md
│
├── kubernetes/                  # Manifiestos K8s
│   ├── namespace.yaml
│   ├── postgres/               # PostgreSQL StatefulSet
│   ├── app/                    # App Deployment
│   └── README.md
│
├── scripts/                     # Utilidades
│   ├── backup.sh               # Backup automático
│   ├── backup.bat              # Backup para Windows
│   ├── restore.sh              # Restore de backups
│   ├── deploy.sh               # Deploy automático
│   └── README.md
│
└── README.md                    # Este archivo
```

---

## 🚀 Quick Start

### Environment Variables Setup

```bash
# Copy template and edit with your credentials
cp .env.example .env
```

**Required Variables:**

| Variable | Description | Get From |
|----------|-------------|----------|
| `GITHUB_TOKEN` | GitHub Personal Access Token | [github.com/settings/tokens](https://github.com/settings/tokens) |
| `OPENAI_API_KEY` | OpenAI API Key | [platform.openai.com/api-keys](https://platform.openai.com/api-keys) |

**Optional - Update Schedule Configuration:**

| Variable | Default | Description |
|----------|---------|-------------|
| `GITHUB_UPDATE_INTERVAL_MINUTES` | 360 (6h) | Minutes between GitHub data updates |
| `TWITTER_UPDATE_INTERVAL_MINUTES` | 30 | Minutes between Twitter updates (future) |
| `ONCHAIN_UPDATE_INTERVAL_MINUTES` | 15 | Minutes between on-chain updates (future) |
| `CHECK_INTERVAL_SECONDS` | 60 | Seconds between schedule checks |

> 💡 El sistema funciona en **modo continuo** con actualizaciones automáticas. GitHub se actualiza cada 6 horas por defecto para respetar rate limits.

### Opción 1: **FULL STACK** - Platform + API + Web (RECOMENDADO)

```bash
# 1. Configura tus API keys
cp .env.example .env
# Edita .env y añade tus credenciales

# 2. Levanta todo el stack
docker-compose -f docker-compose.dev.yml up -d

# 3. Accede a:
# - Web UI: http://localhost:5173
# - API Docs: http://localhost:8000/docs
# - PostgreSQL: localhost:5432
```

**Esto levanta:**
- 🗄️ PostgreSQL (base de datos compartida)
- 🤖 Platform App (pipeline de ingestion)
- 🚀 API (backend FastAPI)
- 🎨 Web (frontend React)

### Opción 2: Solo Base de Datos (PostgreSQL Optimizado)

```bash
cd database
docker-compose up -d
```

Esto levanta PostgreSQL 14 con configuración tuneada en puerto 5432.

### Opción 3: Producción - Full Stack (App + DB)

```bash
# 1. Configura variables
cp .env.prod.example .env.prod
# Edita .env.prod con contraseñas seguras

# 2. Levanta stack completo
docker-compose -f docker-compose.prod.yml --env-file .env.prod up -d
```

Esto levanta:
- PostgreSQL optimizado (con resource limits)
- Aplicación Python (con health checks)
- Red interna aislada

### Opción 4: Con PgAdmin (para administración)

```bash
docker-compose -f docker-compose.prod.yml --env-file .env.prod --profile admin up -d
```

Accede a PgAdmin en `http://localhost:5050`

---

## � Database Schema Management

El directorio `db/` contiene los schemas compartidos utilizados por todos los servicios (Platform, API, Web).

### Inicializar Schema

```bash
# Desde el directorio Support
Get-Content db/create_tables.sql | docker exec -i cip-postgres psql -U crypto_user -d crypto_intel
```

### Estructura del Schema

El schema incluye:
- **projects**: Proyectos crypto tracked
- **sources**: Fuentes de datos (GitHub repos, etc)
- **raw_events**: Eventos sin procesar
- **normalized_events**: Eventos normalizados
- **ai_insights**: Análisis generados por IA (multi-idioma: ES/EN)

### Modificar Schema

Cuando necesites modificar el schema:

1. **Edita** `db/create_tables.sql`
2. **Documenta** cambios en `db/README.md`
3. **Actualiza** modelos en:
   - API: `Crypto-Intelligence-API/app/models.py`
   - Frontend: `Crypto-Intelligence-Web/src/types/index.ts`
4. **Aplica** cambios:
   ```bash
   # Recrear schema (⚠️ destruye datos)
   docker exec -i cip-postgres psql -U crypto_user -d crypto_intel -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"
   Get-Content db/create_tables.sql | docker exec -i cip-postgres psql -U crypto_user -d crypto_intel
   ```

Ver `db/README.md` para más detalles.

---

## 📋 Uso de Templates de Configuración

Support proporciona **templates estandarizados** que puedes copiar a tus proyectos.

### Templates Disponibles

| Template | Descripción | Para Proyectos |
|----------|-------------|----------------|
| `.dockerignore-python` | Archivos a excluir en build Docker Python | Platform, API |
| `.dockerignore-node` | Archivos a excluir en build Docker Node | Web |
| `.gitignore-python` | Patrones Git para Python | Platform, API |
| `.gitignore-node` | Patrones Git para Node | Web |
| `.env.shared.example` | Referencia de variables comunes | Todos |

### Cómo Usar Templates

```powershell
# Copiar desde Support a cada proyecto
cd C:\Users\dani8\git

# Para Platform (Python)
Copy-Item Crypto-Intelligence-Platform-Support\templates\.dockerignore-python Crypto-Intelligence-Platform\.dockerignore
Copy-Item Crypto-Intelligence-Platform-Support\templates\.gitignore-python Crypto-Intelligence-Platform\.gitignore

# Para API (Python)
Copy-Item Crypto-Intelligence-Platform-Support\templates\.dockerignore-python Crypto-Intelligence-API\.dockerignore
Copy-Item Crypto-Intelligence-Platform-Support\templates\.gitignore-python Crypto-Intelligence-API\.gitignore

# Para Web (Node/React)
Copy-Item Crypto-Intelligence-Platform-Support\templates\.dockerignore-node Crypto-Intelligence-Web\.dockerignore
Copy-Item Crypto-Intelligence-Platform-Support\templates\.gitignore-node Crypto-Intelligence-Web\.gitignore
```

**Importante:** Después de copiar, cada proyecto puede personalizar según sus necesidades específicas.

---

## �📦 Componentes

### 1. Database Stack

Dockerizado, optimizado para alta concurrencia y queries JSONB.

**Características:**
- PostgreSQL 14 Alpine (imagen ligera)
- Inicialización automática con schema
- Volúmenes persistentes
- Health checks
- Auto-restart

**Uso:**
```bash
cd database
docker-compose up -d

# Ver logs
docker-compose logs -f postgres

# Backup
docker-compose exec postgres pg_dump -U cip_user crypto_intel > backup.sql
```

### 2. Kubernetes Manifests

Manifiestos listos para producción con:
- StatefulSet para PostgreSQL
- Deployment para la app
- Services y ConfigMaps
- Secrets management
- PVC para persistencia

### 3. Scripts de Utilidad

- `backup.sh` - Backup automático de DB
- `restore.sh` - Restore desde backup
- `deploy.sh` - Deploy automatizado

---

## 🔧 Configuración

### Variables de Entorno para Producción

Crea un archivo `.env.prod` en la raíz (usa `.env.prod.example` como plantilla):

```bash
# Database
POSTGRES_DB=crypto_intel
POSTGRES_USER=cip_user
POSTGRES_PASSWORD=CHANGE_THIS_STRONG_PASSWORD_NOW
POSTGRES_PORT=5432

# Application
OPENAI_API_KEY=sk-your-openai-api-key-here
APP_LOG_LEVEL=INFO

# PgAdmin (si usas profile admin)
PGADMIN_EMAIL=admin@cip.local
PGADMIN_PASSWORD=CHANGE_THIS_ADMIN_PASSWORD
PGADMIN_PORT=5050
```

⚠️ **NUNCA** commmitees archivos `.env` o `.env.prod` con credenciales reales.

### Variables para DB Standalone

Si solo usas `database/docker-compose.yml`:

```bash
# Crear database/.env
POSTGRES_DB=crypto_intel
POSTGRES_USER=cip_user
POSTGRES_PASSWORD=your_secure_password
```

---

## 📊 Acceso a PgAdmin

1. Accede a http://localhost:5050
2. Login con credenciales del `.env`
3. Añade servidor:
   - Host: `postgres` (nombre del container)
   - Port: `5432`
   - Username: `cip_user`
   - Password: tu password

---

## 🔒 Seguridad

### Producción

Para producción, asegúrate de:
1. Cambiar todas las contraseñas por defecto
2. Usar secrets de K8s o Docker Swarm
3. Habilitar SSL/TLS en PostgreSQL
4. Limitar acceso por red
5. Backups automáticos regulares

---

## 🛠️ Troubleshooting

### PostgreSQL no inicia

```bash
# Ver logs (producción)
docker-compose -f docker-compose.prod.yml logs postgres

# Ver logs (DB standalone)
cd database/
docker-compose logs postgres

# Verificar permisos
docker exec crypto-intel-db ls -la /var/lib/postgresql/data
```

### No se puede conectar

```bash
# Verificar que el container está corriendo
docker ps | grep crypto-intel

# Test de conexión (producción)
docker exec crypto-intel-db psql -U cip_user -d crypto_intel -c "SELECT 1"

# Test de conexión (DB standalone)
docker exec cip-postgres psql -U cip_user -d crypto_intel -c "SELECT 1"
```

### Resetear base de datos

⚠️ **CUIDADO:** Esto eliminará TODOS los datos.

```bash
# Producción
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml up -d

# DB standalone
cd database/
docker-compose down -v
docker-compose up -d
```

---
Arquitectura Multi-Proyecto

Ver [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) para entender **la separación de responsabilidades** entre proyectos.

**Resumen:**

```
┌──────────────────────────────────────────────────────────┐
│                 Platform (Pipeline)                      │
│  - Ingestion from GitHub, Twitter, etc.                 │
│  - Normalization                                         │
│  - AI Insights Generation                               │
│  - WRITES to PostgreSQL                                 │
└──────────────┬───────────────────────────────────────────┘
               │
               ↓
       ┌─────────────┐
       │ PostgreSQL  │ ← Shared Database
       └─────────────┘
               ↑
               │
┌──────────────┴───────────────────────────────────────────┐
│                   API (Backend)                          │
│  - FastAPI REST endpoints                                │
│  - READS from PostgreSQL                                 │
│  - Serves data to Web                                    │
└──────────────┬───────────────────────────────────────────┘
               │
               ↓
       ┌─────────────┐
       │ Web (React) │ ← User Interface
       │ Visualizes  │
       └─────────────┘
```

**Proyectos:**

1. **`Crypto-Intelligence-Platform`** (Pipeline - WRITE)
   - Código Python, schema SQL, tests
   - `docker-compose.yml` simple para desarrollo standalone
   - Ingestion, Normalization, AI Insights
   
2. **`Crypto-Intelligence-API`** (Backend - READ)
   - FastAPI REST API
   - Read-only access to PostgreSQL
   - Endpoints for projects, events, insights

3. **`Crypto-Intelligence-Web`** (Frontend - DISPLAY)
   - React + TypeScript + Vite
   - Dashboard, Events Timeline, Insights Viewer
   - Consumes API endpoints
   
4. **`Crypto-Intelligence-Platform-Support`** (Infrastructure - ORCHESTRATE)
   - `docker-compose.dev.yml` → Full stack local development
   - `docker-compose.prod.yml` → Production deployment
   - Kubernetes manifests
   - Backup/restore scripts
   - PostgreSQL optimizado

**¿Cuál usar?**
- 🎨 **Desarrollo Full Stack (con UI):** `Support/docker-compose.dev.yml` (Platform + API + Web)
- 🧑‍💻 **Desarrollando solo pipeline:** `Platform/docker-compose.yml` 
- 🚀 **Producción:** `Support/docker-compose.prod.yml`
- 🗄️ **Solo DB optimizada:** `Support/database/docker-compose.yml`

**Links:**
- 🔗 [Platform Project](../Crypto-Intelligence-Platform) - Data ingestion pipeline
- 🔗 [API Project](../Crypto-Intelligence-API) - FastAPI backend
- 🔗 [Web Project](../Crypto-Intelligence-Web) - React frontendt con `docker-compose.prod.yml`
- 🗄️ **Solo necesitas DB optimizada:** Usa `database/docker-compose.yml`

🔗 [Ver App Project](../Crypto-Intelligence-Platform)

---

## 📐 Arquitectura

Ver [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) para entender **la separación de responsabilidades** entre proyectos.

**Resumen:**
- **App Project:** Código Python, schema SQL, docker-compose simple (desarrollo)
- **Support Project:** Infraestructura, PostgreSQL optimizado, K8s, scripts ops (producción)

---

## 🔗 Referencias

- [PostgreSQL Official Docs](https://www.postgresql.org/docs/14/)
- [Docker Compose Docs](https://docs.docker.com/compose/)
- [Kubernetes Docs](https://kubernetes.io/docs/)
- [App Project](../Crypto-Intelligence-Platform)

---

## 🤝 Contribuciones

Para añadir nuevos componentes de infraestructura:
1. Crea una carpeta descriptiva
2. Incluye README específico
3. Documenta las variables de entorno
4. Añade ejemplos de uso
