#!/bin/bash

# usermod -a -G zabbix postgres

day=$(date +%Y%m%d)
clock=$(date +%H%M)
dest=~/10/backups/$day/$clock

if [ ! -d "$dest" ]; then
  mkdir -p "$dest"
fi

databases2backup=$(psql --host=pg --username=root --list | awk '$1=$1' | grep "^z.*")

echo "$databases2backup" | while IFS= read -r db
do {
echo "$db"
pg_dump --host=pg --username=root $db | gzip --best > $dest/$db.sql.gz
} done

rclone --delete-empty-src-dirs -vv move ~/10/backups ZabbixBackupPostgreSQL:ZabbixBackupPostgreSQL

