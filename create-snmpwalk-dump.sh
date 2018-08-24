#/bin/bash
destination=/home/zabbix/snmpwalk.dump

if [ ! -d "$destination" ]; then
mkdir -p "$destination"
fi

if [ ! -f "$destination/numeric-$2.log" ]; then
/usr/bin/snmpwalk -v2c -c $1 $2 -OfT . > "$destination/numeric-$2.log"
fi



