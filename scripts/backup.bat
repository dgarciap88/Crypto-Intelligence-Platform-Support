@echo off
REM Backup script for CIP PostgreSQL database (Windows)

setlocal enabledelayedexpansion

REM Configuration
set BACKUP_DIR=%~dp0..\backups
set TIMESTAMP=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set TIMESTAMP=%TIMESTAMP: =0%
set POSTGRES_CONTAINER=cip-postgres
set DB_NAME=crypto_intel
set DB_USER=cip_user
set RETENTION_DAYS=7

echo [32m Starting CIP database backup...[0m

REM Create backup directory
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

REM Backup filename
set BACKUP_FILE=%BACKUP_DIR%\cip_backup_%TIMESTAMP%.sql

REM Perform backup
echo [33m Creating backup: %BACKUP_FILE%[0m
docker exec %POSTGRES_CONTAINER% pg_dump -U %DB_USER% %DB_NAME% > "%BACKUP_FILE%"

REM Check if backup was successful
if %ERRORLEVEL% NEQ 0 (
    echo [31m Backup failed![0m
    exit /b 1
)

echo [32m Backup completed: %BACKUP_FILE%[0m

REM List recent backups
echo [33m Recent backups:[0m
dir /B /O-D "%BACKUP_DIR%\cip_backup_*.sql" 2>nul | findstr /N "^" | findstr /B "1: 2: 3: 4: 5:"

echo [32m Backup process completed successfully[0m
