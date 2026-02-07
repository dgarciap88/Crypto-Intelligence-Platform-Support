# PostgreSQL Dockerfile for CIP
# Optimized for JSONB queries and high concurrency

FROM postgres:14-alpine

# Install additional tools
RUN apk add --no-cache \
    postgresql-contrib \
    curl

# Copy custom PostgreSQL configuration
COPY postgresql.conf /etc/postgresql/postgresql.conf

# Copy initialization scripts
COPY init/*.sql /docker-entrypoint-initdb.d/

# Set custom config
ENV POSTGRES_CONFIG_FILE=/etc/postgresql/postgresql.conf

# Health check
HEALTHCHECK --interval=10s --timeout=5s --start-period=10s --retries=3 \
    CMD pg_isready -U ${POSTGRES_USER:-postgres} -d ${POSTGRES_DB:-postgres} || exit 1

# Expose PostgreSQL port
EXPOSE 5432

# Use default entrypoint and cmd from base image
