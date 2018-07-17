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
proxyid = zapi.proxy.get(
			output = ['proxyid'],
			filter={'host':sys.argv[1]}
			)

for id in proxyid:
	print sys.argv[1]+'='+id['proxyid']

	#get all hosts which belongs to proxy
	hosts = zapi.proxy.get(
				proxyids = id['proxyid']
				)
	for h in hosts:
		print h
