#!/bin/bash
curl -o /dev/null -m 25 -s -w %{http_code} $1
#wget --spider -S "$1" 2>&1 | grep "HTTP/" | awk '{print $2}'
