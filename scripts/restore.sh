#!/bin/bash
# Restore script for CIP PostgreSQL database

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
POSTGRES_CONTAINER="${POSTGRES_CONTAINER:-cip-postgres}"
DB_NAME="${POSTGRES_DB:-crypto_intel}"
DB_USER="${POSTGRES_USER:-cip_user}"

# Check if backup file is provided
if [ -z "$1" ]; then
    echo -e "${RED}❌ Error: No backup file specified${NC}"
    echo "Usage: $0 <backup_file.sql.gz>"
    echo ""
    echo "Available backups:"
    ls -lh ./backups/cip_backup_*.sql.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

# Check if file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}❌ Error: Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${YELLOW}⚠️  WARNING: This will replace all data in the database!${NC}"
echo -e "Database: ${DB_NAME}"
echo -e "Backup file: ${BACKUP_FILE}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
echo

if [[ ! $REPLY =~ ^[Yy]es$ ]]; then
    echo -e "${YELLOW}❌ Restore cancelled${NC}"
    exit 0
fi

echo -e "${GREEN}🔄 Starting database restore...${NC}"

# Check if file is gzipped
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo -e "${YELLOW}📦 Decompressing backup...${NC}"
    gunzip -c "$BACKUP_FILE" | docker exec -i "$POSTGRES_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME"
else
    echo -e "${YELLOW}📦 Restoring backup...${NC}"
    cat "$BACKUP_FILE" | docker exec -i "$POSTGRES_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME"
fi

echo -e "${GREEN}✅ Database restored successfully${NC}"

# Verify
echo -e "${YELLOW}🔍 Verifying restore...${NC}"
docker exec "$POSTGRES_CONTAINER" psql -U "$DB_USER" -d "$DB_NAME" -c "
    SELECT 
        'projects' as table_name, COUNT(*) as count FROM projects
    UNION ALL
    SELECT 'sources', COUNT(*) FROM sources
    UNION ALL
    SELECT 'raw_events', COUNT(*) FROM raw_events
    UNION ALL
    SELECT 'normalized_events', COUNT(*) FROM normalized_events
    UNION ALL
    SELECT 'ai_insights', COUNT(*) FROM ai_insights;
"

echo -e "${GREEN}✅ Restore completed successfully${NC}"
