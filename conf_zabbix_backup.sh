#!/bin/bash

# mysqldump: Couldn't execute 'FLUSH TABLES': Access denied; you need (at least one of) the RELOAD privilege(s) for this operation (1227)
# grant RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT on *.* to 'zbx_backup'@'localhost' identified by 'your-password';

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

echo backuping pure configuration
mysqldump \
--set-gtid-purged=OFF \
--flush-logs \
--single-transaction \
--create-options \
--ignore-table=zabbix.acknowledges \
--ignore-table=zabbix.alerts \
--ignore-table=zabbix.auditlog \
--ignore-table=zabbix.auditlog_details \
--ignore-table=zabbix.events \
--ignore-table=zabbix.history \
--ignore-table=zabbix.history_log \
--ignore-table=zabbix.history_str \
--ignore-table=zabbix.history_text \
--ignore-table=zabbix.history_uint \
--ignore-table=zabbix.trends \
--ignore-table=zabbix.trends_uint \
--ignore-table=zabbix.profiles \
--ignore-table=zabbix.service_alarms \
--ignore-table=zabbix.sessions \
--ignore-table=zabbix.problem \
--ignore-table=zabbix.event_recovery \
zabbix | gzip --best > $dest/db.conf.zabbix.sql.gz

if [ ${PIPESTATUS[0]} -ne 0 ]; then
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.status -o 1
echo "mysqldump executed with error !!"
else
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.status -o 0
echo content of $dest
ls -lh $dest
fi

echo list installed packages
yum list installed > $dest/yum.list.installed.log

# grafana container dir
grafana=$(sudo docker inspect grafana | jq -r ".[].GraphDriver.Data.UpperDir")

echo archiving important directories and files
sudo tar -zcvf $dest/fs.conf.zabbix.tar.gz \
$(grep zabbix /etc/passwd|cut -d: -f6) \
$grafana/var/lib/grafana \
/etc/cron.d \
/etc/letsencrypt \
/etc/nginx \
/etc/odbc.ini \
/etc/odbcinst.ini \
/etc/openldap/ldap.conf \
/etc/php-fpm.d \
/etc/security/limits.conf \
/etc/snmp/snmptrapd.conf \
/etc/sudoers.d \
/etc/sysconfig/zabbix-agent \
/etc/sysconfig/zabbix-server \
/etc/sysctl.conf \
/etc/systemd/system/nginx.service.d \
/etc/systemd/system/php-fpm.service.d \
/etc/systemd/system/zabbix-agent.service.d \
/etc/systemd/system/zabbix-server.service.d \
/etc/yum.repos.d \
/etc/zabbix \
/home/zbxbackupuser/.config/rclone/rclone.conf \
/root/.bashrc \
/root/.gitconfig \
/root/.my.cnf \
/root/.ssh \
/root/.vimrc \
/root/bin \
/usr/bin/zabbix_trap_receiver.pl \
/usr/lib/zabbix \
/usr/share/snmp/mibs \
/var/lib/pgsql/.config/rclone/rclone.conf \
/var/lib/pgsql/.pgpass

echo uploading files to google drive
rclone  --delete-empty-src-dirs -vv move ~/zabbix_backup zabbixbackup:zabbix-DB-backup
