#!/bin/bash

# add a dedicated linux user
# groupadd zbxbackupuser
# useradd -g zbxbackupuser -s /bin/bash zbxbackupuser
# usermod -a -G zabbix zbxbackupuser

# allow this user to pick up any file from system with sudo command
# echo "zbxbackupuser        ALL=(ALL)       NOPASSWD: ALL"> /etc/sudoers.d/010_zbx-backup-user

# to run this code mysql credentials must be installed at home directory. this can be done using
# cd
# echo -e "[client]\nuser=zbxbackupuser\npassword=zabbix" > .my.cnf
# chmod 600 .my.cnf

# grant all privileges on zabbix.* to "zbxbackupuser"@"localhost" identified by "zabbix";
# grant RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT on *.* to "zbxbackupuser"@"localhost" identified by "zabbix";

# echo "51 */3 * * * zbxbackupuser /usr/lib/zabbix/externalscripts/full_zabbix_backup.sh" | sudo tee -a /etc/crontab

day=$(date +%Y%m%d)
clock=$(date +%H%M)
dest=~/zabbix_backup
if [ ! -d "$dest" ]; then
  mkdir -p "$dest"
fi

# database backup without history tables
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
zabbix | gzip --best > $dest/db.conf.zabbix.$day.$clock.gz

# backup importand directories and files. last line search what is home direcotry for user 'zabbix'
sudo tar -zcvf $dest/fs.conf.zabbix.$day.$clock.tar.gz \
/etc/zabbix \
/usr/lib/zabbix \
/etc/nginx \
/etc/my.cnf.d \
/etc/php-fpm.d \
/etc/yum.repos.d \
/etc/systemd/system/zabbix-server.service.d \
/etc/systemd/system/zabbix-agent2.service.d \
/etc/systemd/system/zabbix-agent.service.d \
/etc/systemd/system/nginx.service.d \
/etc/systemd/system/php-fpm.service.d \
/etc/systemd/system/mariadb.service.d \
/usr/share/snmp/mibs \
/etc/crontab \
/etc/snmp/snmptrapd.conf \
/etc/zabbix/web/zabbix.conf.php \
$(grep zabbix /etc/passwd|cut -d: -f6)

# backup bolongs to linux user 'zbxbackupuser'
sudo chown zbxbackupuser. $dest/fs.conf.zabbix.$day.$clock.tar.gz

# remove old backups
if [ -d "$dest" ]; then
  find $dest -type f -name '*.gz' -mtime +90 -exec rm {} \;
fi
