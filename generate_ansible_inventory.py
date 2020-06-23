

import csv
import json
import copy
import os

inventory_csv_path = "data/inventory.csv"

inventory_dict = []
with open(inventory_csv_path, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        inventory_dict.append(row)

print("Input Inventory Contents:")
print(json.dumps(inventory_dict, indent=4))

if os.path.exists("data/hosts_inventory"):
  os.remove("data/hosts_inventory")

fin = open("data/hosts_inventory", 'a')

fin.write("[osda_server]\n") 
fin.write("OSDA    ansible_connection=local\n") 
fin.write("\n") 
fin.write("[OSDA_hosts]\n") 

for item in inventory_dict:
    inventory_entry = item['Management_IP1'] + '     ansible_connection=ssh        ansible_ssh_user=root ansible_ssh_pass="Welcome#123"\n'
    fin.write(inventory_entry)

fin.close()

print("Generated Ansible hosts inventory at path: " + "data/hosts_inventory")

