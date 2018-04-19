#!/bin/bash

#each page contains multiple msg files
#that is why we need to create array to put all page msh into
declare -a array

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
array[nr]=$(curl -s "$url" | egrep -o "[0-9a-z]+\.html" | grep -v "^page" | sed "s/\..*$//g" | sort | uniq)

else
nr=$((nr-1))
fi

done

#output all array elements
#replace spaces with new line characters
#convert output to JSON format for Zabbix LLD dicover prototype
echo "${array[@]}" | sed "s/\s/\n/g" | sed "s/^/{\"{#MSG}\":\"/;s/$/\"},/" | tr -cd '[:print:]' | sed "s/^/{\"data\":[/;s/,$/]}/"

