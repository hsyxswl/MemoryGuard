#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
DB="$MG_ROOT/db/memoryguard.db"
REPORT="$MG_ROOT/logs/weekly_report_$(date +%Y%m%d).txt"
today=$(date +%Y-%m-%d)
dow=$(date +%u)
start_date=$(date -d "$today - $(( (dow-1) + 7 )) days" +%Y-%m-%d)
end_date=$(date -d "$start_date + 6 days" +%Y-%m-%d)
{
    echo "========================================"
    echo " MemoryGuard 用药依从性周报"
    echo " 周期: $start_date 至 $end_date"
    echo "========================================"
    echo ""
    total=$(sqlite3 "$DB" "SELECT COUNT(*) FROM med_log WHERE taken_date BETWEEN '$start_date' AND '$end_date';")
    confirmed=$(sqlite3 "$DB" "SELECT COUNT(*) FROM med_log WHERE taken_date BETWEEN '$start_date' AND '$end_date' AND status='taken';")
    missed=$(( total - confirmed ))
    echo "本周提醒总次数: $total"
    echo "已确认: $confirmed"
    echo "未确认: $missed"
    if [[ "$missed" -gt 0 ]]; then
        echo ""
        echo "以下药品未确认:"
        sqlite3 -column -header "$DB" "SELECT med_name, taken_date FROM med_log WHERE taken_date BETWEEN '$start_date' AND '$end_date' AND status!='taken';"
    fi
    echo ""
    echo "详细记录见数据库 $DB"
} > "$REPORT"
cat "$REPORT"
log "INFO" "周报已生成: $REPORT"
