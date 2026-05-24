#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
MEMORY_FILE="$MG_ROOT/memory-aid/memory.txt"
[[ $# -eq 0 ]] && echo "用法: $0 <你的问题>" && exit 1
question="$*"
log "INFO" "问答: $question"
answer=""
while read -r keyword location; do
    [[ -z "$keyword" || "$keyword" == \#* ]] && continue
    if echo "$question" | fgrep -qi "$keyword"; then
        answer="${keyword} ${location}"
        break
    fi
done < "$MEMORY_FILE"
if [[ -n "$answer" ]]; then
    result=$(echo "$answer" | cut -d' ' -f2-)
    echo -e "${GREEN}> $result${NC}"
    speak "答案是，${keyword}，${result}"
    log "INFO" "回答: $result"
else
    msg="抱歉，我没有找到相关信息。"
    echo -e "${RED}$msg${NC}"
    speak "$msg"
    log "WARN" "未匹配: $question"
fi
