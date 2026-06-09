#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/../lib/common.sh"

if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "用法: $0 [--demo] 启动蓝牙扫描（加 --demo 使用模拟模式）"
    exit 0
fi

TARGET_DEVICE_MAC="${TARGET_DEVICE_MAC:-XX:XX:XX:XX:XX:XX}"
RSSI_THRESHOLD="${RSSI_THRESHOLD:--70}"
SCAN_INTERVAL="${SCAN_INTERVAL:-10}"
DEMO_MODE=0

if [[ "${1:-}" == "--demo" ]]; then
    DEMO_MODE=1
    echo ">>> 防走失演示模式已启动（按 Ctrl+C 停止）"
fi

while true; do
    if [[ $DEMO_MODE -eq 1 ]]; then
        rssi=$(( -50 - (RANDOM % 40) ))
        echo -n "[$(date +%H:%M:%S)] 模拟蓝牙 RSSI: ${rssi} dBm "
        if [[ "$rssi" -lt "$RSSI_THRESHOLD" ]]; then
            echo -e "${RED}⚠️ 患者可能远离！${NC}"
            log "WARN" "患者可能远离！RSSI=$rssi"
            bash "$MG_ROOT/safe-zone/alert.sh" "$rssi" "$TARGET_DEVICE_MAC"
        else
            echo -e "${GREEN}信号正常${NC}"
            log "INFO" "信号正常 RSSI=$rssi"
        fi
        sleep 2
    else
        if ! command -v hcitool &>/dev/null; then
            die "hcitool 未安装，无法进行蓝牙扫描"
        fi
        hcitool cc "$TARGET_DEVICE_MAC" 2>/dev/null
        raw=$(hcitool rssi "$TARGET_DEVICE_MAC" 2>/dev/null || true)
        rssi=$(echo "$raw" | grep -oP '(?<=RSSI return value: )-?\d+' || true)
        if [[ -z "$rssi" ]]; then
            echo "未检测到设备 $TARGET_DEVICE_MAC"
            rssi="-100"
        fi
        if [[ "$rssi" -lt "$RSSI_THRESHOLD" ]]; then
            echo -e "${RED}患者可能远离！RSSI=${rssi}${NC}"
            bash "$MG_ROOT/safe-zone/alert.sh" "$rssi" "$TARGET_DEVICE_MAC"
        else
            echo "信号正常 RSSI=${rssi}"
        fi
        sleep "$SCAN_INTERVAL"
    fi
done


