#!/bin/env python
from pyzabbix import ZabbixAPI
import urllib3
from pprint import pprint
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.session.verify=False

zapi.login(config.username, config.password)

hostid=zapi.host.get({"output":"hostid","filter":{"host":"Zabbix server"}})[0]['hostid']

pprint(zapi.hostinterface.get(output=["dns","ip","useip"],selectHosts=["hosts"],filter={"main": 1, "type": 1},hostids=["10084"]))
