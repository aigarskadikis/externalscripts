#!/usr/bin/env python

import sys
from datetime import datetime
import time
import logging
from pyzabbix import ZabbixAPI
import pprint
import re

# Zabbix Web Frontend page, you can define IP-address or use Domain Name:
zapi = ZabbixAPI("http://127.0.0.1/zabbix")
# Zabbix user credentials:
zapi.login("Admin", "zabbix")

# Get timestamps from 30 days back
start_time = int(time.time()) - 300000

# get tagged events
tagged_events=zapi.event.get(time_from = start_time, tags=[{'tag': 'autoclose_alert', 'value': '1', 'operator': 0}], output = ['eventid'])
for elem in tagged_events:
  print elem['eventid']
  events_closed = zapi.event.acknowledge(
    eventids = elem['eventid'],
    action = '1'
    )
  for events in events_closed:
    print events[0]


print '\nEvent ID of the 1st Unacknowledged event with status=PROBLEM'
print tagged_events

