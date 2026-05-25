#!/bin/bash
set -e

# Script de restauración con Restic
# Uso: ./restic-restore.sh [snapshot-id] [restore-path]

SNAPSHOT_ID=${1:-latest}
RESTORE_PATH=${2:-/mnt/restore}

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*"
}

if [ -z "${RESTIC_PASSWORD}" ] || [ -z "${RESTIC_REPOSITORY}" ]; then
    log "ERROR: RESTIC_PASSWORD y RESTIC_REPOSITORY deben estar definidas"
    exit 1
fi

log "========================================="
log "Iniciando restauración desde backup"
log "========================================="
log "Snapshot ID: ${SNAPSHOT_ID}"
log "Ruta de restauración: ${RESTORE_PATH}"

# Crear directorio de restauración
mkdir -p "${RESTORE_PATH}"

# Listar snapshots disponibles
if [ "${SNAPSHOT_ID}" = "list" ]; then
    log "Snapshots disponibles:"
    restic snapshots
    exit 0
fi

# Restaurar snapshot
log "Restaurando snapshot ${SNAPSHOT_ID}..."
restic restore "${SNAPSHOT_ID}" --target "${RESTORE_PATH}" --verbose

log "========================================="
log "Restauración completada"
log "Archivos restaurados en: ${RESTORE_PATH}"
log "========================================="
