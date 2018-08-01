#!/bin/python
from pyzabbix import ZabbixAPI
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.login(config.username, config.password)

# set exception array
file = open('exceptional.hostgroups', 'r')
exception_list = file.read().splitlines()
file.close()

# use Zabbix API procedure hostgroup.get to get all hostgroups 
# +execute selectHosts query to get array of assigned hosts
for hosts in zapi.hostgroup.get(output='extend',selectHosts='query'):
  # detects if array is empty
  if not hosts['hosts']:
    # check if item is in list
    if hosts['name'] not in exception_list:
      # print the hostgroup name
      print hosts['name']
