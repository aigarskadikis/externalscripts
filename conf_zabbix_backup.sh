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
/usr/bin/reboo_sequence \
/etc/sysconfig/zabbix-agent2 \
/etc/sysconfig/zabbix-agent \
/etc/sysconfig/zabbix-proxy \
/etc/sysconfig/zabbix-server \
/var/lib/pgsql/.config/rclone \
/var/lib/pgsql/.pgpass \
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
