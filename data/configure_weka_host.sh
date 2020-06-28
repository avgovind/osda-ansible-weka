
INVENTORY_FILE=$1

if [ ! -f "$INVENTORY_FILE" ]; then
    echo "Missing argument for inventory file or specified inventory file does not exist"
    exit 2
fi


# Configure /etc/hosts from inventory file

# Take backup of /etc/hosts

date1=`date +"%m-%d-%Y"`
bkphostsfile=`echo "/etc/hosts"-$date1`

cp /etc/hosts $bkphostsfile

echo "127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4" > /etc/hosts
echo "::1         localhost localhost.localdomain localhost6 localhost6.localdomain6" >> /etc/hosts
echo "" >> /etc/hosts

while read line
do
    host1=`echo $line | awk -F, '{print $1}'`
    ip1=`echo $line | awk -F, '{print $2}'`
    ip2=`echo $line | awk -F, '{print $3}'`
    
    echo ${ip1}"    "${host1} >> /etc/hosts
#    echo ${ip2}"    "${host1} >> /etc/hosts

    ibhost1=`echo $line | awk -F, '{print $4}'`
    ibip1=`echo $line | awk -F, '{print $5}'`
    ibip2=`echo $line | awk -F, '{print $6}'`
    
    echo ${ibip1}"    "${ibhost1} >> /etc/hosts
#   echo ${ibip2}"    "${ibhost1} >> /etc/hosts

done < $INVENTORY_FILE


# NUMA Balancing Disablement
echo 0 > /proc/sys/kernel/numa_balancing

# Clock Synchronization

# Configure InfiniBand interfaces
HOSTNAME=`hostname`
IB_HOSTNAME=`grep $HOSTNAME $INVENTORY_FILE | awk -F, '{print $4}'`
IB_IP0=`grep $HOSTNAME $INVENTORY_FILE | awk -F, '{print $5}'`


IB_IFACE0=`ls /etc/sysconfig/network-scripts/ifcfg-ib* | sed -n '1 p'`
IB_IFACE1=`ls /etc/sysconfig/network-scripts/ifcfg-ib* | sed -n '2 p'`

IB_DEVICE0=`echo $IB_IFACE0 | awk -F- '{print $NF}'`
IB_DEVICE1=`echo $IB_IFACE1 | awk -F- '{print $NF}'`

#Empty current file first
>$IB_IFACE0

cat >> $IB_IFACE0 << EOL
TYPE=Infiniband
ONBOOT=yes
BOOTPROTO=static
STARTMODE=auto
USERCTL=no
NM_CONTROLLED=no
NETMASK=255.255.0.0
MTU=4092
DEVICE=${IB_DEVICE0}
IPADDR=${IB_IP0}
EOL

