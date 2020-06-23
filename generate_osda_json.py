

import csv
import json
import copy

inventory_csv_path = "data/inventory.csv"

# Template JSON file with all common settings and one host entry
# The host entry in the template will be used for generating entries for hosts 
# based on the input inventory CSV
input_json_template = "data/deploy_template.json"

#output_json_path = "./deploy.json"

inventory_dict = []
with open(inventory_csv_path, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        inventory_dict.append(row)

print("Input Inventory Contents:")
print(json.dumps(inventory_dict, indent=4))

fout = open(input_json_template, 'r')
json_template = json.load(fout)


hosts = []
for item in inventory_dict:
    host = copy.deepcopy(json_template['hosts'][0])
    host['iloIPAddr'] = item['iLO_IP']
    host['iloUser'] = item['ILO_User']
    host['iloPassword'] = item['ILO_Password']
    host['hostName'] = item['Management_Hostname']
    host['ipAddr'] = item['Management_IP1']
    hosts.append(host)

json_template['hosts'] = hosts

fin = open("data/deploy.json", 'w')
json.dump(json_template, fin, indent=4)

print("Generated OSDA deploy JSON with path: " + "output.json")

