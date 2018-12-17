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

# gather all hosts which belongs to this host group
for host in request:
 for h in host["hosts"]:
  print "Checking "+h["name"] + ' (hostid:' + h["hostid"]+") for template \"" +sys.argv[2] + "\""

  # gather all templates regarding this host
  for t in zapi.host.get(selectParentTemplates=["templateid","name"],output='extend',hostids=h["hostid"]):
   for e in t["parentTemplates"]:

    # check if there is any template which match the first argument
    if (str(e["name"]) == str(sys.argv[2])):

     # if the the argument given match the template then print on screen what will get unlinked
     print "TEMPLATE \""+ e["name"] +"\" (templateid:"+e["templateid"]+") will get unlinked from host \""+h["name"] +"\" (hostid:" + h["hostid"]+ ")\n"
     
     # this is sensitive line. remove if want only test scenario
     zapi.host.update(hostid=h["hostid"],templates_clear={'templateid':e["templateid"]})

