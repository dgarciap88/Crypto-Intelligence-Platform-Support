# Docker Production Deployment Guide

Guía completa para deployment en **producción** del Crypto Intelligence Platform usando Docker.

> 📘 **Para desarrollo local**, ver: [App/docs/DOCKER.md](../../Crypto-Intelligence-Platform/docs/DOCKER.md)

---

## 🎯 Arquitectura de Producción

```
Crypto-Intelligence-Platform-Support/
│
├── docker-compose.prod.yml    ← Stack completo de producción
├── database/
│   ├── Dockerfile              ← PostgreSQL optimizado
│   ├── docker-compose.yml      ← DB standalone
│   └── postgresql.conf         ← Configuración tuneada
└── scripts/
    ├── backup.sh               ← Backups automáticos
    ├── restore.sh              ← Restore
    └── deploy.sh               ← Deploy automatizado
```

---

## 🚀 Quick Start Producción

```bash
cd Crypto-Intelligence-Platform-Support

# 1. Configurar secrets de producción
cp .env.prod.example .env
# ⚠️ Editar con valores FUERTES y REALES

# 2. Deploy stack completo
docker-compose -f docker-compose.prod.yml up -d

# 3. Verificar
docker-compose -f docker-compose.prod.yml ps

# 4. Ver logs
docker-compose -f docker-compose.prod.yml logs -f
```

---

## 📦 Stack de Producción

### Componentes

#### 1. PostgreSQL (Optimizado)
- **Image:** Custom (./database/Dockerfile)
- **Config:** postgresql.conf tuneado para JSONB
- **Features:**
  - Shared buffers optimizados
  - WAL configurado para alta escritura
  - Autovacuum ajustado
  - pg_stat_statements habilitado
  - Health checks
  - Resource limits
- **Volumes:** 
  - Datos persistentes
  - Logs
  - Backups

#### 2. CIP Application
- **Image:** Custom desde proyecto principal
- **Features:**
  - Usuario no-root
  - Health checks
  - Resource limits
  - Auto-restart
- **Volumes:**
  - project.yaml (read-only)
  - Logs de aplicación

#### 3. PgAdmin (Opcional - profile admin)
- **Port:** 5050
- **Uso:** Administración visual de DB
- **Activar:** `--profile admin`

#### 4. PostgreSQL Exporter (Opcional - profile monitoring)
- **Port:** 9187
- **Uso:** Métricas para Prometheus
- **Activar:** `--profile monitoring`

---

## 🔧 Configuración de Producción

### Variables de Entorno (.env)

```bash
# ⚠️ USAR VALORES FUERTES EN PRODUCCIÓN

# Database
POSTGRES_DB=crypto_intel
POSTGRES_USER=cip_user
POSTGRES_PASSWORD=USE_STRONG_PASSWORD_HERE_32_CHARS_MIN
POSTGRES_PORT=5432

# Application
GITHUB_TOKEN=ghp_real_token_here
OPENAI_API_KEY=sk-real_key_here

# Admin (solo si usas profile admin)
PGADMIN_EMAIL=admin@yourdomain.com
PGADMIN_PASSWORD=STRONG_PASSWORD_HERE
PGADMIN_PORT=5050

# Monitoring (solo si usas profile monitoring)
EXPORTER_PORT=9187
```

### Resource Limits

Definidos en `docker-compose.prod.yml`:

```yaml
postgres:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
      reservations:
        memory: 512M

app:
  deploy:
    resources:
      limits:
        cpus: '1'
        memory: 1G
      reservations:
        memory: 256M
```

Ajustar según tu hardware disponible.

---

## 🚀 Deployment

### Deploy Básico

```bash
cd Crypto-Intelligence-Platform-Support

# Iniciar stack
docker-compose -f docker-compose.prod.yml up -d

# Ver estado
docker-compose -f docker-compose.prod.yml ps

# Ver logs
docker-compose -f docker-compose.prod.yml logs -f app
```

### Deploy con Admin UI

```bash
docker-compose -f docker-compose.prod.yml --profile admin up -d

# Acceder a PgAdmin: http://your-server:5050
```

