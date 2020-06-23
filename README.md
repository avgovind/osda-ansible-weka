# osda-ansible-weka
Deploy WEKA IO clusters on HPE servers using Ansible and OSDA tool

Generate OSDA deploy JSON from input CSV file container server list:
```
# python3 generate_osda_json.py
```
The above script looks for "inventory.csv" file in the current directory.
This script needs a reference deploy JSON file with name "./deploy_template.json" which will be used as template to generate deploy JSON.

Generates the JSON file "data/deploy.json".

Generate Ansible inventory file:
```
python3 generate_hosts_inventory.py
```
The above script looks for "inventory.csv" file in the current directory.
This script needs a reference deploy JSON file with name "./deploy_template.json" which will be used as template to generate deploy JSON.

Generates the Ansible inventory file "data/hosts_inventory".

To deploy the CentOS hosts on the target baremetal servers run the ansible playbook using the following commandline:
```
# ansible-playbook -i inventory/OSDA osda_deploy_server.yml
```
The above playbook looks for 'deploy.json' file with deployment settings to be input to OSDA for OS deployment.

To install Weka software on all the hosts run the ansible playbook using the following commandline:
```
# ansible-playbook -i data/hosts_inventory master_weka_deploy.yml
```
