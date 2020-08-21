#!/bin/bash

#each page contains multiple msg files
#that is why we need to create array to put all page msh into
declare -a array

#define endpoint for url for example if the ir is
#https://catonrug.blogspot.com/feeds/posts/default/?atom.xml?redirect=false&start-index=1&max-results=50
#then the endpoint is "multimedia"
endpoint="https://$1/feeds/posts/default/?atom.xml?redirect=false&max-results=50&start-index="

arr=0 # array position
count_of_elements=1 # count the found posts
nr=1 #start check from page 0

# while the atom.xml file contans at least 1 record, continue to gather data
while [ "$count_of_elements" -ne "0" ]
do

# analize next 50 posts
nr=$((nr+50))

# switch to next slot in array
arr=$((arr+1))

#set full url link
#remove the forwardslash in the end of argument if exists
url=$(echo "$endpoint$nr")
echo $url

#check if url exist
httpcode=$(curl -s -o /dev/null -w "%{http_code}" "$url")

if [ "$count_of_elements" -ne "0" ]; then
array[arr]=$(curl -s "$url" | grep -Eo "blog-[0-9]+\.post-[0-9]+")
count_of_elements=$(echo "${array[arr]}" | grep -Eo "blog-[0-9]+\.post-[0-9]+" | wc -l)
#echo "${array[arr]}" 
else
arr=$((arr-1))
fi

done

#output all array elements
#replace spaces with new line characters
#convert output to JSON format for Zabbix LLD dicover prototype
echo "${array[@]}" | grep -Eo "blog-[0-9]+\.post-[0-9]+" | sort | uniq | sed 's%blog-%{\d034{#BLOGID}\d034:\d034%;s%.post-%\d034,\d034{#POSTID}\d034:\d034%;s%$%\d034},%' | tr -cd '[:print:]' | sed "s/^/{\"data\":[/;s/,$/]}/"

