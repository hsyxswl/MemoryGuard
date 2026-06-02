#!/bin/bash
source "$(dirname "$0")/lib/common.sh"
PORT="${1:-8080}"
if ! (exec 3<>/dev/tcp/0.0.0.0/$PORT) 2>/dev/null; then
    echo "回退到 nc（需手动停止）"
    while true; do echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/html; charset=utf-8\r\n\r\n<pre>MemoryGuard</pre>" | nc -l -p "$PORT" -q 1; done
    exit 0
fi
echo "Web 通知中心已在端口 $PORT 启动"
while true; do
    exec 3<>/dev/tcp/0.0.0.0/$PORT
    read -r line <&3
    if echo "$line" | fgrep -q "GET /confirm?"; then
        med=$(echo "$line" | grep -oP 'med=\K[^& ]+' || true)
        [[ -n "$med" ]] && bash "$MG_ROOT/db/med_query.sh" web-confirm "$med"
        echo -ne "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n确认成功" >&3
    else
        cat >&3 <<-EOT
HTTP/1.1 200 OK
Content-Type: text/html; charset=utf-8

<html><head><meta charset="utf-8"><meta http-equiv="refresh" content="30">
<title>MemoryGuard</title>
<style>body{font-family:sans-serif;margin:20px} .alert{color:red} .ok{color:green}</style>
</head>
<body><h1>🏠 MemoryGuard 通知中心</h1>
<p><b>$(date)</b></p>
<h2>🚨 最近报警</h2><pre>$(tail -5 "$LOG_FILE" | grep -E "ALERT|ERROR|WARN" || echo "暂无")</pre>
<h2>💊 待确认用药</h2><pre>$(sqlite3 "$MG_ROOT/db/memoryguard.db" "SELECT med_name, taken_date FROM med_log WHERE status='pending' ORDER BY taken_date DESC LIMIT 5;" 2>/dev/null || echo "无")</pre>
<p><i>v2.0 优化版</i></p>
</body></html>
EOT
    fi
    exec 3<&-
    sleep 1
done
