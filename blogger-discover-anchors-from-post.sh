#!/bin/bash
curl -s "https://$1/feeds/posts/default/$2?alt=json" | jq -r '.entry|.content|."$t"' | grep -o '<a href=['"'"'"][^"'"'"']*['"'"'"]' | sed -e 's/^<a href=["'"'"']//' -e 's/["'"'"']$//' | sed "s/^\//https:\/\/$1\//" | sed "s/^/{\"{#LINK}\":\"/;s/$/\"},/" | tr -cd "[:print:]" | sed "s/^/{\"data\":[/;s/,$/]}/"


