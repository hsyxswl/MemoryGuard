#!/bin/bash
# 启动 Python Web 服务器，如果 Python 不可用则回退到 nc 模式（可选）
cd "$(dirname "$0")" || exit
if command -v python3 &>/dev/null; then
    exec python3 web_status.py "$@"
else
    echo "错误: 未找到 python3，无法启动 Web 服务"
    exit 1
fi
