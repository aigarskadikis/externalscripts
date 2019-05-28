#!/usr/bin/env python
import csv
from zabbix_api import ZabbixAPI

server="http://127.0.0.1/"
username="Admin"
password="zabbix"

zapi = ZabbixAPI(server=server)
zapi.login(username, password)

file = open('hostgroups.txt', 'r')
list = file.read().splitlines()
file.close()

for group in list:
 print group
 zapi.hostgroup.create ({ "name":group }) 
