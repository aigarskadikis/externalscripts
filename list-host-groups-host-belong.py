#!/usr/bin/env python
"""
show the groups where host belongs
"""

from pyzabbix import ZabbixAPI

#import credentials from external file
import sys
sys.path.insert(0,'/var/lib/zabbix')
import config

try:
    # The hostname at which the Zabbix web interface is available
    ZABBIX_SERVER = config.url
    zapi = ZabbixAPI(ZABBIX_SERVER)
    # Disable SSL certificate verification
    zapi.session.verify = False
    # Login to the Zabbix API
    zapi.login(config.username, config.password)
    hostname = sys.argv[1]
    groups = "Groups assigned to the " + hostname + ":"
    host = zapi.host.get(filter={"host": hostname},selectGroups = True)
    print groups
    for x in host[0]['groups']:
        print x['name']
    zapi.user.logout
except:
    print "No hostname defined"
