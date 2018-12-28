#!/bin/bash
CALL=$(find /var/log/zabbix/`date +%m`-`date +%Y`/`date +%d`/ -name zabbix_server.log)
MACRO=LOGFILE
#echo $CALL | xargs -n1  | cut -d'>' -f2- | cut -d'<' -f1
COUNT=$(echo $CALL| xargs -n1 | wc -l)
printf "{\"data\":[\n"
echo $CALL | xargs -n1 | cut -d'>' -f2- | cut -d'<' -f1 | while read line; do \
        if [[ $COUNT > 1 ]];then
                printf "{\"{#$MACRO}\":\"$line\"},\n"
                COUNT=$(( COUNT - 1))
        elif [[ $COUNT = 1 ]]; then
                printf "{\"{#$MACRO}\":\"$line\"}\n"
fi;
done
printf "]}\n"
