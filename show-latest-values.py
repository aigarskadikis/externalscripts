#!/usr/bin/python
# -*- coding: utf-8 -*-

from pyzabbix import ZabbixAPI, ZabbixAPIException

# import credentials from external file

import sys
sys.path.insert(0, '/var/lib/zabbix')
import config
# we will search latest very latest values
import time

# set current unixtime in varible and print it outloud
ctime = time.time()
print ctime

ZABBIX_SERVER = config.url

zapi = ZabbixAPI(ZABBIX_SERVER)

# Login to the Zabbix API
zapi.login(config.username, config.password)

var = zapi.history.get(
#			hostids=10084,
#			itemids=218992,
			history=3,
			time_from = ctime-600,
			time_till = ctime,
			filter={
				"itemid":"218992"
				}
			)

print var


