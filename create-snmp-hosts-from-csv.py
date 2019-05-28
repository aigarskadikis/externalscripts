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

file = open("test.csv",'rb')
reader = csv.DictReader( file )

# take the file and read line by line
for line in reader:
 
 # check if this host exists in zabbix
 #result = zapi.host.get({"filter":{"host" :line['name']}}) 
 if not zapi.host.get({"filter":{"host" :line['name']}}):
  print line['name'],"not yet registred"
  if zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}}):
   print line['proxy'],"is in the instance"
   proxy_id=zapi.proxy.get({"output": "proxyid","selectInterface": "extend","filter":{"host":line['proxy']}})[0]['proxyid']
   if proxy_id>0:
     print line['proxy'],"exists"
     print line['template']
     templates=line['template'].split(";")
     print templates
     groups=line['group'].split(";")
     print groups
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
     if len(templates)>1:
      # skip the first element in array
      for one_template in templates[1:]:
       print "t: ",one_template
       try:
        tid=zapi.template.get({"filter" : {"name" : one_template}})[0]['templateid']
        if tid:
          print "Temnplate:",one_template,"exist"
          # link new template
          try:
           nt=zapi.template.massadd({"templates":tid,"hosts":hostid})
          except Exception as nt:
           print "template",one_template,"probably already linked"
        else:
          print "Temnplate:",one_template,"does not exist"
       except Exception as tid:
        print("Temnplate:",one_template,"does not exist")

      for one_hostgroup in groups[1:]:
       print "g: ",one_hostgroup
       try:
        gid=zapi.hostgroup.get({"filter" : {"name" : one_hostgroup}})[0]['groupid']
        if gid:
          print "Group",one_hostgroup,"exist"
          # link new hostgroup
          try:
           nhg=zapi.hostgroup.massadd({"groups":gid,"hosts":hostid})
          except Exception as nhg:
           print "Hostgroup",one_hostgroup,"probably already linked"
        else:
          print "Hostgroup",one_hostgroup,"does not exist"
       except Exception as gid:
        print "Hostgroup",one_hostgroup,"does not exist"

   else:
    print "proxy id does not exist"

 else:
   print line['name'],"already exist"

file.close()
