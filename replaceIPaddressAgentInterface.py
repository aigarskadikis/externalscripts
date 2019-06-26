#!/bin/env python
from pyzabbix import ZabbixAPI
import urllib3
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.session.verify=False

zapi.login(config.username, config.password)

print zapi.host.get ({"output":"hostid","filter":{"host":"Zabbix server"}})[0]['hostid']
