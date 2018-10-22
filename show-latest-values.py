#!/usr/bin/python
# -*- coding: utf-8 -*-

from pyzabbix import ZabbixAPI, ZabbixAPIException

# import credentials from external file

import sys
sys.path.insert(0, '/var/lib/zabbix')
import config
# we will search latest very latest values
import time

ctime = time.time()
print ctime
# The hostname at which the Zabbix web interface is available

ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API

zapi.login(config.username, config.password)

# to get current timestamp in bash use 'date +%s'

#zapi.history.get(hostids=10084, itemids=218992, history=0, time_from=1540191853.0, time_till=1540192780.0, sortfield='clock', sortorder='ASC')
var = zapi.history.get(
			hostids=10084,
			itemids=218992,
			history=3,
			time_from = ctime-3600,
			time_till = ctime,
			filter={
				"itemid":"218992"
				}
			)

print var


#zapi.history.get(hostids=10350, itemids=46525, history=0, time_from=1538132400.0, time_till=1538136000.0, sortfield='clock', sortorder='ASC', filter={"itemid":"46525"})

