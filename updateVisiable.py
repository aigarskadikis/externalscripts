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

file = open("visiable.csv",'rb')
reader = csv.DictReader( file )

# take the file and read line by line
for line in reader:
 
 # check if this host exists in zabbix
 if zapi.host.get({"filter":{"host" :line['name']}}):
  print line['name'],"exists"

  
     # crete a host an put hostid instantly in the 'hostid' variable
#     hostid = zapi.host.create ({
 #       "host":line['name'],"interfaces":[{"type":2,"dns":"","main":1,"ip": line['address'],"port": 161,"useip": 1,}],
  #      "groups": [{ "groupid": group_id }],
   #     "proxy_hostid":proxy_id,
    #    "templates": [{ "templateid": template_id }]})['hostids']

 else:
   print line['name'],"not exist"

file.close()
