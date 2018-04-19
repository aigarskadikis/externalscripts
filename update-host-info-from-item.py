#!/usr/bin/python
"""
Shows a list of all current issues (AKA tripped triggers)
"""

#for argument support
import sys

#pip install pyzabbix
from pyzabbix import ZabbixAPI

#hostname at which the Zabbix web interface is available
ZABBIX_SERVER = 'http://localhost/zabbix'

zapi = ZabbixAPI(ZABBIX_SERVER)

#login to the Zabbix API
zapi.login('Admin', 'zabbix')

#query host id by parsing hostname as argument 1
hosts = zapi.host.get (
		output=['hostid'],
		filter={'host': sys.argv[1]})

#extract hostid from json string. host['hostid'] is array element with string identifier
for host in hosts:
	hostid = host['hostid']

#look for last value. key_ is the name of column. sysName is name of 'item key' in zabbix
items = zapi.item.get(                               
                hostids=hostid,
                output=['lastvalue'],
                filter={'key_':'sysName'})

#assign item lastvalue to dev_name
for item in items:
	dev_name = item['lastvalue']

#if nothing has assigned. if nothing kas placed in variable then python assigns 0 to it
if dev_name == '0':
	sys.exit("Sytem name not found !")

#get decription
items = zapi.item.get(                               
                hostids=hostid,
                output=['lastvalue'],
                filter={'key_':'sysDescr'})

#assign last value
for item in items:
        dev_desc = item['lastvalue']

items = zapi.item.get(                              
                hostids=hostid,
                output=['lastvalue'],
                filter={'key_':'sysLocation'})

#generate full description sentence
for item in items:
        dev_desc = 'Location: ' + item['lastvalue'] + '\n\n' + dev_desc


#update host 'Visible name' and 'Description'
zapi.do_request('host.update', {'hostid': hostid,'name': dev_name,'description': dev_desc})

