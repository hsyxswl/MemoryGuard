#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
bash "$MG_ROOT/memory-aid/ask.sh" "钥匙在哪" | fgrep -q "挂钩" && echo -e "${GREEN}[PASS]${NC}" || echo -e "${RED}[FAIL]${NC}"
