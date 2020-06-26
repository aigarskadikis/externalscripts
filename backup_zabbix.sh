#!/bin/bash

# zabbix server or zabbix proxy for zabbix sender
contact=127.0.0.1

year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)
clock=$(date +%H%M)
volume=/backup/zabbix
mysql=$volume/mysql/$year/$month/$day/$clock
filesystem=$volume/filesystem/$year/$month/$day/$clock
if [ ! -d "$mysql" ]; then
  mkdir -p "$mysql"
fi

if [ ! -d "$filesystem" ]; then
  mkdir -p "$filesystem"
fi

echo backuping schema
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.schema.status -o 1
mysqldump \
--flush-logs \
--single-transaction \
--create-options \
--no-data \
zabbix | xz > $mysql/schema.sql.xz

if [ ${PIPESTATUS[0]} -ne 0 ]; then
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.schema.status -o 1
echo "mysqldump executed with error !!"
else
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.schema.status -o 0
echo content of $mysql
ls -lh $mysql
fi

/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.schema.size -o $(ls -s --block-size=1 $mysql/schema.sql.xz | grep -Eo "^[0-9]+")

sleep 1
echo backup all except raw metrics. those can be restored later
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.conf.data.status -o 1
mysqldump \
--set-gtid-purged=OFF \
--flush-logs \
--single-transaction \
--no-create-info \
--ignore-table=zabbix.history \
--ignore-table=zabbix.history_log \
--ignore-table=zabbix.history_str \
--ignore-table=zabbix.history_text \
--ignore-table=zabbix.history_uint \
--ignore-table=zabbix.trends \
--ignore-table=zabbix.trends_uint \
zabbix | xz > $mysql/data.sql.xz

if [ ${PIPESTATUS[0]} -ne 0 ]; then
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.conf.data.status -o 1
echo "mysqldump executed with error !!"
else
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.conf.data.status -o 0
echo content of $mysql
ls -lh $mysql
fi

/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.conf.data.size -o $(ls -s --block-size=1 $mysql/data.sql.xz | grep -Eo "^[0-9]+")

# grafana container dir
grafana=$(sudo docker inspect grafana | jq -r ".[].GraphDriver.Data.UpperDir")

sleep 1
echo archiving important directories and files
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.filesystem.status -o 1

sudo tar -cJf $filesystem/fs.conf.zabbix.tar.xz \
--files-from "${0%/*}/backup_zabbix_files.list" \
--files-from "${0%/*}/backup_zabbix_directories.list" \
/usr/bin/zabbix_* \
$(grep zabbix /etc/passwd|cut -d: -f6) \
$grafana/var/lib/grafana 

/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.filesystem.status -o $?

/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.filesystem.size -o $(ls -s --block-size=1 $filesystem/fs.conf.zabbix.tar.xz | grep -Eo "^[0-9]+")

echo uploading files to google drive
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.upload.status -o 1
rclone -vv sync $volume BackupMySQL:zabbix-DB-backup

/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.upload.status -o $?

