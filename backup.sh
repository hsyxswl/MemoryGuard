#!/bin/bash
source "$(dirname "$0")/lib/common.sh"
BACKUP_DIR="${1:-$MG_ROOT/backups}"
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/memoryguard_backup_$(date +%Y%m%d_%H%M%S).tar.gz" -C "$MG_ROOT" db/memoryguard.db logs memory-aid/memory.txt 2>/dev/null
log "INFO" "备份完成"
find "$BACKUP_DIR" -name "memoryguard_backup_*.tar.gz" -mtime +7 -delete
