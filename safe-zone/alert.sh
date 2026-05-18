#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
rssi="$1" mac="$2"
msg="请注意，患者可能走远。信号强度 ${rssi} dBm。"
throttle_alert "lost_$mac" "$msg"
log "ALERT" "防走失触发: RSSI=$rssi, MAC=$mac"
