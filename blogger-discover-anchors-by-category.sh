#!/bin/bash


#maximum count blogger can contain per one sitemap view is 50 posts
#that is why we need to create array to put all post ids inside 
declare -a array

nr=-49 #start check from page 0
count=1 #loop will continue while there is at least one post in sitemap

#loop starts because we definet so in previous step
while [ "$count" -gt "0" ]
do

#how many posts should check per one view
nr=$((nr+50))

#set up full url link
url="https://$1/feeds/posts/default/-/$(echo "$2"|sed "s/ /%20/g")/?atom.xml?redirect=false&start-index=$nr&max-results=50"

#uncoment for debuging
#echo "$url"

#check if url exist
httpcode=$(curl -s -o /dev/null -w "%{http_code}" "$url")

if [ "$httpcode" -eq "200" ]; then
array[nr]=$(curl -s "$url" | xmllint --xpath "//*[local-name()='feed']/*[local-name()='entry']/*[local-name()='content']" - | sed "s/<content/\n<content/g" | sed "s/\d034\|\d039/\n/g" | grep "^http.*://")

#count how many posts is there
count=$(echo "${array[nr]}"|grep -v "^$"|wc -l)

#uncomment for debuging
#echo "${array[nr]}"
#echo $count
#echo

fi

done

#output all array elements
#convert output to JSON format for Zabbix LLD dicover prototype
echo "${array[@]}" | sort | uniq | sed "s/^/{\"{#LINK}\":\"/;s/$/\"},/" | tr -cd "[:print:]" | sed "s/^/{\"data\":[/;s/,$/]}/"

