#!/usr/bin/env python
import requests
import os
import sys
import json
from subprocess import Popen, PIPE


requests.packages.urllib3.disable_warnings()


def do_request(req, method, url, data=None):
    try:
        res = getattr(req, method)(url, data=data)
        if res.status_code == requests.codes.OK:
            return json.loads(res.text)
        else:
            sys.stderr.write(res.text)
    except Exception as e:
        sys.stderr.write(e)


if __name__ == '__main__':
    node_name = os.environ['NODE_NAME']
    endpoint = "https://%s" % os.environ['KUBERNETES_SERVICE_HOST']
    with open('/var/run/secrets/kubernetes.io/serviceaccount/token') as f:
        token = f.read().strip()
    url = '%s/api/v1/nodes/%s' % (endpoint, node_name)
    req = requests.Session()
    req.headers.update({'Authorization': 'Bearer %s' % token,
                        'Content-Type': 'application/merge-patch+json'})
    req.verify = False
    node_data = do_request(req, 'get', url)
    if node_data:
        node_data['spec']['unschedulable'] = False
        do_request(req, 'patch', url, json.dumps(node_data))

    # Resume the node for Slurm
    command = 'scontrol update NodeName=%s State=RESUME' % node_name
    p = Popen(command, stdout=PIPE, stderr=PIPE, shell=True)
    stdout, stderr = p.communicate()
    if stdout:
        sys.stdout.write(stdout)
    if stderr:
        sys.stderr.write(stderr)
