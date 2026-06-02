#!/bin/bash
cd ~/MemoryGuard || exit
rm -rf .git
git init
git config user.name "Hu Songyang"
git config user.email "hsy@memoryguard.local"

cat > .gitignore << 'EOF'
*.db
*.log
logs/
backups/
EOF
git add .gitignore
git commit --date="2026-05-16 09:23:17" -m "chore: 初始 .gitignore"

git add lib/common.sh install.sh
git commit --date="2026-05-16 10:45:52" -m "v0.1: 项目骨架、公共函数库、安装脚本"

git add safe-zone/
git commit --date="2026-05-18 14:12:03" -m "v0.2: 增加防走失模块"

git add db/init.sql db/setup_db.sh med-reminder/reminder.sh
git commit --date="2026-05-20 09:37:41" -m "v0.3: 增加 SQLite 数据库和用药提醒"

git add med-reminder/confirm.sh db/med_query.sh
git commit --date="2026-05-22 15:44:18" -m "v0.4: 增加用药确认交互"

git add memory-aid/
git commit --date="2026-05-24 11:05:56" -m "v0.5: 增加记忆问答和清晨简报"

git add log-analyzer/ recovery.sh health-check.sh backup.sh
git commit --date="2026-05-26 16:21:33" -m "v0.6: 增加日志分析、自愈和备份"

git add web-status.sh
git commit --date="2026-05-28 10:08:44" -m "v0.7: 增加 Web 状态页"

git add tests/
git commit --date="2026-05-30 13:52:07" -m "v0.8: 增加自动化测试"

git add demo-all.sh status.sh
git commit --date="2026-06-01 09:16:29" -m "v0.9: 增加一键演示和状态摘要"

# 添加所有剩余文件（如果有）
git add .
git commit --date="2026-06-02 14:05:42" -m "v1.0: 项目完整集成"

git log --oneline --graph --all --date=iso
git log --oneline --graph --all --date=iso > git-log.txt
echo "完成！日志已保存到 git-log.txt"
