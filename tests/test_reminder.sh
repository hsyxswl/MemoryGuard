#!/bin/bash
source "$(dirname "$0")/../lib/common.sh"
DB="$MG_ROOT/db/memoryguard.db"
sqlite3 "$DB" "INSERT INTO medicines (name,take_time,dosage) VALUES ('test','$(date +%H:%M)','1片');"
bash "$MG_ROOT/med-reminder/reminder.sh" > /dev/null 2>&1
sleep 2
count=$(sqlite3 "$DB" "SELECT count(*) FROM med_log WHERE med_name='test';")
if [[ $count -gt 0 ]]; then
    echo -e "${GREEN}[PASS]${NC}"
else
    echo -e "${RED}[FAIL]${NC}"
fi
sqlite3 "$DB" "DELETE FROM medicines WHERE name='test'; DELETE FROM med_log WHERE med_name='test';"
