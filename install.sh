#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/lib/common.sh"
echo "MemoryGuard 安装向导"
mkdir -p "$MG_ROOT/logs"
find "$MG_ROOT" -name "*.sh" -exec chmod +x {} \;
bash "$MG_ROOT/db/setup_db.sh"
if [ ! -f "$MG_ROOT/config.sh" ]; then
    cat > "$MG_ROOT/config.sh" <<-EOF
export ALERT_EMAIL=''
export TARGET_DEVICE_MAC='XX:XX:XX:XX:XX:XX'
export RSSI_THRESHOLD='-70'
EOF
fi
echo ">>> 检查依赖..."
missing=()
for cmd in sqlite3 espeak hcitool notify-send mail curl nc python3; do
    command -v "$cmd" &>/dev/null || missing+=("$cmd")
done
[ ${#missing[@]} -gt 0 ] && echo "缺少命令: ${missing[*]}" || echo "所有依赖就绪"
CRON_ENTRIES="
* * * * * $MG_ROOT/med-reminder/reminder.sh > /dev/null 2>&1
*/5 * * * * $MG_ROOT/safe-zone/bluetooth-scan.sh --demo > /dev/null 2>&1
0 8 * * * $MG_ROOT/memory-aid/morning-brief.sh > /dev/null 2>&1
0 20 * * * $MG_ROOT/recovery.sh > /dev/null 2>&1
*/30 * * * * $MG_ROOT/health-check.sh > /dev/null 2>&1
0 3 * * * $MG_ROOT/backup.sh $HOME/MemoryGuard/backups > /dev/null 2>&1
0 7 * * 1 $MG_ROOT/advanced-report.sh > /dev/null 2>&1
0 6 * * 1 $MG_ROOT/sys-info.sh > /dev/null 2>&1
"
(crontab -l 2>/dev/null; echo "$CRON_ENTRIES") | sort -u | crontab -
echo ">>> crontab 已添加"
echo "安装完毕！"
