#!/bin/bash
set -e

# Script de backup con Restic
# Uso: ./restic-backup.sh [full|db|files]

BACKUP_TYPE=${1:-full}
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
LOG_FILE="/var/log/restic-backup.log"

log() {
    echo "[${TIMESTAMP}] $*" | tee -a "${LOG_FILE}"
}

log "========================================="
log "Iniciando backup de tipo: ${BACKUP_TYPE}"
log "========================================="

# Inicializar repositorio si no existe
if [ ! -d "${RESTIC_REPOSITORY}" ]; then
    log "Inicializando repositorio Restic en ${RESTIC_REPOSITORY}"
    restic init
fi

# Backup de archivos/volúmenes
backup_files() {
    log "Iniciando backup de volúmenes..."

    # Backup de volúmenes Docker
    restic backup \
        --verbose \
        --exclude='*.log' \
        --exclude='*.tmp' \
        --exclude='*.cache' \
        --exclude='node_modules' \
        --exclude='.git' \
        ${BACKUP_EXCLUDE} \
        /volumes

    log "Backup de volúmenes completado"
}

# Backup de PostgreSQL
backup_postgres() {
    if [ "${BACKUP_POSTGRES}" != "true" ]; then
        log "Backup de PostgreSQL deshabilitado"
        return
    fi

    log "Iniciando backup de PostgreSQL..."

    # Crear directorio temporal
    PGBACKUP_DIR="/tmp/pg-backup-$(date +%s)"
    mkdir -p "${PGBACKUP_DIR}"

    # Usar docker exec para ejecutar pg_dumpall
    docker exec postgres pg_dumpall \
        -U "${POSTGRES_USER}" \
        > "${PGBACKUP_DIR}/all-databases.sql" 2>/dev/null || {
        log "ERROR: No se pudo hacer backup de PostgreSQL"
        rm -rf "${PGBACKUP_DIR}"
        return 1
    }

    # Hacer backup con restic
    restic backup "${PGBACKUP_DIR}"

    # Limpiar
    rm -rf "${PGBACKUP_DIR}"
    log "Backup de PostgreSQL completado"
}

# Backup de MongoDB
backup_mongodb() {
    if [ "${BACKUP_MONGODB}" != "true" ]; then
        log "Backup de MongoDB deshabilitado"
        return
    fi

    log "Iniciando backup de MongoDB..."

    # Crear directorio temporal
    MONGOBACKUP_DIR="/tmp/mongo-backup-$(date +%s)"
    mkdir -p "${MONGOBACKUP_DIR}"

    # Hacer backup con mongodump
    docker exec mongodb mongodump \
        --username="${MONGODB_USER}" \
        --password="${MONGODB_PASSWORD}" \
        --authenticationDatabase=admin \
        --out="${MONGOBACKUP_DIR}" 2>/dev/null || {
        log "ERROR: No se pudo hacer backup de MongoDB"
        rm -rf "${MONGOBACKUP_DIR}"
        return 1
    }

    # Hacer backup con restic
    restic backup "${MONGOBACKUP_DIR}"

    # Limpiar
    rm -rf "${MONGOBACKUP_DIR}"
    log "Backup de MongoDB completado"
}

# Backup de bases de datos
backup_databases() {
    log "Iniciando backups de bases de datos..."
    backup_postgres
    backup_mongodb
    log "Backups de bases de datos completados"
}

# Ejecutar según tipo
case ${BACKUP_TYPE} in
    full)
        backup_files
        backup_databases
        ;;
    db)
        backup_databases
        ;;
    files)
        backup_files
        ;;
    *)
        log "ERROR: Tipo de backup inválido: ${BACKUP_TYPE}"
        log "Usos válidos: full | db | files"
        exit 1
        ;;
esac

# Limpiar snapshots antiguos según retención
log "Aplicando política de retención..."
restic forget \
    --keep-daily="${RETENTION_DAILY}" \
    --keep-weekly="${RETENTION_WEEKLY}" \
    --keep-monthly="${RETENTION_MONTHLY}" \
    --prune

log "========================================="
log "Backup completado exitosamente"
log "========================================="
