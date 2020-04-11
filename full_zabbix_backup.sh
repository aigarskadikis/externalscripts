#!/bin/bash

# zabbix server or zabbix proxy for zabbix sender
#contact=127.0.0.1

# initialize startup message. 1 - backup is started
#/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.status -o 1

year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)
clock=$(date +%H%M)
dest=~/zabbix_backup/$year/$month/$day/$clock
if [ ! -d "$dest" ]; then
  mkdir -p "$dest"
fi

echo backuping full instance
mysqldump \
--flush-logs \
--single-transaction \
--create-options \
zabbix | gzip --best > $dest/db.full.zabbix.sql.gz

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
/etc/nginx/conf.d \
/etc/nginx/nginx.conf \
/etc/odbc.ini \
/etc/odbcinst.ini \
/etc/openldap/ldap.conf \
/etc/security/limits.conf \
/etc/selinux/config \
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

if [ ${PIPESTATUS[0]} -ne 0 ]; then
#/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.status -o 1
echo "mysqldump executed with error !!"
else
#/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.status -o 0
echo content of $dest
ls -lh $dest
fi

rclone  --delete-empty-src-dirs -vv move ~/zabbix_backup zabbixbackup:zabbix-DB-backup
