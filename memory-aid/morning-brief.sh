#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
current_date=$(date '+%Y年%m月%d日')
weekday=$(date '+%A')
case "$weekday" in
    Monday) week_cn="星期一" ;;
    Tuesday) week_cn="星期二" ;;
    Wednesday) week_cn="星期三" ;;
    Thursday) week_cn="星期四" ;;
    Friday) week_cn="星期五" ;;
    Saturday) week_cn="星期六" ;;
    Sunday) week_cn="星期日" ;;
    *) week_cn="$weekday" ;;
esac
weather_text=""
if command -v python3 &>/dev/null && command -v curl &>/dev/null; then
    weather_text=$(python3 << 'PYEOF'
import json, urllib.request, sys
trans = {"sunny":"晴","clear":"晴","partly cloudy":"多云","mostly cloudy":"多云","cloudy":"阴","overcast":"阴","rain":"雨","light rain":"小雨","moderate rain":"中雨","heavy rain":"大雨","snow":"雪","light snow":"小雪","moderate snow":"中雪","heavy snow":"大雪","mist":"雾","fog":"雾","haze":"霾","thunderstorm":"雷阵雨","drizzle":"毛毛雨"}
try:
    req = urllib.request.urlopen('http://wttr.in/?format=j1&lang=zh', timeout=5)
    data = json.loads(req.read())
    cur = data['current_condition'][0]
    desc = cur['weatherDesc'][0]['value'].strip().lower()
    desc_cn = desc
    for k, v in trans.items():
        if k in desc:
            desc_cn = v
            break
    temp = cur['temp_C']
    feels = cur['FeelsLikeC']
    print(f'今天天气{desc_cn}，气温{temp}度，体感{feels}度。')
except:
    print('')
PYEOF
)
fi
if [[ -z "$weather_text" ]]; then
    raw=$(curl -s --max-time 5 "wttr.in?format=%c+%t&lang=zh" 2>/dev/null || true)
    weather_text=$(echo "$raw" | sed 's/\x1b\[[0-9;]*m//g' | tr -s ' ' | xargs)
    [[ -n "$weather_text" ]] && weather_text="今天天气${weather_text}。"
fi
speak "早上好。今天是${current_date}，${week_cn}。"
sleep 0.5
if [[ -n "$weather_text" ]]; then
    speak "$weather_text"
else
    speak "无法获取天气信息。"
fi
notify_desktop "MemoryGuard 清晨简报" "今天是${current_date} ${week_cn}\n天气: ${weather_text:-未知}"
log "INFO" "清晨简报已播报"
