#!/bin/python
from pprint import pprint
from pyzabbix import ZabbixAPI

#import credentials from external file
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(config.username, config.password)

# Get a list of all issues (AKA tripped triggers)
for hosts in zapi.hostgroup.get(output='extend',selectHosts='query'):
  # detects if array is empty
  if not hosts['hosts']:
    print hosts['name']

