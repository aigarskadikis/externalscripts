#!/bin/python
from pyzabbix import ZabbixAPI
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.login(config.username, config.password)

# use Zabbix API procedure hostgroup.get to get all hostgroups 
# +execute selectHosts query to get array of assigned hosts
for hosts in zapi.hostgroup.get(output='extend',selectHosts='query'):
  # detects if array is empty
  if not hosts['hosts']:
    # go through exceptional file line by line and compare the host groups
    file = open('exceptional.groups', 'r')
    if not file.read().find(hosts['name']):
      print '['+hosts['name']+']'+' is an exception'
    else:
      print hosts['groupid']+','+hosts['name']
    file.close()
