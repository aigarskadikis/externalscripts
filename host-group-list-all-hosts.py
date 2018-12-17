#!/usr/bin/env python

import os
import sys
from pprint import pprint
from pyzabbix import ZabbixAPI

# authorize in API
sys.path.insert(0,'/var/lib/zabbix')
import config
ZABBIX_SERVER = config.url
zapi = ZabbixAPI(ZABBIX_SERVER)
zapi.login(config.username, config.password)

# main program
hostgroup = sys.argv[1]
request=zapi.do_request('hostgroup.get',{"selectHosts":"extend","output": "extend","filter": { "name": [ hostgroup ] } })

for r in request["result"]:
 for host in r["hosts"]:
  print "Checking "+host["name"] + ' (hostid:' + host["hostid"]+") for template \"" +sys.argv[2] + "\""

  for t in zapi.host.get(selectParentTemplates=["templateid","name"],output='extend',hostids=host["hostid"]):
   for e in t["parentTemplates"]:
    if (str(e["name"]) == str(sys.argv[2])):
     print "TEMPLATE \""+ e["name"] +"\" (templateid:"+e["templateid"]+") will get unlinked from host \""+host["name"] +"\" (hostid:" + host["hostid"]+ ")\n"
     zapi.host.update(hostid=host["hostid"],templates_clear={'templateid':e["templateid"]})

