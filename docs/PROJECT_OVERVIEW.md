# Explicación de los 4 Proyectos

## 1. 🤖 **Platform** (Crypto-Intelligence-Platform)
**Pipeline de Ingestion y Procesamiento**

- **Tecnología:** Python 3.11
- **Propósito:** Recolectar, normalizar y analizar datos de fuentes externas
- **Funcionalidades:**
  - Ingestion de commits de GitHub
  - Normalización de eventos
  - Generación de insights con IA (OpenAI GPT-4o-mini)
  - Multi-idioma: genera insights en español e inglés simultáneamente
- **Salida:** Escribe eventos e insights en PostgreSQL
- **Ejecución:** Pipeline que corre periódicamente o bajo demanda

## 2. 🚀 **API** (Crypto-Intelligence-API)
**Backend REST - Capa de Lectura**

- **Tecnología:** Python 3.11 + FastAPI
- **Propósito:** Exponer datos procesados vía REST API
- **Endpoints:**
  - `/projects` - Lista de proyectos monitorizados
  - `/events` - Timeline de eventos normalizados
  - `/insights` - Análisis de IA con traducciones
- **Características:** CORS habilitado, documentación automática (Swagger)
- **Salida:** JSON con datos para el frontend
- **Docs:** `http://localhost:8000/docs`

## 3. 🎨 **Web** (Crypto-Intelligence-Web)
**Frontend - Visualización**

- **Tecnología:** React 18 + TypeScript + Vite
- **Propósito:** Interfaz de usuario para visualizar datos
- **Páginas:**
  - Dashboard con métricas
  - Events Timeline (línea temporal de eventos)
  - AI Insights con toggle ES/EN 🇪🇸🇬🇧
- **Features:** Hot reload, Axios client, responsive
- **URL:** `http://localhost:5173`

## 4. 🏗️ **Support** (Crypto-Intelligence-Platform-Support)
**Infraestructura Compartida**

- **Tecnología:** Docker Compose, SQL, Templates
- **Propósito:** Artefactos no ejecutables compartidos
- **Contiene:**
  - `db/create_tables.sql` - Schema PostgreSQL (única fuente de verdad)
  - Templates de configuración (.dockerignore, .gitignore, .env)
  - `docker-compose.dev.yml` - Orquestación del stack completo
  - Documentación de arquitectura
- **Principio:** NO contiene código ejecutable, solo referencias

---

## 🔄 Flujo de Datos

```
GitHub/Fuentes 
    ↓
Platform (Ingestion) 
    ↓
PostgreSQL (Database) 
    ↑
API (REST Backend) 
    ↑
Web (React Frontend) 
    ↑
Usuario
```

---

## 🐳 Stack Docker

Todos los servicios se orquestan con Docker Compose:

```yaml
services:
  postgres:      # Base de datos compartida
  platform-app:  # Pipeline de ingestion
  api:           # Backend REST
  web:           # Frontend React
```

**Arquitectura:** Todos los proyectos son independientes, comunicándose únicamente vía PostgreSQL (para datos) y HTTP (API ← Web).

---

## 🎯 Independencia de Proyectos

Cada proyecto:
- ✅ Tiene su propio Dockerfile y dependencias
- ✅ Se despliega independientemente
- ✅ Gestiona su propio código sin dependencias cruzadas
- ✅ Puede desarrollarse y testearse en aislamiento

La única dependencia compartida es el **schema de base de datos** en Support.

---

## 🚀 Levantar el Stack Completo

```bash
# Desde Support/
docker-compose -f docker-compose.dev.yml up -d

# Acceder a:
# Web UI: http://localhost:5173
# API Docs: http://localhost:8000/docs
# PostgreSQL: localhost:5432
```

---

## 📦 Repositorios

| Proyecto | Repositorio | Tecnología |
|----------|-------------|------------|
| Platform | `Crypto-Intelligence-Platform` | Python 3.11 |
| API | `Crypto-Intelligence-API` | Python 3.11 + FastAPI |
| Web | `Crypto-Intelligence-Web` | React 18 + TypeScript |
| Support | `Crypto-Intelligence-Platform-Support` | Docker + SQL + Docs |
