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

argument_count = len(sys.argv)
print 'arguments received = ' + str(argument_count-1)
destination_proxy_count = len(sys.argv)-2
print 'destination proxy count = ' + str(destination_proxy_count)

# look if every proxy exists. [1:] means to skip the first array element which is filename
for proxy in sys.argv[1:]:
	proxyid = zapi.proxy.get(
			output = ['proxyid'],
			filter={'host':proxy}
			)
	print proxyid

#calculate the source proxy ID
source_proxy = zapi.proxy.get(
                        output = ['proxyid'],
                        filter={'host':sys.argv[1]}
			)

for id in source_proxy:
	print sys.argv[1]+'='+id['proxyid']

	#get all hosts which belongs to proxy
	proxies = zapi.proxy.get(
				proxyids = id['proxyid'],
				selectHosts = 'extend'
				)
	for proxy in proxies:
		for idx,host in enumerate(proxy['hosts']):
			destination = idx % destination_proxy_count + 1
			print 'host with id:' + str(host['hostid']) + ' will be delivered to destination proxy ' + str(destination)

host_count_per_proxy = len(proxy['hosts'])
print 'houst count per proxy ' + sys.argv[1] + ' = ' + str(host_count_per_proxy)



