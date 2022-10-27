#!/bin/bash

allowedDeviceModels="ConnectX-7\|ConnectX-6\|ConnectX-5"
abcList="a b c d e f g h i j k l m n o p q r s t u v w x y z"

################################################################################################

device=1
mellBusListAllowed=$(lspci | grep Mellanox | grep "$allowedDeviceModels" | cut -f1 -d' ')
mst start || echo "Error -- failed OFED installation."
(mlxcables || mst cable add ) > /dev/null
for busId in $mellBusListAllowed; do
  lastPciDigit=$(echo $busId | cut -f 2 -d .)
  if [ $lastPciDigit == 0 ]; then
    letter1=$(echo $abcList | awk '{print $1}')
    newIfaceName="link${device}${letter1}"
    interfInfoByBus=$(lshw -c network -businfo | grep $busId | awk '{print $2}')
    echo "Renaming (pci@${busId}): ${interfInfoByBus} to ${newIfaceName}" &
    ip addr flush dev $interfInfoByBus
    
    driverQuery=$(ethtool -i $interfInfoByBus | grep -i "driver:")
    fwQuery=$(ethtool -i $interfInfoByBus | grep -i "firmware-version:")
    echo "  $newIfaceName (pci@${busId}) --> [${driverQuery}][${fwQuery}]" &
    
    ip link set $interfInfoByBus down
    lnkStaQuery=$(lspci -s "$busId" -vv | grep "LnkSta:")
    echo "  $newIfaceName (pci@${busId}) --> ${lnkStaQuery}"
    lnkCapQuery=$(lspci -s "$busId" -vv | grep "LnkCap:")
    echo "  $newIfaceName (pci@${busId}) --> ${lnkCapQuery}"
    
    ip link set $interfInfoByBus name $newIfaceName
    ip link set $newIfaceName up &
    
    devIDQuery=$(cat /dev/mst/*pciconf* | grep -B 1 $busId | cut -f 1 -d' ')
    roQuery=$(mlxconfig -d $devIDQuery query | grep PCI_WR_ORDERING | awk '{print $2}')
    echo "  $newIfaceName (pci@${busId}) --> [dev: ${devIDQuery}][relaxed_order: ${roQuery}]"
  
  elif [ $lastPciDigit != 0 ]; then
    lastValue=10
    for i in $(seq 1 $lastValue); do
     if [ $lastPciDigit == $i ]; then
       letterN=$(echo $abcList | awk '{print $('$i'+1)}')
       newIfaceName="link${device}${letterN}"
       interfInfoByBus=$(lshw -c network -businfo | grep $busId | awk '{print $2}')
       echo "Renaming (pci@${busId}): ${interfInfoByBus} to ${newIfaceName}" &
       ip addr flush dev $interfInfoByBus

       driverQuery=$(ethtool -i $interfInfoByBus | grep -i "driver:")
       fwQuery=$(ethtool -i $interfInfoByBus | grep -i "firmware-version:")
       echo "  $newIfaceName (pci@${busId}) --> [${driverQuery}][${fwQuery}]" &
       
       ip link set $interfInfoByBus down
       lnkStaQuery=$(lspci -s "$busId" -vv | grep "LnkSta:")
       echo "  $newIfaceName (pci@${busId}) --> ${lnkStaQuery}"
       lnkCapQuery=$(lspci -s "$busId" -vv | grep "LnkCap:")
       echo "  $newIfaceName (pci@${busId}) --> ${lnkCapQuery}"
       
       ip link set $interfInfoByBus name $newIfaceName
       ip link set $newIfaceName up &&
       
       devIDQuery=$(cat /dev/mst/*pciconf* | grep -B 1 $busId | cut -f 1 -d' ')
       roQuery=$(mlxconfig -d $devIDQuery query | grep PCI_WR_ORDERING | awk '{print $2}')
       echo "  $newIfaceName (pci@${busId}) --> [dev: ${devIDQuery}][relaxed_Order: ${roQuery}]"
     elif [ $i == $lastValue ]; then
       ((device++))
     fi
    done
  else
    printf "Aborting: device ID does not end in a valid number."
    exit 1
  fi
done

if [[ $(printenv | grep REMOTE_HOST) == "" ]]; then
	echo "Please set LOCAL_HOST and REMOTE_HOST environmental variables:"
	echo "	e.g. export REMOTE_HOST="xxx.xx.xx.xx""
	echo "	e.g. export LOCAL_HOST="yyy.yy.yy.yy""
fi

exit 0
