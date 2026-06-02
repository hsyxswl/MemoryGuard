#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
DB="$MG_ROOT/db/memoryguard.db"
med_name="$1" remind_time="$2"
today=$(date +%Y-%m-%d)
TIMEOUT=1800
if [ -t 0 ]; then
    echo -e "${YELLOW}按 y 确认已服用 $med_name，超时或按 n 将告警。${NC}"
    read -t $TIMEOUT -p "已服用(y/n)? " ans || ans="timeout"
    case "$ans" in
        [Yy]*)
            sqlite3 "$DB" "UPDATE med_log SET status='taken', confirmed_at=datetime('now') WHERE med_name='$med_name' AND taken_date='$today' AND status='pending';"
            log "INFO" "终端确认: $med_name"
            echo -e "${GREEN}好的，已记录${NC}"
            speak "好的，已记录" ;;
        *)
            log "WARN" "$med_name 未确认"
            throttle_alert "missed_$med_name" "$med_name 可能未服用，请检查"
            [[ -n "${ALERT_EMAIL:-}" ]] && send_mail_alert "用药告警" "$med_name 未确认" ;;
    esac
else
    log "WARN" "非交互环境，$med_name 待 Web 确认"
    speak "提醒，请确认 ${med_name} 是否已服用"
    notify_desktop "用药提醒" "请通过 Web 页面确认 $med_name"
fi
