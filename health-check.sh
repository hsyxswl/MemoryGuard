#!/bin/bash
source "$(dirname "$0")/lib/common.sh"
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2*100}')
disk_usage=$(df -h / | awk 'NR==2 {print $5}' | tr -d '%')
echo "CPU: ${cpu_usage}% 内存: ${mem_usage}% 磁盘: ${disk_usage}%"
if [ $(echo "$cpu_usage > 80" | bc) -eq 1 ] || [ "$mem_usage" -gt 80 ] || [ "$disk_usage" -gt 80 ]; then
    speak "系统资源告警"
    log "ALERT" "系统资源高: CPU${cpu_usage}% MEM${mem_usage}% DISK${disk_usage}%"
fi
