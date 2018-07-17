#!/bin/python
"""
Shows a list of all current issues (AKA tripped triggers)
"""

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

# get proxy info by name
result = zapi.proxy.get(
			output = ['proxyid'],
			filter={'host':sys.argv[1]}
			)
print result
