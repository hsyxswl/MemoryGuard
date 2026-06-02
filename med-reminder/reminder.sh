#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
DB="$MG_ROOT/db/memoryguard.db"
CONFIRM_SCRIPT="$MG_ROOT/med-reminder/confirm.sh"
current_time=$(date +%H:%M)
sqlite3 "$DB" "SELECT id, name, dosage, note FROM medicines WHERE take_time='$current_time';" | while IFS='|' read -r med_id med_name dosage note; do
    today=$(date +%Y-%m-%d)
    already=$(sqlite3 "$DB" "SELECT COUNT(*) FROM med_log WHERE med_name='$med_name' AND taken_date='$today' AND status='taken';")
    if [[ "$already" -gt 0 ]]; then
        log "INFO" "$med_name 今日已确认，跳过"
        continue
    fi
    msg="该吃${med_name}了，${dosage}"
    [[ -n "$note" ]] && msg="$msg，请注意：$note"
    log "INFO" "提醒: $med_name at $current_time"
    speak "$msg"
    notify_desktop "用药提醒" "$msg"
    sqlite3 "$DB" "INSERT OR IGNORE INTO med_log (med_name, taken_date, status) VALUES ('$med_name','$today','pending');"
    bash "$CONFIRM_SCRIPT" "$med_name" "$current_time" &
done
