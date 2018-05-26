#!/bin/bash
curl -s "https://$1/feeds/posts/default/-/$2/?atom.xml?redirect=false&start-index=1&max-results=50" | egrep -o "\/posts\/default\/[0-9]+" |sort|uniq| egrep -o "[0-9]+" | sed "s/^/{\"{#POST}\":\"/;s/$/\"},/" | tr -cd "[:print:]" | sed "s/^/{\"data\":[/;s/,$/]}/"

