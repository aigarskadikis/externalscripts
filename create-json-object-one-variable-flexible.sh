#!/bin/bash
IFS=':, ' read -r -a array <<< "$1"
idx=0
echo {\"data\":[
while [ -n "${array[$idx]}" ]; do
echo -n \{\"{#path}\":\""${array[$idx]}"\}
let idx=$idx+1
[ -n "${array[idx]}" ] && echo "," || echo
done
echo ]}
exit
