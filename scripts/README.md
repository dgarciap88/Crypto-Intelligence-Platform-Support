# Utility Scripts for CIP

Scripts de utilidad para gestión y mantenimiento del Crypto Intelligence Platform.

## 📜 Scripts Disponibles

### 🔄 backup.sh / backup.bat
Backup automático de la base de datos PostgreSQL.

**Linux/Mac:**
```bash
./backup.sh
```

**Windows:**
```batch
backup.bat
```

**Variables de entorno:**
- `BACKUP_DIR` - Directorio de backups (default: ./backups)
- `POSTGRES_CONTAINER` - Nombre del container (default: cip-postgres)
- `POSTGRES_DB` - Nombre de la base de datos (default: crypto_intel)
- `POSTGRES_USER` - Usuario de la base de datos (default: cip_user)
- `RETENTION_DAYS` - Días de retención (default: 7)

**Características:**
- Compresión automática (.gz)
- Limpieza de backups antiguos
- Timestamp en nombre de archivo
- Validación de éxito

---

### 🔙 restore.sh
Restaurar base de datos desde un backup.

**Uso:**
```bash
./restore.sh ./backups/cip_backup_20260207_120000.sql.gz
```

**Características:**
- Confirmación antes de restaurar
- Soporte para archivos .gz
- Verificación post-restore
- Muestra estadísticas de tablas

---

### 🚀 deploy.sh
Script de deployment completo.

**Uso:**
```bash
# Producción
./deploy.sh

# Desarrollo (con PgAdmin)
PROFILE=development ./deploy.sh

# Con monitoreo
PROFILE=monitoring ./deploy.sh
```

**Acciones:**
- Verifica Docker
- Valida configuración
- Build de imágenes
- Deploy de containers
- Health checks

---

## 📅 Automatización

### Cron (Linux/Mac)

**Backup diario a las 2 AM:**
```bash
# Editar crontab
crontab -e

# Añadir línea
0 2 * * * cd /path/to/Crypto-Intelligence-Platform-Support/scripts && ./backup.sh >> /var/log/cip-backup.log 2>&1
```

**Backup cada 6 horas:**
```bash
0 */6 * * * cd /path/to/Crypto-Intelligence-Platform-Support/scripts && ./backup.sh
```

### Task Scheduler (Windows)

1. Abrir **Task Scheduler**
2. **Create Basic Task**
3. **Trigger:** Daily at 2:00 AM
4. **Action:** Start a program
   - Program: `cmd.exe`
   - Arguments: `/c "cd /d C:\path\to\scripts && backup.bat"`

---

## 🔧 Personalización

### Backup a S3/Cloud Storage

Editar `backup.sh`:
```bash
# Después de la línea de backup, añadir:
aws s3 cp "$BACKUP_FILE.gz" s3://mi-bucket/backups/
```

### Notificaciones

Añadir al final de `backup.sh`:
```bash
# Webhook de Slack
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"✅ CIP Backup completado: '"$BACKUP_FILE"'"}' \
  YOUR_SLACK_WEBHOOK_URL

# Email
echo "Backup completado" | mail -s "CIP Backup" admin@example.com
```

---

## 🐛 Troubleshooting

### "Docker is not running"
```bash
# Linux
sudo systemctl start docker

# Windows/Mac
# Iniciar Docker Desktop
```

### "Permission denied"
```bash
# Dar permisos de ejecución
chmod +x backup.sh restore.sh deploy.sh
```

### "Container not found"
```bash
# Verificar nombre del container
docker ps

# Ajustar variable
export POSTGRES_CONTAINER=nombre_correcto
./backup.sh
```

---

## 📚 Ejemplos de Uso

### Backup antes de actualizar
```bash
./backup.sh
cd ../Crypto-Intelligence-Platform
git pull origin main
./scripts/deploy.sh
```

### Restaurar a estado anterior
```bash
# Ver backups disponibles
ls -lh ./backups/

# Restaurar
./restore.sh ./backups/cip_backup_20260207_120000.sql.gz
```

### Deploy completo
```bash
# 1. Backup de seguridad
./backup.sh

# 2. Deploy
./deploy.sh

# 3. Verificar
cd ../../Crypto-Intelligence-Platform
docker-compose ps
docker-compose logs -f
```
