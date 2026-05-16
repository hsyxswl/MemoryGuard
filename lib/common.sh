#!/bin/bash
export MG_ROOT
MG_ROOT="$(cd "$(dirname "$(dirname "${BASH_SOURCE[0]}")")" && pwd)"
LOG_DIR="$MG_ROOT/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/memoryguard.log"
ESPEAK_CMD="espeak"
NOTIFY_CMD="notify-send"
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLINK='\033[5;31m'
NC='\033[0m'

[ -f "$MG_ROOT/config.sh" ] && source "$MG_ROOT/config.sh"

log() {
    local level="$1" message="$2" timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
    [[ "$level" == "ERROR" ]] && echo -e "${RED}[ERROR]${NC} $message" >&2
}

die() { log "ERROR" "$1"; echo -e "${RED}[FATAL] $1${NC}" >&2; exit 1; }

speak() {
    local text="$1"
    local lock="/tmp/memoryguard_speak.lock"
    exec 200>"$lock"
    if ! flock -w 10 200; then
        [ -t 1 ] && echo -e "${YELLOW}[语音] $text${NC}" || echo "[语音] $text"
        return 1
    fi
    if command -v pico2wave &>/dev/null; then
        local wav="/tmp/spk_$$.wav"
        for l in zh-CN zh cmn; do pico2wave -l "$l" -w "$wav" "$text" 2>/dev/null && break; done
        local played=0
        if command -v aplay &>/dev/null; then aplay "$wav" 2>/dev/null && played=1
        elif command -v paplay &>/dev/null; then paplay "$wav" 2>/dev/null && played=1; fi
        rm -f "$wav"
        if [ $played -eq 1 ]; then flock -u 200; return 0; fi
    fi
    if command -v espeak &>/dev/null; then
        echo "$text" | sed 's/[，。！？、]/&\n/g' | while IFS= read -r line; do
            [ -z "$line" ] && continue
            espeak -v zh -s 120 -a 200 -p 50 -g 8 "$line" 2>/dev/null
            sleep 0.3
        done
        flock -u 200; return 0
    fi
    if command -v espeak-ng &>/dev/null; then
        echo "$text" | sed 's/[，。！？、]/&\n/g' | while IFS= read -r line; do
            [ -z "$line" ] && continue
            espeak-ng -v zh -s 120 -a 200 -p 50 -g 8 "$line" 2>/dev/null
            sleep 0.3
        done
        flock -u 200; return 0
    fi
    [ -t 1 ] && echo -e "${YELLOW}[语音] $text${NC}" || echo "[语音] $text"
    flock -u 200
}

notify_desktop() {
    local title="$1" content="$2"
    if command -v "$NOTIFY_CMD" &>/dev/null; then
        $NOTIFY_CMD "$title" "$content" 2>/dev/null
    else
        log "INFO" "桌面通知跳过: $title"
    fi
}

send_mail_alert() {
    local subject="$1" body="$2"
    if command -v mail &>/dev/null || command -v mailx &>/dev/null; then
        echo "$body" | mail -s "$subject" "${ALERT_EMAIL:-root}" 2>/dev/null || \
        echo "$body" | mailx -s "$subject" "${ALERT_EMAIL:-root}" 2>/dev/null
        log "INFO" "已发送告警邮件至 ${ALERT_EMAIL:-root}"
    else
        log "WARN" "邮件工具未安装，告警邮件跳过"
    fi
}

flash_alert() {
    local msg="$1"
    if [ -t 1 ]; then
        echo -e "${BLINK}⚠️ ${msg}${NC}"
    else
        echo -e "${RED}[警报] ${msg}${NC}"
    fi
}

throttle_alert() {
    local key="$1" msg="$2"
    local throttle_file="/tmp/memoryguard_throttle_${key}"
    local current_time=$(date +%s) last_time=0
    [ -f "$throttle_file" ] && last_time=$(cat "$throttle_file")
    if (( current_time - last_time > 300 )); then
        echo "$current_time" > "$throttle_file"
        flash_alert "$msg"
        speak "$msg"
        notify_desktop "MemoryGuard" "$msg"
        return 0
    else
        log "INFO" "告警抑制: $key"
        return 1
    fi
}
