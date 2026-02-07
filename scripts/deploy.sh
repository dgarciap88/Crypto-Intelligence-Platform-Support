#!/bin/bash
# Deployment script for CIP

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_DIR="${PROJECT_DIR:-../Crypto-Intelligence-Platform}"
PROFILE="${PROFILE:-production}"

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Crypto Intelligence Platform Deployment  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if docker is running
if ! docker info > /dev/null 2>&1; then
    echo -e "${RED}❌ Docker is not running${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Docker is running${NC}"

# Check if .env exists
if [ ! -f "$PROJECT_DIR/.env" ]; then
    echo -e "${YELLOW}⚠️  .env file not found. Creating from example...${NC}"
    cp "$PROJECT_DIR/.env.example" "$PROJECT_DIR/.env"
    echo -e "${RED}❌ Please configure .env file before deploying${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Environment file found${NC}"

# Check if project.yaml exists
if [ ! -f "$PROJECT_DIR/project.yaml" ]; then
    echo -e "${RED}❌ project.yaml not found${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Project configuration found${NC}"
echo ""

# Deploy
echo -e "${BLUE}🚀 Starting deployment...${NC}"
echo ""

cd "$PROJECT_DIR"

# Pull latest changes (if git repo)
if [ -d ".git" ]; then
    echo -e "${YELLOW}📥 Pulling latest changes...${NC}"
    git pull origin main || git pull origin master || echo "No remote updates"
fi

# Build images
echo -e "${YELLOW}🔨 Building Docker images...${NC}"
docker-compose build

# Stop existing containers
echo -e "${YELLOW}🛑 Stopping existing containers...${NC}"
docker-compose down

# Start containers
echo -e "${YELLOW}🚀 Starting containers...${NC}"
if [ "$PROFILE" == "development" ]; then
    docker-compose --profile admin up -d
elif [ "$PROFILE" == "monitoring" ]; then
    docker-compose --profile admin --profile monitoring up -d
else
    docker-compose up -d
fi

# Wait for database to be ready
echo -e "${YELLOW}⏳ Waiting for database...${NC}"
sleep 5

# Check health
echo -e "${YELLOW}🏥 Checking service health...${NC}"
docker-compose ps

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Deployment completed successfully!   ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Access points:${NC}"
echo -e "  - PostgreSQL: localhost:5432"
if [ "$PROFILE" != "production" ]; then
    echo -e "  - PgAdmin: http://localhost:5050"
fi
if [ "$PROFILE" == "monitoring" ]; then
    echo -e "  - Metrics: http://localhost:9187/metrics"
fi
echo ""
echo -e "${BLUE}📝 Useful commands:${NC}"
echo -e "  - View logs: docker-compose logs -f"
echo -e "  - Stop: docker-compose down"
echo -e "  - Restart: docker-compose restart"
echo ""
