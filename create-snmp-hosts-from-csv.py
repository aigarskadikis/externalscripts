#!/usr/bin/python
# import hosts from txt file to Zabbix via API
# and assign template and host group to them
import csv
from zabbix_api import ZabbixAPI

server="http://127.0.0.1/"
username="Admin"
password="zabbix"

zapi = ZabbixAPI(server=server)
zapi.login(username, password)

file = open("hostlist.txt",'rb')
reader = csv.DictReader( file )

# take the file and read line by line
for line in reader:
 
 # check if this host exists in zabbix
 result = zapi.host.get({"filter":{"host" :line['name']}}) 
 if not result:
   #print line['name'],line['address'],line['template'],line['group']
   print line['template']
   
   # put all templates in array
   temp_array=[]
   for templ in line['template'].split(";"):
    idiftemp = "template:"+str(zapi.template.get({"filter" : {"name" : templ}})[0]['templateid'])
    temp_array.append(idiftemp)

   print temp_array
 
   # look for first group in group array
#   group_id = zapi.hostgroup.get({"filter" : {"name" : groups[0]}})[0]['groupid']
#   print group_id
#   t = zapi.host.create ({
#        "host":line['name'],"interfaces":[{"type":2,"dns":"","main":1,"ip": line['address'],"port": 161,"useip": 1,}],
#        "groups": [{ "groupid": group_id }],
#        "templates": [{ "templateid": template_id }]})
 else:
   print line['name'],"already exit"
   # count the lenght of tempate array

file.close()
