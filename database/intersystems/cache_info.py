#!/usr/bin/python

# Copyright: (c) 2019, Jameson Pugh <imntreal@gmail.com>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

ANSIBLE_METADATA = {
    'metadata_version': '1.1',
    'status': ['preview'],
    'supported_by': 'community'
}

DOCUMENTATION = '''
---
module: cache

short_description: Gathers information about Intersystems Cache' databases

version_added: "2.8"

description:
  - Gathers information about Intersystems Cache' databases.

options:
    get_facts:
        description:
            - Check for facts
        required: false

extends_documentation_fragment:
    - intersystems

author:
    - Jameson Pugh (@ImNtReal)
'''

EXAMPLES = '''
# Get Cache' facts
- name: Get Cache facts
  cache_info:
    get_facts: yes
'''

RETURN = '''
original_message:
    description: The original name param that was passed in
    type: str
    returned: always
message:
    description: The output message that the sample module generates
    type: str
    returned: always
'''

from ansible.module_utils.basic import *
from ansible.module_utils.facts import *
from subprocess import Popen, PIPE
import json

def get_instances():
    output = []
    pipe = Popen('ccontrol qlist', shell=True, stdout=PIPE)
    for line in pipe.stdout:
      output.append(str(line))
    return output

def main():
    # define available arguments/parameters a user can pass to the module
    module_args = dict(
        get_facts=dict(default='yes', required=False),
    )

    # the AnsibleModule object will be our abstraction working with Ansible
    # this includes instantiation, a couple of common attr would be the
    # args/params passed to the execution, as well as if the module
    # supports check mode
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    ansible_facts_dict = {
        "changed": False,
        "ansible_facts": { 
            "ansible_intersystems_cache": {}
        }
    }

    if module.params['get_facts'] == 'yes':
        instances = get_instances()
        ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'] = {}
        for instance in instances:
          inst_name = instance.split("^")[0]
          inst_dir = instance.split("^")[1]
          inst_ver = instance.split("^")[2]
          inst_status = instance.split("^")[3]
          inst_ss_port = instance.split("^")[5]
          inst_web_port = instance.split("^")[6]
          inst_state = instance.split("^")[8]
          inst_mir_type = instance.split("^")[10]
          inst_mir_status = instance.split("^")[11]
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'] = {}
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'][inst_name]['name'] = inst_name
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'][inst_name]['directory'] = inst_dir
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'][inst_name]['version'] = inst_ver
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'][inst_name]['status'] = inst_status
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'][inst_name]['superserver_port'] = inst_ss_port
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'][inst_name]['web_port'] = inst_web_port
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'][inst_name]['state'] = inst_state
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'][inst_name]['mirror_type'] = inst_mir_type
          ansible_facts_dict['ansible_facts']['ansible_intersystems_cache']['instances'][inst_name]['mirror_status'] = inst_mir_status

    # during the execution of the module, if there is an exception or a
    # conditional state that effectively causes a failure, run
    # AnsibleModule.fail_json() to pass in the message and the result
    #if module.params['name'] == 'fail me':
    #    module.fail_json(msg='You requested this to fail', **result)

    # in the event of a successful module execution, you will want to
    # simple AnsibleModule.exit_json(), passing the key/value results
    #module.exit_json(**result)
    module.exit_json(**ansible_facts_dict)

if __name__ == '__main__':
    main()
