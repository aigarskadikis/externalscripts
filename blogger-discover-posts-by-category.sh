#!/bin/bash




#each page contains multiple msg files
#that is why we need to create array to put all page msh into
declare -a array

nr=-49 #start check from page 0
count=1 #reset the status code as OK

#this while loop is only to count how many pages needs to analyse
while [ "$count" -gt "0" ]
do

#increase page number
nr=$((nr+50))

#set full url link
#remove the forwardslash in the end of argument if exists
url="https://$1/feeds/posts/default/-/$(echo "$2"|sed "s/ /%20/g")/?atom.xml?redirect=false&start-index=$nr&max-results=50"
#echo "$url"

#check if url exist
httpcode=$(curl -s -o /dev/null -w "%{http_code}" "$url")

if [ "$httpcode" -eq "200" ]; then
array[nr]=$(curl -s "$url" | egrep -o "\/posts\/default\/[0-9]+" |sort|uniq| egrep -o "[0-9]+")

#count how many posts is there
count=$(echo "${array[nr]}"|grep -v "^$"|wc -l)
#echo "${array[nr]}"
#echo $count
fi

done

#output all array elements
#replace spaces with new line characters
#convert output to JSON format for Zabbix LLD dicover prototype
echo "${array[@]}" |sort|uniq|sed "s/^/{\"{#POST}\":\"/;s/$/\"},/" | tr -cd "[:print:]" | sed "s/^/{\"data\":[/;s/,$/]}/"

