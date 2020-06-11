#!/bin/bash
 
# this script is suposed to run with root with ~/.my.cnf installed which allows passwordless use of mysqldump
 
day=$(date +%Y%m%d)
clock=$(date +%H%M)
dest=/home/zabbix_backup
if [ ! -d "$dest" ]; then
  mkdir -p "$dest"
fi

# backup schema
mysqldump \
--flush-logs \
--single-transaction \
--create-options \
--no-data \
zabbix | gzip --best > $dest/schema.sql.$day.$clock.gz

# backuping pure configuration without historical data
mysqldump \
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
zabbix | gzip --best > $dest/data.$day.$clock.gz
 
# backup important directories and files. last line search what is home directory for user 'zabbix'
sudo tar -zcvf $dest/fs.conf.zabbix.$day.$clock.tar.gz \
/etc/zabbix \
/usr/lib/zabbix \
/etc/php-fpm.d \
/etc/nginx \
/etc/httpd \
/etc/my.cnf.d \
/etc/yum.repos.d \
/usr/share/snmp/mibs \
$(grep zabbix /etc/passwd|cut -d: -f6)
 
# remove old backups
if [ -d "$dest" ]; then
  find $dest -type f -name '*.gz' -mtime +30 -exec rm {} \;
fi

