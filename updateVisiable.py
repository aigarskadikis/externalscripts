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
  print zapi.host.get ({"output":"hostid","filter":{"host":line['name']}})[0]['hostid']
 else:
  print line['name'],"not exist"

file.close()
