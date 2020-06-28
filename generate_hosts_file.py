

import csv
import copy
import os

#inventory_csv_path = "./inventory.csv"
inventory_csv_path = "data/inventory_all.csv"


inventory_dict = []
with open(inventory_csv_path, newline='') as f:
    reader = csv.DictReader(f)
    for row in reader:
        inventory_dict.append(row)

print("Input Inventory Contents:")


if os.path.exists("data/hosts"):
  os.remove("data/hosts")

fin = open("data/hosts", 'a')

fin.write("127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4\n") 
fin.write("::1         localhost localhost.localdomain localhost6 localhost6.localdomain6\n") 
fin.write("\n") 
fin.write ("# WEKA hosts\n")

for item in inventory_dict:
    hosts_entry = "#" + item['Management_Hostname'] + "\n"
    fin.write(hosts_entry)
    hosts_entry = item['Management_IP1'] + "\t" + item['Management_Hostname'] + "\n"
    fin.write(hosts_entry)
    hosts_entry = item['IB_Interface_IP1'] + "\t" + item['IB_Hostname'] + "\n"
    fin.write(hosts_entry)

fin.close()

print("Generated Ansible hosts inventory at path: " + "data/hosts")

