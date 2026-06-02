#!/bin/bash
source "$(dirname "$0")/lib/common.sh"
echo "===== MemoryGuard 状态摘要 ====="
echo "时间: $(date)"
echo "药品数: $(sqlite3 "$MG_ROOT/db/memoryguard.db" "SELECT count(*) FROM medicines;" 2>/dev/null || echo 0)"
echo "今日提醒: $(sqlite3 "$MG_ROOT/db/memoryguard.db" "SELECT count(*) FROM med_log WHERE taken_date='$(date +%Y-%m-%d)';" 2>/dev/null || echo 0)"
echo "最近警报: $(grep -c 'ALERT' "$LOG_FILE" 2>/dev/null || echo 0) 次"
echo "定时任务: $(crontab -l 2>/dev/null | grep -c MemoryGuard || echo 0) 条"
echo "================================"
