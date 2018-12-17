#!/usr/bin/env python

import os
import sys
from pprint import pprint
from pyzabbix import ZabbixAPI

sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.login(config.username, config.password)

hostgroup = sys.argv[1]
request=zapi.hostgroup.get(output='extend',selectHosts='extend',filter={'name': hostgroup})

for host in request:
 for h in host["hosts"]:
  print "Checking "+h["name"] + ' (hostid:' + h["hostid"]+") for template \"" +sys.argv[2] + "\""
  for t in zapi.host.get(selectParentTemplates=["templateid","name"],output='extend',hostids=h["hostid"]):
   for e in t["parentTemplates"]:
    if (str(e["name"]) == str(sys.argv[2])):
     print "TEMPLATE \""+ e["name"] +"\" (templateid:"+e["templateid"]+") will get unlinked from host \""+h["name"] +"\" (hostid:" + h["hostid"]+ ")\n"
     zapi.host.update(hostid=h["hostid"],templates_clear={'templateid':e["templateid"]})

