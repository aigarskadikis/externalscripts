#!/usr/bin/python
"""
Shows a list of all current issues (AKA tripped triggers)
"""

#for argument support
import sys
from pprint import pprint

#pip install pyzabbix
from pyzabbix import ZabbixAPI

#import api credentials from different file
sys.path.insert(0,'/var/lib/zabbix')
import config

# The hostname at which the Zabbix web interface is available
ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(config.username, config.password)

request=zapi.do_request('hostgroup.get', {
		"selectHosts":"extend", 
		"output": "extend",
		"filter": { "name": [ "Zabbix proxy" ] } })

##pprint(request)

for r in request["result"]:
##        print str(r) + '\n'
	for host in r["hosts"]:
		print host["name"] + ' with hostid ' + host["hostid"]
		
