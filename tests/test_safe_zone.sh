#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"

LOG_FILE="$MG_ROOT/logs/memoryguard.log"
echo ">>> 防走失演示模式已启动（按 Ctrl+C 停止）"

timeout 10 bash "$MG_ROOT/safe-zone/bluetooth-scan.sh" --demo &
pid=$!
sleep 6

if grep -q -E "ALERT|WARN" "$LOG_FILE" 2>/dev/null; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC}"
fi

kill $pid 2>/dev/null || true
