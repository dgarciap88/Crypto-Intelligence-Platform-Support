#!/bin/bash
# Backup script for CIP PostgreSQL database

set -e

# Configuration
BACKUP_DIR="${BACKUP_DIR:-./backups}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
POSTGRES_CONTAINER="${POSTGRES_CONTAINER:-cip-postgres}"
DB_NAME="${POSTGRES_DB:-crypto_intel}"
DB_USER="${POSTGRES_USER:-cip_user}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔄 Starting CIP database backup...${NC}"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup filename
BACKUP_FILE="$BACKUP_DIR/cip_backup_${TIMESTAMP}.sql"

# Perform backup
echo -e "${YELLOW}📦 Creating backup: $BACKUP_FILE${NC}"
docker exec "$POSTGRES_CONTAINER" pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"

# Compress backup
echo -e "${YELLOW}🗜️  Compressing backup...${NC}"
gzip "$BACKUP_FILE"
BACKUP_FILE="${BACKUP_FILE}.gz"

# Check backup size
BACKUP_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
echo -e "${GREEN}✅ Backup completed: $BACKUP_FILE ($BACKUP_SIZE)${NC}"

# Cleanup old backups
echo -e "${YELLOW}🧹 Cleaning up old backups (older than ${RETENTION_DAYS} days)...${NC}"
find "$BACKUP_DIR" -name "cip_backup_*.sql.gz" -type f -mtime +${RETENTION_DAYS} -delete

# List remaining backups
BACKUP_COUNT=$(ls -1 "$BACKUP_DIR"/cip_backup_*.sql.gz 2>/dev/null | wc -l)
echo -e "${GREEN}📊 Total backups: $BACKUP_COUNT${NC}"
ls -lh "$BACKUP_DIR"/cip_backup_*.sql.gz 2>/dev/null | tail -5

echo -e "${GREEN}✅ Backup process completed successfully${NC}"
