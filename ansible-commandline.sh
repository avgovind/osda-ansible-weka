

python3.6 generate_osda_json.py data/inventory.csv
python3.6 generate_ansible_inventory.py data/inventory.csv

#ansible-playbook -i inventory/OSDA osda_deploy_server.yml

ansible-playbook -i data/hosts_inventory master_weka_deploy.yml
