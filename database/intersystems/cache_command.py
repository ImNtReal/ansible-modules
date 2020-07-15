#!/usr/bin/python

# Copyright: (c) 2019, Jameson Pugh <imntreal@gmail.com>

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: cache_command

short_description: Runs a command on Intersystems Cache' database

version_added: "2.8"

description:
  - Runs a command on Intersystems Cache' database.

options:
  instance:
    description:
      - Instance to execute command in
    required: true
  namespace:
    description:
      - Namespace to execute command in
    required: false
    default: '%SYS'
  command:
    description:
      - Command to execute
    required: true

extends_documentation_fragment:
    - intersystems

author:
    - Jameson Pugh (@ImNtReal)
'''

EXAMPLES = '''
- name: Get path to CACHE database
  cache_command:
    instance: PRD
    command: w ^CONFIG("Databases","CACHE")
'''

RETURN = '''
command_result:
    description: Result of the command
    type: str
    returned: always
'''

from ansible.module_utils.basic import *
from ansible.module_utils.facts import *
from subprocess import Popen, PIPE
import json

def main():
  module = AnsibleModule(
    argument_spec={
      'instance': {'type': 'str', 'required': True},
      'namespace': {'default': '%SYS', 'required': False},
      'command': {'type': 'str', 'required': True},
    }
  )

  instance=module.params['instance']
  namespace=module.params['namespace']
  command=module.params['command']

  # the AnsibleModule object will be our abstraction working with Ansible
  # this includes instantiation, a couple of common attr would be the
  # args/params passed to the execution, as well as if the module
  # supports check mode



  output = []
  command_to_run = ('csession %s -U %s %s', (instance, namespace, command))
  try:
    pipe = Popen(command_to_run, shell=True, stdout=PIPE)
    for line in pipe.stdout:
      output.append(str(line))

  except Exception as e:
    module.fail_json(msg="Command failed.")

  results = {
    'changed': 'changed',
    'command_result': output,
  }

  # during the execution of the module, if there is an exception or a
  # conditional state that effectively causes a failure, run
  # AnsibleModule.fail_json() to pass in the message and the result
  #if module.params['name'] == 'fail me':
  #    module.fail_json(msg='You requested this to fail', **result)

  # in the event of a successful module execution, you will want to
  # simple AnsibleModule.exit_json(), passing the key/value results
  module.exit_json(**results)

if __name__ == '__main__':
  main()