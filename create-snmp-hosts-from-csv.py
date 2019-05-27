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
   
   templates=line['template'].split(";")

   groups=line['group'].split(";")
   # look for first group in group array
   group_id = zapi.hostgroup.get({"filter" : {"name" : groups[0]}})[0]['groupid']
   template_id = zapi.template.get({"filter" : {"name" : templates[0]}})[0]['templateid']
   hostid = zapi.host.create ({
        "host":line['name'],"interfaces":[{"type":2,"dns":"","main":1,"ip": line['address'],"port": 161,"useip": 1,}],
        "groups": [{ "groupid": group_id }],
        "templates": [{ "templateid": template_id }]})['hostids']
   # add additional templates
   for templ in templates:
    idiftemp = zapi.template.get({"filter" : {"name" : templ}})[0]['templateid']   
    try:
     print zapi.template.massadd({"templates":idiftemp,"hosts":hostid})
    except Exception as e:
     print str(e)
 else:
   print line['name'],"already exit"
   # count the lenght of tempate array

file.close()