### Deploy con Monitoreo

```bash
docker-compose -f docker-compose.prod.yml --profile monitoring up -d

# Métricas: http://your-server:9187/metrics
```

### Deploy Completo (Todo)

```bash
docker-compose -f docker-compose.prod.yml --profile admin --profile monitoring up -d
```

### Usar Script Automatizado

```bash
cd scripts
./deploy.sh

# O con profile
PROFILE=monitoring ./deploy.sh
```

---

## 🔄 Operaciones

### Gestión de Servicios

```bash
# Detener
docker-compose -f docker-compose.prod.yml down

# Reiniciar
docker-compose -f docker-compose.prod.yml restart

# Reiniciar solo app
docker-compose -f docker-compose.prod.yml restart app

# Ver recursos en uso
docker stats
```

### Ejecutar Pipeline

```bash
# Método 1: Ejecutar en container existente
docker-compose -f docker-compose.prod.yml exec app \
  python run_pipeline.py --project-id arbitrum --days 7

# Método 2: Modificar command en docker-compose.prod.yml
# y hacer restart
```

### Logs

```bash
# Todos los servicios
docker-compose -f docker-compose.prod.yml logs -f

# Solo app
docker-compose -f docker-compose.prod.yml logs -f app

# Solo postgres
docker-compose -f docker-compose.prod.yml logs -f postgres

# Últimas 100 líneas
docker-compose -f docker-compose.prod.yml logs --tail=100 app
```

### Escalar Aplicación

```bash
# Escalar a 3 instancias de app
docker-compose -f docker-compose.prod.yml up -d --scale app=3

# Nota: Para load balancing entre instancias, necesitas nginx/traefik
```

---

## 💾 Backups

### Manual

```bash
# Usando docker-compose
docker-compose -f docker-compose.prod.yml exec postgres \
  pg_dump -U cip_user crypto_intel | gzip > backup_$(date +%Y%m%d).sql.gz

# Usando script
cd scripts
./backup.sh
```

### Automático (Cron)

```bash
# Editar crontab
crontab -e

# Backup diario a las 2 AM
0 2 * * * cd /path/to/Crypto-Intelligence-Platform-Support/scripts && ./backup.sh >> /var/log/cip-backup.log 2>&1
```

### Restore

```bash
# Usando script
cd scripts
./restore.sh ../backups/cip_backup_20260207_120000.sql.gz

# Manual
gunzip -c backup.sql.gz | docker-compose -f docker-compose.prod.yml exec -T postgres \
  psql -U cip_user -d crypto_intel
```

---

## 🔒 Seguridad en Producción

### Checklist

- [ ] **Passwords fuertes** - Mínimo 32 caracteres, aleatorios
- [ ] **.env protegido** - Nunca commitear, permisos 600
- [ ] **Firewall** - Solo puertos necesarios abiertos
- [ ] **SSL/TLS** - En PostgreSQL y conexiones externas
- [ ] **Usuario no-root** - Ya implementado en Dockerfile
- [ ] **Backups automáticos** - Configurar cron
- [ ] **Monitoreo** - Configurar alertas
- [ ] **Updates regulares** - Security patches

### Habilitar SSL en PostgreSQL

1. Generar certificados:
```bash
cd database
openssl req -new -x509 -days 365 -nodes -text \
  -out server.crt -keyout server.key \
  -subj "/CN=cip-postgres"
chmod 600 server.key
```

2. Modificar `postgresql.conf`:
```conf
ssl = on
ssl_cert_file = '/etc/ssl/certs/server.crt'
ssl_key_file = '/etc/ssl/private/server.key'
```

3. Montar certificados en docker-compose.

### Secrets Management

Para producción seria, usar:
- **Docker Secrets** (Swarm)
- **AWS Secrets Manager**
- **HashiCorp Vault**
- **Azure Key Vault**

---

## 📊 Monitoreo

### Health Checks

```bash
# Verificar salud de containers
docker-compose -f docker-compose.prod.yml ps

# Health check manual
docker-compose -f docker-compose.prod.yml exec postgres \
  pg_isready -U cip_user -d crypto_intel
```

