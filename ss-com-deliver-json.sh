#!/bin/bash

# $1 = "ss.com flats hand over"
# $2 = https://www.ss.com/lv/real-estate/flats/riga/all/hand_over

jobid=$(echo $2 | sed "s/\/$//" | sed "s/^.*\///g")
out=/dev/shm/zbx.ss.com.$jobid.json

cd /usr/lib/zabbix/externalscripts
./ss-com-property-discover.sh $2 > $out

jq . $out > /dev/null
/usr/bin/zabbix_sender -z 127.0.0.1 -s $1 -k json.error -o $?
