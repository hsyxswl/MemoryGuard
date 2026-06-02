#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
DB="$MG_ROOT/db/memoryguard.db"
usage() { echo "用法: $0 {add|list|delete|web-confirm} [参数]"; exit 1; }
cmd="${1:-}"
shift || true
case "$cmd" in
    add) sqlite3 "$DB" "INSERT INTO medicines (name,take_time,dosage,note) VALUES ('$1','$2','$3','$4');" ;;
    list) sqlite3 -column -header "$DB" "SELECT id, name, take_time, dosage, note FROM medicines;" ;;
    delete) sqlite3 "$DB" "DELETE FROM medicines WHERE name='$1';" ;;
    web-confirm)
        name="$1"
        command -v python3 &>/dev/null && name=$(python3 -c "import sys,urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$name")
        today=$(date +%Y-%m-%d)
        sqlite3 "$DB" "UPDATE med_log SET status='taken', confirmed_at=datetime('now') WHERE med_name='$name' AND taken_date='$today' AND status='pending';"
        ;;
    *) usage ;;
esac
