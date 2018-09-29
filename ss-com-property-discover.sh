#!/bin/bash

#each page contains multiple msg files
#that is why we need to create array to put all page msh into
declare -a array

#define endpoint for url for example if the ir is
#https://www.ss.com/lv/electronics/computers/multimedia/
#then the endpoint is "multimedia"

nr=0 #start check from page 0
httpcode=200 #reset the status code as OK

#this while loop is only to count how many pages needs to analyse
while [ "$httpcode" -eq "200" ]
do

#increase page number
nr=$((nr+1))

#set full url link
#remove the forwardslash in the end of argument if exists
url=$(echo "$1" | sed "s/\/$//")/page$nr.html

#check if url exist
httpcode=$(curl -s -o /dev/null -w "%{http_code}" "$url")

if [ "$httpcode" -eq "200" ]; then
#echo $url
array[nr]=$(curl -s "$url" | tr -cd '[:print:]' | sed "s|<tr|\n<tr|g;s|<\/tr>|\n|g" |\
grep "id..tr_[0-9]" | sed "s|<td|\n<td|g" | sed "1~10d" | sed "1~9d" | sed "2~8d" | sed "s|<br>|, |g" |\
sed "s|^.*\/msg\/|https:\/\/www.ss.com\/msg\/|g;s|\.html..id.*$|\.html|g" | sed "s/<[^>]*>//g" |\
sed "s|^|\"|g;s|$|\"|g" |\
sed ': loop;
i {\"{#URL}\":
a ,
n;
i \"{#PLACE}\":
a ,
n;
i \"{#ROOMS}\":
a ,
n;
i \"{#SQM}\":
a ,
n;
i \"{#FLOOR}\":
a ,
n;
i \"{#TYPE}\":
a ,
n;
i \"{#PRICE}\":
a },
n;
b loop' |\
tr -cd "[:print:]" | sed 's/\\/\\\\/g')
#echo "${array[nr]}"
else
nr=$((nr-1))
fi

done

#output all array elements
#replace spaces with new line characters
#convert output to JSON format for Zabbix LLD dicover prototype
echo "${array[@]}" | tr -cd '[:print:]' | sed "s/^/{\"data\":[/;s/,$/]}/" 

# to use this at crontab on Raspbarry Pi, on proxy compiled from source
# */15 * * * * cd /usr/local/share/zabbix/externalscripts && ./ss-com-property-discover.sh https://www.ss.com/lv/real-estate/flats/riga/all/hand_over | sed 's|\"|\\\\\"|g' > /dev/shm/hand.over.zbx && sed "s|^|\"ss.com\ flats\ hand\ over\" discover.ss.items\ \"|;s|$|\"|" /dev/shm/hand.over.zbx > /dev/shm/hand.over.39.zbx && /usr/local/bin/zabbix_sender -z 127.0.0.1 -i /dev/shm/hand.over.39.zbx

# 55 * * * * cd /usr/local/share/zabbix/externalscripts && ./ss-com-property-discover.sh https://www.ss.com/lv/real-estate/flats/riga/all/sell/ | sed 's/\\\\/\\\\\\\\/g' |sed 's|\"|\\\\\"|g' > /dev/shm/sell.zbx && sed -i "s|^|\"ss.com\ flats\ sell\" discover.ss.items\ \"|;s|$|\"|" /dev/shm/sell.zbx && /usr/local/bin/zabbix_sender -z 127.0.0.1 -i /dev/shm/sell.zbx
# to use this at crontab

# on CentOS 7 use to use this at crontab
#38 * * * * cd /usr/lib/zabbix/externalscripts && ./ss-com-property-discover.sh https://www.ss.com/lv/real-estate/flats/riga/all/hand_over | sed 's/\\/\\\\/g' |sed 's|\"|\\\"|g' > /dev/shm/hand.over.zbx && sed "s|^|\"ss.com\ flats\ hand\ over\" discover.ss.items\ \"|;s|$|\"|" /dev/shm/hand.over.zbx > /dev/shm/hand.over.39.zbx && /usr/bin/zabbix_sender -z 127.0.0.1 -i /dev/shm/hand.over.39.zbx

#41 * * * * cd /usr/lib/zabbix/externalscripts && ./ss-com-property-discover.sh https://www.ss.com/lv/real-estate/flats/riga/all/sell/ | sed 's/\\/\\\\/g' |sed 's|\"|\\\"|g' > /dev/shm/sell.zbx && sed -i "s|^|\"ss.com\ flats\ sell\" discover.ss.items\ \"|;s|$|\"|" /dev/shm/sell.zbx && /usr/bin/zabbix_sender -z 127.0.0.1 -i /dev/shm/sell.zbx
