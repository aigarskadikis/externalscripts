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
  try:
   proxy_id=zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}})[0]['proxyid']
   print line['template']
   templates=line['template'].split(";")
   groups=line['group'].split(";")
   # take first group from group array
   group_id = zapi.hostgroup.get({"filter" : {"name" : groups[0]}})[0]['groupid']
   # take first template from template array
   template_id = zapi.template.get({"filter" : {"name" : templates[0]}})[0]['templateid']
   # crete a host an put hostid instantly in the 'hostid' variable
   hostid = zapi.host.create ({
        "host":line['name'],"interfaces":[{"type":2,"dns":"","main":1,"ip": line['address'],"port": 161,"useip": 1,}],
        "groups": [{ "groupid": group_id }],
        "proxy_hostid":proxy_id,
        "templates": [{ "templateid": template_id }]})['hostids']
   # add additional templates
   for one_template in templates:
    id_of_template = zapi.template.get({"filter" : {"name" : one_template}})[0]['templateid']   
    try:
     print zapi.template.massadd({"templates":id_of_template,"hosts":hostid})
    except Exception as e:
     print str(e)
   for one_hostgroup in groups:
    id_of_hostgroup = zapi.hostgroup.get({"filter" : {"name" : one_hostgroup}})[0]['groupid']
    try:
     print zapi.hostgroup.massadd({"groups":id_of_hostgroup,"hosts":hostid})
    except Exception as e:
     print str(e)

  # proxy do not exist
  except Exception as e:
   print "proxy",line['proxy'],"does not exist"

 else:
   print line['name'],"already exist"

file.close()
