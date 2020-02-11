#!/bin/bash

# usermod -a -G zabbix postgres

day=$(date +%Y%m%d)
clock=$(date +%H%M)
dest=~/10/backups/$day/$clock

if [ ! -d "$dest" ]; then
  mkdir -p "$dest"
fi

databases2backup=$(psql -t -c "SELECT datname FROM pg_database" | awk '$1=$1' | grep "^z.*")

echo "$databases2backup" | while IFS= read -r db
do {
echo "$db"
pg_dump $db | gzip --best > $dest/$db.sql.gz
} done

rclone --delete-empty-src-dirs -vv move ~/10/backups ZabbixBackupPostgreSQL:ZabbixBackupPostgreSQL

