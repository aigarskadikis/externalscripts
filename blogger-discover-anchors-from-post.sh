#!/bin/bash

#curl -s "https://$1/feeds/posts/default/$2?alt=json" | jq -r '.entry|.content|."$t"' | grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' | sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//' | sed "s/^\//https:\/\/$1\//" | sed "s/^/{\"{#LINK}\":\"/;s/$/\"},{\"{#ID}\":\"$2\"},/" | tr -cd "[:print:]" | sed "s/^/{\"data\":[/;s/,$/]}/"

zabbix_sender -z 127.0.0.1 -s "$1" -k discover.anchors -o "$(curl -s "https://$1/feeds/posts/default/$2?alt=json" | jq -r '.entry|.content|."$t"' | grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' | sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//' | sed "s/^\//https:\/\/$1\//" | sed "s/^/{\"{#LINK}\":\"/;s/$/\",\"{#ID}\":\"$2\"},/" | tr -cd "[:print:]" | sed "s/^/{\"data\":[/;s/,$/]}/")"

