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
zabbix | gzip --best > $dest/db.full.zabbix.sql.gz

echo list installed packages
yum list installed > $dest/yum.list.installed.log

echo archiving important directories and files
sudo tar -zcvf $dest/fs.conf.zabbix.tar.gz \
/etc/crontab \
/etc/grafana/grafana.ini \
/etc/httpd \
/etc/letsencrypt \
/etc/my.cnf.d \
/etc/nginx \
/etc/odbc.ini \
/etc/odbcinst.ini \
/etc/openldap \
/etc/php-fpm.d \
/etc/rc.local \
/etc/security/limits.conf \
/etc/snmp/snmpd.conf \
/etc/snmp/snmptrapd.conf \
/etc/sudoers \
/etc/sudoers.d \
/etc/sysconfig \
/etc/systemd/system/mariadb.service.d \
/etc/systemd/system/nginx.service.d \
/etc/systemd/system/php-fpm.service.d \
/etc/systemd/system/zabbix-agent.service.d \
/etc/systemd/system/zabbix-agent2.service.d \
/etc/systemd/system/zabbix-server.service.d \
/etc/sysctl.conf \
/etc/yum.repos.d \
/etc/zabbix \
/usr/bin/frontend-version-change \
/usr/bin/postbody.py \
/usr/bin/zabbix_trap_receiver.pl \
/usr/lib/zabbix \
/usr/share/grafana \
/usr/share/snmp/mibs \
/var/lib/pgsql/10/data/pg_hba.conf \
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
