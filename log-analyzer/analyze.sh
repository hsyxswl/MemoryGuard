#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
LOG="$MG_ROOT/logs/memoryguard.log"
DB="$MG_ROOT/db/memoryguard.db"
DAYS="${1:-7}"
echo "========== MemoryGuard 日志分析（最近 $DAYS 天）=========="
echo ""
echo "【防走失警报统计】"
alerts=$(grep -c "ALERT" "$LOG" 2>/dev/null || echo 0)
echo "总警报次数: $alerts"
echo "【用药依从性】"
total=$(sqlite3 "$DB" "SELECT COUNT(*) FROM med_log WHERE taken_date >= date('now','-$DAYS days');")
taken=$(sqlite3 "$DB" "SELECT COUNT(*) FROM med_log WHERE taken_date >= date('now','-$DAYS days') AND status='taken';")
echo "总提醒: $total, 已确认: $taken"
if [[ "$total" -gt 0 ]]; then
    echo "依从率: $(echo "scale=1; $taken*100/$total" | bc 2>/dev/null)%"
else
    echo "暂无数据"
fi
echo "=============================================="
