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

file = open("list1.txt",'rb')
reader = csv.DictReader( file )

for line in reader:
 print line['name'],line['address'],line['template'],line['group']

 # create an array of templates
 templates=line['template'].split(";")
 print templates
 # create an array of groups
 groups=line['group'].split(";")
 print groups

 # look for first template in template array
 template_id = zapi.template.get({"filter" : {"name" : templates[0]}})[0]['templateid']
 print template_id
 
 # look for first group in group array
 group_id = zapi.hostgroup.get({"filter" : {"name" : groups[0]}})[0]['groupid']

#    t = zapi.host.create (
#    {
#        "host":line['name'],"interfaces":[{"type":2,"dns":"","main":1,"ip": line['address'],"port": 161,"useip": 1,}],
#        "groups": [{ "groupid": group_id }],
#        "templates": [{ "templateid": template_id }],
#    })

 # count the lenght of tempate array
 


file.close()
