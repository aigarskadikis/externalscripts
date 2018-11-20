#!/bin/env python
from pyzabbix import ZabbixAPI
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.login(config.username, config.password)
result = zapi.proxy.get()
for elem in result:
  print elem['host']
