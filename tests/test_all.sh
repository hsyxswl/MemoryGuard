#!/bin/bash
echo "执行全量回归测试"
bash "$(dirname "$0")/test_safe_zone.sh"
bash "$(dirname "$0")/test_reminder.sh"
bash "$(dirname "$0")/test_memory_aid.sh"
echo "全部测试完成"
