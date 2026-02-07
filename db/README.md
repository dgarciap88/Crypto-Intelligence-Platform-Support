# Database Schema

This directory contains the shared database schema used by all Crypto Intelligence Platform services (Platform, API, Web).

## Files

- **create_tables.sql**: PostgreSQL schema with all tables, indexes, and constraints

## Schema Overview

### Tables

1. **projects**: Crypto projects being tracked
   - `id` (UUID): Primary key
   - `project_id` (TEXT): Unique identifier (e.g., "arbitrum")
   - `name`, `category`, `token_symbol`
   - Indexed on `project_id`

2. **sources**: Data sources for each project
   - Links to projects via `project_id` FK
   - Stores GitHub repos, Twitter accounts, etc.

3. **raw_events**: Raw data from external sources
   - Links to projects and sources
   - Stores original JSON payloads

4. **normalized_events**: Standardized event data
   - Links to projects and raw_events
   - Uniform schema for all event types (commits, releases, tweets)
   - Indexed on `project_id`, `event_timestamp`, `entity_type`

5. **ai_insights**: AI-generated analysis and summaries
   - Links to projects
   - Multi-language support via `content_translations` JSONB
   - Supports Spanish and English content
   - Indexed on `project_id`, `created_at`

## Usage

### Initialize Database

From the Support project root:

```bash
# Using docker-compose (automatic)
docker-compose -f docker-compose.dev.yml up -d postgres

# Manual initialization
Get-Content db/create_tables.sql | docker exec -i cip-postgres psql -U crypto_user -d crypto_intel
```

### Schema Migrations

When modifying the schema:

1. Update `create_tables.sql` with changes
2. Document breaking changes in this README
3. Run migration script or recreate database
4. Update API models if needed
5. Update frontend types if needed

### Multi-Language Insights

The `ai_insights` table supports multi-language content:

```json
{
  "content": "Default content (Spanish)",
  "content_translations": {
    "es": "Contenido en español",
    "en": "Content in English"
  }
}
```

## Affected Services

Changes to this schema affect:
- **Platform**: Data ingestion and normalization
- **API**: Query models and endpoints
- **Web**: Frontend TypeScript types
