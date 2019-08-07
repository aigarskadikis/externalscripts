#!/bin/bash

# zabbix server or zabbix proxy for zabbix sender
contact=127.0.0.1

# initialize startup message. 1 - backup is started
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.status -o 1

day=$(date +%Y%m%d)
clock=$(date +%H%M)
dest=~/zabbix_backup/$day/$clock
if [ ! -d "$dest" ]; then
  mkdir -p "$dest"
fi

echo backup partitions for the 7 biggest tables
mysql zabbix <<<'show create table history\G;'|grep PARTITION|tr -cd "[:print:]"|sed "s|^|ALTER TABLE \`history\`|"|sed "s|$|;\n|"> $dest/create.historical.partitions.sql
mysql zabbix <<<'show create table history_log\G;'|grep PARTITION|tr -cd "[:print:]"|sed "s|^|ALTER TABLE \`history_log\`|"|sed "s|$|;\n|">> $dest/create.historical.partitions.sql
mysql zabbix <<<'show create table history_str\G;'|grep PARTITION|tr -cd "[:print:]"|sed "s|^|ALTER TABLE \`history_str\`|"|sed "s|$|;\n|">> $dest/create.historical.partitions.sql
mysql zabbix <<<'show create table history_text\G;'|grep PARTITION|tr -cd "[:print:]"|sed "s|^|ALTER TABLE \`history_text\`|"|sed "s|$|;\n|">> $dest/create.historical.partitions.sql
mysql zabbix <<<'show create table history_uint\G;'|grep PARTITION|tr -cd "[:print:]"|sed "s|^|ALTER TABLE \`history_uint\`|"|sed "s|$|;\n|">> $dest/create.historical.partitions.sql
mysql zabbix <<<'show create table trends\G;'|grep PARTITION|tr -cd "[:print:]"|sed "s|^|ALTER TABLE \`trends\`|"|sed "s|$|;\n|">> $dest/create.historical.partitions.sql
mysql zabbix <<<'show create table trends_uint\G;'|grep PARTITION|tr -cd "[:print:]"|sed "s|^|ALTER TABLE \`trends_uint\`|"|sed "s|$|;\n|">> $dest/create.historical.partitions.sql

echo backuping full instance
mysqldump \
--flush-logs \
--single-transaction \
--create-options \
zabbix | gzip --best > $dest/db.full.zabbix.gz

# backup importand directories and files. last line search what is home direcotry for user 'zabbix'
sudo tar -zcvf $dest/fs.conf.zabbix.tar.gz \
/etc/zabbix \
/usr/lib/zabbix \
/etc/httpd \
/etc/my.cnf.d \
/etc/yum.repos.d \
/usr/share/snmp/mibs \
/etc/letsencrypt \
/etc/crontab \
/etc/zabbix/web/zabbix.conf.php \
$(grep zabbix /etc/passwd|cut -d: -f6)

if [ ${PIPESTATUS[0]} -ne 0 ]; then
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.status -o 1
echo "mysqldump executed with error !!"
else
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.status -o 0
echo content of $dest
ls -lh $dest
fi

rclone  --delete-empty-src-dirs -vv move ~/zabbix_backup zabbixbackup:zabbix-DB-backup
