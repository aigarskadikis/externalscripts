#!/bin/bash
list=$(curl -s "https://$1/feeds/posts/default/$2?alt=json" | \
jq -r '.entry|.content|."$t"' | \
grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' | \
sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//' | \
sed "s/^\//https:\/\/$1\//")

echo "$list" | wc -l

zabbix_sender --zabbix-server 127.0.0.1 \
	--host "$1" \
	-k "discover.anchors" \
	-o $(echo "$list" | \
	sed "s/^/{\"{#LINK}\":\"/;s/$/\",\"{#ID}\":\"$2\"},/" | \
	tr -cd "[:print:]" | \
	sed "s/^/{\"data\":[/;s/,$/]}/")