### Métricas (con profile monitoring)

```bash
# Endpoint de métricas
curl http://localhost:9187/metrics

# Integrar con Prometheus (prometheus.yml):
scrape_configs:
  - job_name: 'cip-postgres'
    static_configs:
      - targets: ['your-server:9187']
```

### Logs Centralizados

Opcional: integrar con ELK Stack o similar.

```yaml
# Añadir a docker-compose.prod.yml
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

---

## 🔧 Mantenimiento

### Updates

```bash
# 1. Backup
cd scripts
./backup.sh

# 2. Pull cambios de app
cd ../../Crypto-Intelligence-Platform
git pull origin main

# 3. Rebuild
cd ../Crypto-Intelligence-Platform-Support
docker-compose -f docker-compose.prod.yml build

# 4. Deploy nueva versión
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d

# 5. Verificar
docker-compose -f docker-compose.prod.yml logs -f app
```

### Vacuum y Analyze

```bash
# Manual
docker-compose -f docker-compose.prod.yml exec postgres \
  psql -U cip_user -d crypto_intel -c "VACUUM ANALYZE;"

# Automático via cron
0 3 * * 0 docker-compose -f docker-compose.prod.yml exec postgres psql -U cip_user -d crypto_intel -c "VACUUM ANALYZE;"
```

### Limpiar Espacio

```bash
# Logs antiguos de app
find ../Crypto-Intelligence-Platform/logs -name "*.log" -mtime +30 -delete

# Docker cleanup
docker system prune -a --volumes

# Backups antiguos (retención configurable en backup.sh)
find ./backups -name "*.sql.gz" -mtime +30 -delete
```

---

## 🐛 Troubleshooting

### Container no inicia

```bash
# Ver logs
docker-compose -f docker-compose.prod.yml logs postgres
docker-compose -f docker-compose.prod.yml logs app

# Inspect container
docker inspect cip-postgres-prod

# Verificar recursos
docker stats
free -h
df -h
```

### Performance Issues

```bash
# Ver queries lentas
docker-compose -f docker-compose.prod.yml exec postgres \
  psql -U cip_user -d crypto_intel -c "
    SELECT query, calls, mean_exec_time, max_exec_time 
    FROM pg_stat_statements 
    ORDER BY mean_exec_time DESC 
    LIMIT 10;"

# Ver conexiones activas
docker-compose -f docker-compose.prod.yml exec postgres \
  psql -U cip_user -d crypto_intel -c "
    SELECT count(*) FROM pg_stat_activity;"
```

### Out of Memory

Ajustar resource limits en `docker-compose.prod.yml`.

### Network Issues

```bash
# Verificar network
docker network inspect crypto-intelligence-platform-support_cip-network

# Test conectividad
docker-compose -f docker-compose.prod.yml exec app \
  ping -c 3 postgres
```

---

## 🌐 High Availability

### Docker Swarm (Multi-node)

```bash
# Init swarm
docker swarm init

# Deploy como stack
docker stack deploy -c docker-compose.prod.yml cip

# Escalar
docker service scale cip_app=3

# Ver servicios
docker service ls
docker service ps cip_app
```

### Kubernetes

Ver [kubernetes/README.md](../kubernetes/README.md) para manifiestos completos.

---

## 📚 Referencias

- **Desarrollo Local:** [App/docs/DOCKER.md](../../Crypto-Intelligence-Platform/docs/DOCKER.md)
- **Database Setup:** [database/README.md](../database/README.md)
- **Scripts:** [scripts/README.md](../scripts/README.md)
- **Kubernetes:** [kubernetes/README.md](../kubernetes/README.md)

---

## 💡 Best Practices

1. **Backups regulares** - Automatizar con cron
2. **Monitoreo activo** - Configurar alertas
3. **Resource limits** - Evitar OOM
4. **Health checks** - Detection rápida de fallos
5. **Logs rotados** - No llenar disco
6. **Updates programados** - Security patches
7. **Documentar cambios** - Mantener changelog
8. **Disaster recovery plan** - Procedimiento de restore documentado
