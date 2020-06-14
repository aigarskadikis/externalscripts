#!/bin/bash
for table in $( \
mysql zabbix -B -N -e "show tables" | \
grep "^history\|^trends"); do \
mysqldump \
--flush-logs \
--single-transaction \
--no-create-info \
zabbix $table --where=" \
clock >= UNIX_TIMESTAMP(\"$(date -d "2 DAY AGO" "+%Y-%m-%d 00:00:00")\") \
AND \
clock < UNIX_TIMESTAMP(\"$(date -d "1 DAY AGO" "+%Y-%m-%d 00:00:00")\") \
" | xz > /home/zabbix_backup/$table.sql.xz.$(date -d "2 DAY AGO" "+%Y-%m-%d")
done

