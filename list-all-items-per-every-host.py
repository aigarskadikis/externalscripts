#!/usr/bin/python
import sys
from pyzabbix import ZabbixAPI
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.login(config.username, config.password)
result = zapi.host.get(selectItems = ['itemid', 'name', 'key_'], selectTriggers = ['triggerid', 'description', 'expression'])
print(result)
