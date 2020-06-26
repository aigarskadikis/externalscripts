#!/bin/bash
destination=/home/mysql
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
if [ ! -f "$destination/$table.sql.xz.$yesterday" ]; then
mysqldump \
--flush-logs \
--single-transaction \
--no-create-info \
zabbix $table --where=" \
clock >= UNIX_TIMESTAMP(\"$yesterday 00:00:00\") \
AND \
clock < UNIX_TIMESTAMP(\"$today 00:00:00\") \
" | xz > $destination/$table.sql.xz && \
mv $destination/$table.sql.xz $destination/$table.sql.xz.$yesterday
fi
} done
