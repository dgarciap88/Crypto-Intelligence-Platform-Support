# Análisis de Elementos Compartidos entre Proyectos

## ⚠️ Principio Arquitectónico Fundamental

**Cada proyecto (Platform, API, Web) debe ser independiente y autónomo.**

- ❌ **NO compartir código ejecutable** entre proyectos
- ❌ **NO crear dependencias de código** entre proyectos  
- ❌ **NO librerías/módulos compartidos** que requieran imports cruzados
- ✅ **SÍ duplicar código** si mantiene independencia de proyectos
- ✅ **Cada proyecto gestiona su propio código** dentro de su contenedor

**Razón:** Cada proyecto tiene su propio ciclo de vida, despliegue y contenedor Docker independiente.

---

## 🎯 Propósito del Proyecto Support

Support debe contener **SOLO artefactos no ejecutables** que sirvan como fuente de verdad:

### ✅ Lo que SÍ va en Support

1. **Esquemas de Base de Datos**
   - `db/create_tables.sql` ✅ YA EXISTE
   - Migrations SQL
   - Scripts de inicialización
   - **Razón:** Schema es la única fuente de verdad compartida por todos

2. **Templates de Configuración** (para copiar, no importar)
   - `.dockerignore-python` / `.dockerignore-node`
   - `.gitignore-python` / `.gitignore-node`
   - `.env.example` con variables comunes documentadas
   - **Razón:** Estandarizar configuraciones, pero cada proyecto tiene su copia

3. **Documentación Compartida**
   - Especificaciones de API
   - Documentación del schema
   - Guías de arquitectura
   - **Razón:** Conocimiento compartido, no código

4. **Scripts de Utilidades de DB** (SQL, no código app)
   - Scripts de backup
   - Scripts de migrations
   - Queries de verificación
   - **Razón:** Operaciones sobre la base de datos, no lógica de app

### ❌ Lo que NO va en Support

1. **Código Python/JavaScript compartido**
   - ❌ NO `shared/python/database_utils.py`
   - ❌ NO `shared/python/config_loader.py`
   - ❌ NO utilidades de código para importar
   - **Alternativa:** Cada proyecto tiene su propia capa de DB

2. **Librerías o Módulos Compartidos**
   - ❌ NO crear dependencias de código entre proyectos
   - **Alternativa:** Duplicar código si es necesario

3. **Imágenes Docker Base Compartidas**
   - ❌ NO Dockerfile.base para múltiples proyectos
   - **Alternativa:** Cada proyecto define su propio Dockerfile

---

## 📁 Estructura Correcta de Support

```
Support/
├── db/                          # ✅ Esquemas y SQL
│   ├── create_tables.sql        # ✅ YA EXISTE
│   ├── README.md                # ✅ YA EXISTE
│   └── migrations/              # 🆕 Migrations SQL
│       └── 001_add_translations.sql
├── templates/                   # ✅ Templates de configuración
│   ├── .dockerignore-python     # ✅ YA EXISTE
│   ├── .dockerignore-node       # 🆕 Para Web
│   ├── .gitignore-python        # 🆕 Template Python
│   ├── .gitignore-node          # 🆕 Template Node
│   └── .env.shared.example      # 🆕 Variables comunes documentadas
├── scripts/                     # 🆕 Scripts de utilidades (SQL/bash)
│   ├── backup_db.sh
│   ├── migrate_db.sh
│   └── verify_schema.sql
└── docs/                        # ✅ Documentación
    ├── SHARED_CODE_ANALYSIS.md  # Este documento
    ├── DATABASE_SCHEMA.md       # Documentación del schema
    └── API_SPECS.md             # Especificaciones de API
```

---

## 🔄 Qué Hacer en Cada Proyecto

### Platform (Python - Ingestion)

**Mantener dentro del proyecto:**
- Propia capa de conexión a DB (puede ser simple psycopg2)
- Propia configuración de environment
- Propios scripts de ingestion
- Propios Dockerfile y docker-compose

