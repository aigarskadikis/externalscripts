#!/usr/bin/python
import os
import sys
import json

extension = sys.argv[1]
logdir = sys.argv[2]


data = []

for (logdir, _, files) in os.walk(logdir):
    for f in files:
        if f.endswith(extension):
            path = os.path.join(logdir, f)
            data.append({'{#LOGFILEPATH}':path})
            jsondata = json.dumps(data)

print json.dumps({"data": data})

