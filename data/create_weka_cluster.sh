
INVENTORY_FILE=$1

if [ ! -f "$INVENTORY_FILE" ]; then
    echo "Missing argument for inventory file or specified inventory file does not exist"
    exit 2
fi

# Generate list of hosts that are part of WEKA cluster
WEKA_HOSTS=""
WEKA_HOST_IPS=""

i=1
while read line
do
    # Skip the headers
    test $i -eq 1 && ((i=i+1)) && continue

    host1=`echo $line | awk -F, '{print $1}'`
    ibip1=`echo $line | awk -F, '{print $5}'`
    ibip2=`echo $line | awk -F, '{print $6}'`

    # space separated hostnames
    WEKA_HOSTS=`echo $WEKA_HOSTS $host1`
    # Comma separated IB interfaces
    if [ ! $WEKA_HOST_IPS ]; then
        WEKA_HOST_IPS=$ibip1
    else
        WEKA_HOST_IPS=`echo $WEKA_HOST_IPS,$ibip1`
    fi

done < $INVENTORY_FILE

# Run WEKA cluster create command only on the first host in the inventory
if [ `echo $WEKA_HOSTS | awk '{print $NR}'` = `hostname` ]; then
    # Stage 2: Formation of a Cluster from the Hosts
    weka cluster create $WEKA_HOSTS --host-ips $WEKA_HOST_IPS

    # Stage 3: Naming the Cluster
    weka cluster update --cluster-name=weka_on_apollo

    Stage 4: Enabling Cloud Event Notifications
    # weka cloud enable --cloud-url=

fi


# Stage 5: Setting hosts as dedicated to the cluster
weka cluster host dedicate

# Stage 6: Configuration of Networking

CURRENT_HOST=`hostname`
# get host id for current host
HOST_ID=`weka cluster host --no-header -o id,hostname | grep $CURRENT_HOST | awk '{print $2}'`

IB_IFACE0=`ls /etc/sysconfig/network-scripts/ifcfg-ib* | sed -n '1 p'`
IB_IFACE1=`ls /etc/sysconfig/network-scripts/ifcfg-ib* | sed -n '2 p'`

IB_DEVICE0=`echo $IB_IFACE0 | awk -F- '{print $NF}'`
IB_DEVICE1=`echo $IB_IFACE1 | awk -F- '{print $NF}'`

IB_IP0=`grep $CURRENT_HOST $INVENTORY_FILE | awk -F, '{print $5}'`
IB_IP1=`grep $CURRENT_HOST $INVENTORY_FILE | awk -F, '{print $6}'`

weka cluster host net add $HOST_ID $IB_DEVICE0 --ips-type=USER --ips=$IB_IP0
#weka cluster host net add $HOST_ID $IB_DEVICE1 --ips-type=USER --ips=$IB_IP1



# Stage 7: Configuration of NVMes
# Look for NVMe drives with largest size
SIZE=`lsblk -b -d -o NAME,SIZE,ROTA,TYPE -n | sort -n --key=2 | grep nvme | tail -n 1 | awk '{print $2}'`
DEVICES=`lsblk -b -d -o NAME,SIZE,ROTA,TYPE -n | grep $SIZE | grep nvme | awk '{print $1}'`

for DRIVE in $DEVICES; do
    weka cluster drive add $HOST_ID /dev/$DRIVE --force
done


# Stage 8: Scanning Drives
#weka cluster drive scan


# Stage 9: Configuration of CPU Resources
# weka cluster host cores <host-id> <cores> [--frontend-dedicated-cores <fe_cores>] [--drives-dedicated-cores <be_cores>] [--cores-ids <cores_ids>]

# the below command is for standard 24 core configuration
#weka cluster host cores $HOST_ID 19 --frontend-dedicated-cores 4 --drives-dedicated-cores 6 

# The below line is only for Houston lab
weka cluster host cores $HOST_ID 14 --frontend-dedicated-cores 1 --drives-dedicated-cores 6 


# Stage 10: Configuration of Memory 
## weka cluster host memory <host-id> <capacity-memory>

# Stage 14: Activation of Cluster Hosts
# weka cluster host activate [<host-ids>...]


# Stage 15: Activation of Cluster SSDs
# weka cluster drive activate [<uuids>...]


# Stage 16: Running the Start IO Command
#weka cluster start-io

