#!/bin/bash
source "$(dirname "$0")/lib/common.sh"
echo "🔍 MemoryGuard 自愈检查..."
FAILED=0
log_size=$(stat -c%s "$LOG_FILE" 2>/dev/null || echo 0)
if [[ "$log_size" -gt 5242880 ]]; then
    echo "[WARN] 日志轮转"
    mv "$LOG_FILE" "$LOG_DIR/memoryguard_$(date +%Y%m%d_%H%M%S).log"
    : > "$LOG_FILE"
    log "INFO" "日志轮转完成"
fi
if crontab -l 2>/dev/null | grep -q "MemoryGuard"; then
    echo "[OK] crontab 任务"
else
    echo "[FAIL] crontab 缺失，重新安装"
    bash "$MG_ROOT/install.sh"
    FAILED=1
fi
if sqlite3 "$MG_ROOT/db/memoryguard.db" "PRAGMA integrity_check;" &>/dev/null; then
    echo "[OK] 数据库"
else
    echo "[FAIL] 数据库损坏"
    FAILED=1
fi
[[ $FAILED -eq 0 ]] && echo "✅ 系统健康" || echo "⚠️ 存在异常"