**Usar de Support:**
- Copiar template `.dockerignore-python`
- Copiar template `.gitignore-python`
- Referenciar `Support/db/create_tables.sql` para inicializar DB
- Consultar docs de schema

### API (Python - FastAPI)

**Mantener dentro del proyecto:**
- `app/database.py` con su connection pool (YA BIEN HECHO)
- Propia configuración de FastAPI
- Propios modelos Pydantic
- Propios routers

**Usar de Support:**
- Copiar templates de configuración
- Referenciar schema de DB
- Seguir especificaciones de API docs

### Web (Node/React)

**Mantener dentro del proyecto:**
- Propia configuración de Vite
- Propios componentes React
- Propios types TypeScript
- Propio API client

**Usar de Support:**
- Copiar template `.dockerignore-node`
- Copiar template `.gitignore-node`
- Seguir API specs de docs

---

## ✅ Templates a Crear en Support

### 1. `.gitignore-python` Template
```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
.venv/
.env
.pytest_cache/
.mypy_cache/
.coverage

# IDEs
.idea/
*.swp
*.swo
```

### 2. `.gitignore-node` Template
```gitignore
# Node
node_modules/
dist/
build/
.env
.env.local
.env.*.local

# IDEs
.idea/

# Logs
npm-debug.log*
yarn-debug.log*
yarn-error.log*
```

### 3. `.dockerignore-node` Template
```dockerignore
node_modules/
npm-debug.log
.git/
.gitignore
README.md
.env
.env.local
dist/
build/
```

### 4. `.env.shared.example` - Variables Comunes Documentadas
```bash
# ===========================================
# Crypto Intelligence Platform
# Shared Environment Variables Reference
# ===========================================
# Copiar a cada proyecto y ajustar según necesidad

# Database Configuration
DATABASE_URL=postgresql://crypto_user:crypto_pass@postgres:5432/crypto_intel
# Platform usa: postgres:5432 (desde contenedor)
# API usa: postgres:5432 (desde contenedor)
# Local host usa: localhost:5432

# OpenAI Configuration (solo Platform)
OPENAI_API_KEY=your_openai_api_key_here

# API Configuration (solo API)
CORS_ORIGINS=http://localhost:5173,http://localhost:3000
```

---

## 📖 Uso de Templates

### Para copiar un template:

```powershell
# Desde Support/ a Platform/
Copy-Item Support/templates/.dockerignore-python Platform/.dockerignore

# Desde Support/ a API/
Copy-Item Support/templates/.dockerignore-python API/.dockerignore
Copy-Item Support/templates/.gitignore-python API/.gitignore

# Desde Support/ a Web/
Copy-Item Support/templates/.dockerignore-node Web/.dockerignore
Copy-Item Support/templates/.gitignore-node Web/.gitignore
```

**Importante:** Después de copiar, cada proyecto puede personalizar según sus necesidades.

---

## 🎯 Resumen

| Elemento | ¿Va en Support? | Razón |
|----------|-----------------|-------|
| **Schemas SQL** | ✅ SÍ | Fuente de verdad compartida |
| **Migrations SQL** | ✅ SÍ | Versionado del schema |
| **Templates config** | ✅ SÍ | Estandarización (copiar) |
| **Documentación** | ✅ SÍ | Conocimiento compartido |
| **Scripts SQL** | ✅ SÍ | Operaciones de DB |
| **Código Python** | ❌ NO | Cada proyecto independiente |
| **Librerías compartidas** | ❌ NO | Mantener independencia |
| **Imágenes Docker base** | ❌ NO | Cada proyecto su Dockerfile |

---

## 🚀 Próximos Pasos

1. ✅ Mantener `Support/db/` como está (YA CORRECTO)
2. 🆕 Crear templates de configuración en `Support/templates/`
3. 🆕 Crear documentación de API en `Support/docs/API_SPECS.md`
4. 🆕 Documentar schema detalladamente en `Support/docs/DATABASE_SCHEMA.md`
5. 📋 Copiar templates relevantes a cada proyecto
6. ✅ Cada proyecto mantiene su código independiente

**Filosofía:** Support es el "manual de referencia" compartido, no una librería de código.
