# PostgreSQL Database Stack for CIP

Stack de base de datos PostgreSQL optimizado para el Crypto Intelligence Platform.

## 🚀 Quick Start

```bash
# 1. Configurar variables de entorno
cp .env.example .env
# Editar .env con tus valores

# 2. Levantar solo PostgreSQL
docker-compose up -d

# 3. Levantar con PgAdmin
docker-compose --profile admin up -d

# 4. Levantar con monitoreo
docker-compose --profile monitoring up -d

# 5. Levantar todo
docker-compose --profile admin --profile monitoring up -d
```

## 📦 Componentes

### PostgreSQL 14
- **Puerto:** 5432 (configurable)
- **Base de datos:** crypto_intel
- **Optimizaciones:** JSONB queries, alta concurrencia
- **Extensiones:** uuid-ossp, pg_stat_statements, pg_trgm

### PgAdmin 4 (opcional)
- **Puerto:** 5050 (configurable)
- **Profile:** `admin`
- **Uso:** Gestión visual de la base de datos

### PostgreSQL Exporter (opcional)
- **Puerto:** 9187 (configurable)
- **Profile:** `monitoring`
- **Uso:** Métricas para Prometheus

## 🔧 Configuración

### Variables de Entorno

Archivo `.env`:
```bash
POSTGRES_DB=crypto_intel
POSTGRES_USER=cip_user
POSTGRES_PASSWORD=your_secure_password
POSTGRES_PORT=5432
```

### Optimizaciones PostgreSQL

El archivo `postgresql.conf` incluye:
- Buffers optimizados para JSONB
- WAL configurado para escritura intensiva
- Autovacuum ajustado
- Logging detallado
- Statistics tracking

## 📊 Acceso

### psql CLI
```bash
# Desde el host
psql -h localhost -p 5432 -U cip_user -d crypto_intel

# Desde el container
docker-compose exec postgres psql -U cip_user -d crypto_intel
```

### PgAdmin Web UI
1. Acceder a http://localhost:5050
2. Login con credenciales de `.env`
3. Añadir servidor:
   - **Name:** CIP Production
   - **Host:** postgres
   - **Port:** 5432
   - **Username:** cip_user
   - **Password:** tu password

## 💾 Backups

### Manual
```bash
# Backup
docker-compose exec postgres pg_dump -U cip_user crypto_intel > backup_$(date +%Y%m%d).sql

# Restore
cat backup_20260207.sql | docker-compose exec -T postgres psql -U cip_user -d crypto_intel
```

### Automático
Ver `../scripts/backup.sh` para backups automáticos programados.

## 🔍 Monitoreo

### Logs
```bash
# Ver logs en tiempo real
docker-compose logs -f postgres

# Logs dentro del container
docker-compose exec postgres tail -f /var/log/postgresql/postgresql-*.log
```

### Métricas
Con el profile `monitoring`:
```bash
# Endpoint de métricas
curl http://localhost:9187/metrics

# Integrar con Prometheus
# Añadir a prometheus.yml:
scrape_configs:
  - job_name: 'cip-postgres'
    static_configs:
      - targets: ['localhost:9187']
```

## 🛠️ Mantenimiento

### Vacuum y Analyze
```bash
# Manual
docker-compose exec postgres psql -U cip_user -d crypto_intel -c "VACUUM ANALYZE;"

# Usando función de mantenimiento
docker-compose exec postgres psql -U cip_user -d crypto_intel -c "SELECT maintain_database();"
```

### Verificar salud
```bash
# Health check
docker-compose exec postgres pg_isready -U cip_user -d crypto_intel

# Estadísticas de queries
docker-compose exec postgres psql -U cip_user -d crypto_intel -c "SELECT * FROM pg_stat_statements ORDER BY total_exec_time DESC LIMIT 10;"
```

### Resetear base de datos
```bash
# ⚠️ ESTO ELIMINA TODOS LOS DATOS
docker-compose down -v
docker-compose up -d
```

## 🔒 Seguridad (Producción)

1. **Cambiar contraseñas:**
   - Usa contraseñas fuertes en `.env`
   - No commitear el archivo `.env`

2. **SSL/TLS:**
   ```bash
   # Generar certificados
   openssl req -new -x509 -days 365 -nodes -text -out server.crt -keyout server.key
   chmod 600 server.key
   ```
   
   Añadir a `postgresql.conf`:
   ```
   ssl = on
   ssl_cert_file = '/etc/ssl/certs/server.crt'
   ssl_key_file = '/etc/ssl/private/server.key'
   ```

3. **Firewall:**
   - Limitar acceso al puerto 5432
   - Usar network policies en producción

4. **Usuario limitado:**
   - Usar `cip_app` para la aplicación
   - Reservar `cip_user` para admin

## 📈 Escalado

### Ajustar recursos
Editar `postgresql.conf`:
```conf
shared_buffers = 512MB      # 25% de RAM disponible
effective_cache_size = 2GB  # 50-75% de RAM disponible
work_mem = 32MB             # RAM / max_connections / 4
```

### Replicación
Para configurar replicación master-slave, ver `/kubernetes/postgres/statefulset.yaml`

## 🐛 Troubleshooting

### Container no inicia
```bash
# Ver logs
docker-compose logs postgres

# Verificar permisos del volumen
docker volume inspect database_postgres_data
```

### Conexión rechazada
```bash
# Verificar que está corriendo
docker ps | grep postgres

# Health check
docker-compose exec postgres pg_isready
```

### Performance lento
```bash
# Ver queries lentas
docker-compose exec postgres psql -U cip_user -d crypto_intel -c "
SELECT query, calls, mean_exec_time, max_exec_time 
FROM pg_stat_statements 
ORDER BY mean_exec_time DESC 
LIMIT 10;"
```

## 📚 Referencias

- [PostgreSQL 14 Documentation](https://www.postgresql.org/docs/14/)
- [PostgreSQL Performance Tuning](https://wiki.postgresql.org/wiki/Performance_Optimization)
- [Docker PostgreSQL](https://hub.docker.com/_/postgres)
