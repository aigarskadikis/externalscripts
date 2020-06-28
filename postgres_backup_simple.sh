#!/bin/bash

year=$(date +%Y)
day=$(date +%m%d)
clock=$(date +%H%M)
volume=/backup/postgres
dest=$volume/$year/$day/$clock

if [ ! -d "$dest" ]; then
  mkdir -p "$dest"
fi

for db in $(
PGPASSWORD=zabbix PGUSER=postgres psql -h 10.133.112.87 -t -A -c "SELECT datname FROM pg_database where datname not in ('template0','template1','postgres','dummy_db')"
) ; do echo $db; PGPASSWORD=zabbix PGUSER=postgres pg_dump -h 10.133.112.87 $db | gzip --best > $dest/$db.sql.gz ; done

rclone -vv sync $volume BackupPostgreSQL:postgres
