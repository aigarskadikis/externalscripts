#!/bin/bash

# zabbix server or zabbix proxy for zabbix sender
contact=127.0.0.1

year=$(date +%Y)
month=$(date +%m)
day=$(date +%d)
clock=$(date +%H%M)
dest=~/zabbix_backup/$year/$month/$day/$clock
if [ ! -d "$dest" ]; then
  mkdir -p "$dest"
fi

echo backuping schema
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.schema.status -o 1
mysqldump \
--flush-logs \
--single-transaction \
--create-options \
--no-data \
zabbix | xz > $dest/schema.sql.xz

if [ ${PIPESTATUS[0]} -ne 0 ]; then
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.schema.status -o 1
echo "mysqldump executed with error !!"
else
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.schema.status -o 0
echo content of $dest
ls -lh $dest
fi

/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.schema.size -o $(ls -s --block-size=1 $dest/schema.sql.xz | grep -Eo "^[0-9]+")

echo backuping full instance
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.full.data.status -o 1
# do not use highest compression 'zx -9'! it will not work because of low memory
mysqldump \
--flush-logs \
--single-transaction \
--no-create-info \
zabbix | xz > $dest/data.sql.xz

if [ ${PIPESTATUS[0]} -ne 0 ]; then
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.full.data.status -o 1
echo "mysqldump executed with error !!"
else
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.full.data.status -o 0
echo content of $dest
ls -lh $dest
fi

/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.sql.full.data.size -o $(ls -s --block-size=1 $dest/data.sql.xz | grep -Eo "^[0-9]+")

echo list installed packages
yum list installed > $dest/yum.list.installed.log

# grafana container dir
grafana=$(sudo docker inspect grafana | jq -r ".[].GraphDriver.Data.UpperDir")

sleep 1

echo archiving important directories and files
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.filesystem.status -o 1
sudo tar -zcvf $dest/fs.conf.zabbix.tar.gz \
$(grep zabbix /etc/passwd|cut -d: -f6) \
$grafana/var/lib/grafana \
/etc/cron.d \
/etc/letsencrypt \
/etc/nginx/conf.d \
/etc/nginx/nginx.conf \
/etc/openldap/ldap.conf \
/etc/security/limits.conf \
/etc/selinux/config \
/etc/snmp/snmptrapd.conf \
/etc/sudoers.d \
/etc/sysconfig/zabbix-agent \
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
/usr/local/sbin \
/usr/share/snmp/mibs \
/var/lib/pgsql/.config/rclone/rclone.conf \
/var/lib/pgsql/.pgpass > /dev/null

/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.filesystem.status -o $?

/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.filesystem.size -o $(ls -s --block-size=1 $dest/fs.conf.zabbix.tar.xz | grep -Eo "^[0-9]+")

echo uploading files to google drive
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.upload.status -o 1
rclone move ~/zabbix_backup zabbixbackup:zabbix-DB-backup --delete-empty-src-dirs -v
/usr/bin/zabbix_sender --zabbix-server $contact --host $(hostname) -k backup.upload.status -o $?
