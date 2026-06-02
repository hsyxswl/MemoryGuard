#!/bin/bash
source "$(dirname "$0")/lib/common.sh"
echo ">>> MemoryGuard 全功能演示 <<<"
echo ""
echo "1. 清晨简报..."
./memory-aid/morning-brief.sh
sleep 1
echo ""
echo "2. 防走失演示（10秒）..."
timeout 10 ./safe-zone/bluetooth-scan.sh --demo 2>/dev/null || true
echo ""
echo "3. 用药提醒测试..."
./db/med_query.sh add 多奈哌齐 $(date +%H:%M) "1片" "饭后"
./med-reminder/reminder.sh
sleep 2
./db/med_query.sh delete 多奈哌齐
echo ""
echo "4. 记忆问答..."
./memory-aid/ask.sh 存折在哪
echo ""
echo "5. 日志分析..."
./log-analyzer/analyze.sh
echo ""
echo "6. 系统自检..."
./recovery.sh
echo ""
echo ">>> 演示完成 <<<"
