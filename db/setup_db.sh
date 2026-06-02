#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
DB="$MG_ROOT/db/memoryguard.db"
if [[ ! -f "$DB" ]]; then
    sqlite3 "$DB" < "$MG_ROOT/db/init.sql"
    log "INFO" "数据库已创建"
else
    log "INFO" "数据库已存在"
fi
echo "数据库就绪"
