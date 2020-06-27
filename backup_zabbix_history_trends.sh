#!/bin/bash
destination=/backup/zabbix/mysql/raw
mkdir -p $destination
yesterday=$(date -d "1 DAY AGO" "+%Y-%m-%d")
today=$(date -d "0 DAY AGO" "+%Y-%m-%d")
echo "
history
history_uint
history_str
history_text
history_log
trends
trends_uint
" | \
grep -v "^$" | \
while IFS= read -r table; do {
echo $table
old=$(echo $table|sed "s|$|_old|")
if [ ! -f "$destination/$table.sql.xz.$yesterday" ]; then
mysqldump \
--flush-logs \
--single-transaction \
--no-create-info \
zabbix $table --where=" \
clock >= UNIX_TIMESTAMP(\"$yesterday 00:00:00\") \
AND \
clock < UNIX_TIMESTAMP(\"$today 00:00:00\") \
" | sed "s|$table|$old|" > $destination/$table.sql && \
xz $destination/$table.sql && \
mv $destination/$table.sql.xz $destination/$table.sql.xz.$yesterday
fi
} done
