#!/bin/bash

##THIS SCRIPT HAS BEEN MODIFIED FOR MULTEVENT COLLECTION.

#####################Script Variables#####################
DESIRED_ITERATIONS=${DESIRED_ITERATIONS:=1}
DEBUG_MESSAGE_PAUSE_TIME=1

##Local Host Corresponds to SUT
LOCAL_HOST=${LOCAL_HOST:="10.216.177.121"} #Ethanol

##Remote Host Corresponds to Ldgen
REMOTE_HOST=${REMOTE_HOST:="10.216.177.86"} # Ruby2

FIRST_RUN_AFTER_BOOT=TRUE  ##Set this to true the first time after a boot

#RUNTIME=430 # Duration to run iperf
RUNTIME=120 # Duration to run iperf


##iPerf3 Testing Network
ip_addr_link1b_local="192.168.2.2" #link1b IP local
ip_addr_link2b_local="192.168.4.2" #link2b IP Local
ip_addr_link1b_remote="192.168.2.3" #link1b IP remote
ip_addr_link2b_remote="192.168.4.3" #link2b IP remote
<<com
if [ $FIRST_RUN_AFTER_BOOT == TRUE ]; then
  bash ./set_nic_interfaces.sh 
  scp -r set_nic_interfaces.sh ${REMOTE_HOST}:/root
  ssh -p 22 root@${REMOTE_HOST} "bash ./set_nic_interfaces.sh"
fi
com
#################Program Start (Main Body)#################
for i in $(seq 1 ${DESIRED_ITERATIONS})
do
    echo "Iteration ${i}: Starting iteration."
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    CURTIME=$(date +"%m%d_%H%M%S")
    
    echo "Iteration ${i}: File Directory Setup"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    # File and directory setup
    PREFIX=${CURTIME}-${LOCAL_HOST}
    OUTPUT_FILE=1port_Bidir_iter${i}.out
    #OUTPUT_DIR=./bidir_iPerf_FF2.5_OOB_wo_ME_Cstates_dis_7_13_2022/iter_${i}/${PREFIX}/
    OUTPUT_DIR=./OOB_MM_woZcpy_16TXRX_per_NIC_no-atlas_wo_ME_re-installed_drivers_8_16_2022/iter_${i}/${PREFIX}/
    LOCAL_MREPORT_LOG="RS_SUT_mreport_${PREFIX}_iter${i}"
    REMOTE_MREPORT_LOG="/home/amd/iperf/RS_Ldgen_mreport_${PREFIX}_iter_${i}"
    
    echo "Iteration ${i}: Pinning iperf processes to cores"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    
    
    
    
    
    echo "Iteration ${i}: ethtool & sysctl"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    
    killall -9 iperf3 ; rm /root/*remote_*
    ip addr flush link1a
    ip addr add ${ip_addr_link1b_local}/24 dev link1a
    ethtool -s link1a speed 100000 duplex full autoneg off
    ip addr flush link1b
    ip addr add ${ip_addr_link2b_local}/24 dev link1b
    ethtool -s link1b speed 100000 duplex full autoneg off
    systemctl start irqbalance
    echo "Iteration ${i}: SSH'ing into Ldgen & Configuring"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
   
    ssh -p 22 root@${REMOTE_HOST} "killall -9 iperf3 ; rm *remote_*"
    ssh -p 22 ${REMOTE_HOST} "ip addr flush link1a; ip addr add ${ip_addr_link1b_remote}/24 dev link1a"
    ssh -p 22 ${REMOTE_HOST} "ethtool -s link1a speed 100000 duplex full autoneg off"
    ssh -p 22 ${REMOTE_HOST} "ip addr flush link1b; ip addr add ${ip_addr_link2b_remote}/24 dev link1b"
    ssh -p 22 ${REMOTE_HOST} "ethtool -s link1b speed 100000 duplex full autoneg off"
    ssh -p 22 ${REMOTE_HOST} "systemctl start irqbalance"
    
    echo "Iteration ${i}: Results Directory Creation"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    # Check and create results directory
    if [ ! -d "${OUTPUT_DIR}" ]; then
        mkdir -p "${OUTPUT_DIR}"
    fi
    
    cd "${OUTPUT_DIR}" || return
    sleep 1
    
    echo "Beginning of run at ${CURTIME}" | tee "${OUTPUT_FILE}"
    
    # Server creation
    ###############################################################################
    
    echo "Iteration ${i}: Server Creation & Numactl"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    echo "Starting servers:" | tee -a "${OUTPUT_FILE}"
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25000 >${ip_addr_link1b_local}_local_server_25000.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25001 >${ip_addr_link1b_local}_local_server_25001.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25002 >${ip_addr_link1b_local}_local_server_25002.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25003 >${ip_addr_link1b_local}_local_server_25003.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25004 >${ip_addr_link1b_local}_local_server_25004.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25005 >${ip_addr_link1b_local}_local_server_25005.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25006 >${ip_addr_link1b_local}_local_server_25006.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25007 >${ip_addr_link1b_local}_local_server_25007.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25008 >${ip_addr_link1b_local}_local_server_25008.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25009 >${ip_addr_link1b_local}_local_server_25009.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25010 >${ip_addr_link1b_local}_local_server_25010.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25011 >${ip_addr_link1b_local}_local_server_25011.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25012 >${ip_addr_link1b_local}_local_server_25012.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25013 >${ip_addr_link1b_local}_local_server_25013.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25014 >${ip_addr_link1b_local}_local_server_25014.out &
    iperf3 --server --bind ${ip_addr_link1b_local} --port 25015 >${ip_addr_link1b_local}_local_server_25015.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25000 >${ip_addr_link2b_local}_local_server_25000.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25001 >${ip_addr_link2b_local}_local_server_25001.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25002 >${ip_addr_link2b_local}_local_server_25002.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25003 >${ip_addr_link2b_local}_local_server_25003.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25004 >${ip_addr_link2b_local}_local_server_25004.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25005 >${ip_addr_link2b_local}_local_server_25005.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25006 >${ip_addr_link2b_local}_local_server_25006.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25007 >${ip_addr_link2b_local}_local_server_25007.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25008 >${ip_addr_link2b_local}_local_server_25008.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25009 >${ip_addr_link2b_local}_local_server_25009.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25010 >${ip_addr_link2b_local}_local_server_25010.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25011 >${ip_addr_link2b_local}_local_server_25011.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25012 >${ip_addr_link2b_local}_local_server_25012.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25013 >${ip_addr_link2b_local}_local_server_25013.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25014 >${ip_addr_link2b_local}_local_server_25014.out &
    iperf3 --server --bind ${ip_addr_link2b_local} --port 25015 >${ip_addr_link2b_local}_local_server_25015.out &
    
    
    
    ssh -p 22 ${REMOTE_HOST} bash -c "'
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25000 >${ip_addr_link1b_remote}_remote_server_25000.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25001 >${ip_addr_link1b_remote}_remote_server_25001.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25002 >${ip_addr_link1b_remote}_remote_server_25002.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25003 >${ip_addr_link1b_remote}_remote_server_25003.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25004 >${ip_addr_link1b_remote}_remote_server_25004.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25005 >${ip_addr_link1b_remote}_remote_server_25005.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25006 >${ip_addr_link1b_remote}_remote_server_25006.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25007 >${ip_addr_link1b_remote}_remote_server_25007.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25008 >${ip_addr_link1b_remote}_remote_server_25008.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25009 >${ip_addr_link1b_remote}_remote_server_25009.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25010 >${ip_addr_link1b_remote}_remote_server_25010.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25011 >${ip_addr_link1b_remote}_remote_server_25011.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25012 >${ip_addr_link1b_remote}_remote_server_25012.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25013 >${ip_addr_link1b_remote}_remote_server_25013.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25014 >${ip_addr_link1b_remote}_remote_server_25014.out &
    iperf3 --server --bind ${ip_addr_link1b_remote} --port 25015 >${ip_addr_link1b_remote}_remote_server_25015.out &
    
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25000 >${ip_addr_link2b_remote}_remote_server_25000.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25001 >${ip_addr_link2b_remote}_remote_server_25001.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25002 >${ip_addr_link2b_remote}_remote_server_25002.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25003 >${ip_addr_link2b_remote}_remote_server_25003.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25004 >${ip_addr_link2b_remote}_remote_server_25004.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25005 >${ip_addr_link2b_remote}_remote_server_25005.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25006 >${ip_addr_link2b_remote}_remote_server_25006.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25007 >${ip_addr_link2b_remote}_remote_server_25007.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25008 >${ip_addr_link2b_remote}_remote_server_25008.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25009 >${ip_addr_link2b_remote}_remote_server_25009.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25010 >${ip_addr_link2b_remote}_remote_server_25010.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25011 >${ip_addr_link2b_remote}_remote_server_25011.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25012 >${ip_addr_link2b_remote}_remote_server_25012.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25013 >${ip_addr_link2b_remote}_remote_server_25013.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25014 >${ip_addr_link2b_remote}_remote_server_25014.out &
    iperf3 --server --bind ${ip_addr_link2b_remote} --port 25015 >${ip_addr_link2b_remote}_remote_server_25015.out &
    '" &
    sleep 5
    
    # Client creation
    ###############################################################################
    
    echo "Iteration ${i}: Client Creation & Numactl"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    
    echo "Starting clients " | tee -a "${OUTPUT_FILE}"
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25000  >${ip_addr_link1b_local}_local_client_25000.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25001  >${ip_addr_link1b_local}_local_client_25001.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25002  >${ip_addr_link1b_local}_local_client_25002.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25003  >${ip_addr_link1b_local}_local_client_25003.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25004  >${ip_addr_link1b_local}_local_client_25004.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25005  >${ip_addr_link1b_local}_local_client_25005.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25006  >${ip_addr_link1b_local}_local_client_25006.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25007  >${ip_addr_link1b_local}_local_client_25007.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25008  >${ip_addr_link1b_local}_local_client_25008.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25009  >${ip_addr_link1b_local}_local_client_25009.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25010  >${ip_addr_link1b_local}_local_client_25010.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25011  >${ip_addr_link1b_local}_local_client_25011.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25012  >${ip_addr_link1b_local}_local_client_25012.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25013  >${ip_addr_link1b_local}_local_client_25013.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25014  >${ip_addr_link1b_local}_local_client_25014.out &
    iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25015  >${ip_addr_link1b_local}_local_client_25015.out &
    
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25000  >${ip_addr_link2b_local}_local_client_25000.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25001  >${ip_addr_link2b_local}_local_client_25001.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25002  >${ip_addr_link2b_local}_local_client_25002.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25003  >${ip_addr_link2b_local}_local_client_25003.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25004  >${ip_addr_link2b_local}_local_client_25004.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25005  >${ip_addr_link2b_local}_local_client_25005.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25006  >${ip_addr_link2b_local}_local_client_25006.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25007  >${ip_addr_link2b_local}_local_client_25007.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25008  >${ip_addr_link2b_local}_local_client_25008.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25009  >${ip_addr_link2b_local}_local_client_25009.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25010  >${ip_addr_link2b_local}_local_client_25010.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25011  >${ip_addr_link2b_local}_local_client_25011.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25012  >${ip_addr_link2b_local}_local_client_25012.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25013  >${ip_addr_link2b_local}_local_client_25013.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25014  >${ip_addr_link2b_local}_local_client_25014.out &
    iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25015  >${ip_addr_link2b_local}_local_client_25015.out &
com
 echo "test-1"

<<com
    ssh -p 22 ${REMOTE_HOST} bash -c "'
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25000  >${ip_addr_link1b_remote}_remote_client_25000.out  &
    '" &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25001  >${ip_addr_link1b_remote}_remote_client_25001.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25002  >${ip_addr_link1b_remote}_remote_client_25002.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25003  >${ip_addr_link1b_remote}_remote_client_25003.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25004  >${ip_addr_link1b_remote}_remote_client_25004.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25005  >${ip_addr_link1b_remote}_remote_client_25005.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25006  >${ip_addr_link1b_remote}_remote_client_25006.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25007  >${ip_addr_link1b_remote}_remote_client_25007.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25008  >${ip_addr_link1b_remote}_remote_client_25008.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25009  >${ip_addr_link1b_remote}_remote_client_25009.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25010  >${ip_addr_link1b_remote}_remote_client_25010.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25011  >${ip_addr_link1b_remote}_remote_client_25011.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25012  >${ip_addr_link1b_remote}_remote_client_25012.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25013  >${ip_addr_link1b_remote}_remote_client_25013.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25014  >${ip_addr_link1b_remote}_remote_client_25014.out  &
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25015  >${ip_addr_link1b_remote}_remote_client_25015.out  &

    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25000  >${ip_addr_link2b_remote}_remote_client_25000.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25001  >${ip_addr_link2b_remote}_remote_client_25001.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25002  >${ip_addr_link2b_remote}_remote_client_25002.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25003  >${ip_addr_link2b_remote}_remote_client_25003.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25004  >${ip_addr_link2b_remote}_remote_client_25004.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25005  >${ip_addr_link2b_remote}_remote_client_25005.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25006  >${ip_addr_link2b_remote}_remote_client_25006.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25007  >${ip_addr_link2b_remote}_remote_client_25007.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25008  >${ip_addr_link2b_remote}_remote_client_25008.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25009  >${ip_addr_link2b_remote}_remote_client_25009.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25010  >${ip_addr_link2b_remote}_remote_client_25010.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25011  >${ip_addr_link2b_remote}_remote_client_25011.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25012  >${ip_addr_link2b_remote}_remote_client_25012.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25013  >${ip_addr_link2b_remote}_remote_client_25013.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25014  >${ip_addr_link2b_remote}_remote_client_25014.out  &
    iperf3 --client ${ip_addr_link2b_local} --interval 10 --bind ${ip_addr_link2b_remote} --time ${RUNTIME} --len=128K --port 25015  >${ip_addr_link2b_remote}_remote_client_25015.out  &
    '" &
com 
    
    ssh -p 22 ${REMOTE_HOST} "ps -ef | grep iperf"
    echo "Iperf test is done"
    
    
    echo "copy remote results" | tee -a ${OUTPUT_FILE}
    scp ${REMOTE_HOST}:*remote_* .
    ssh ${REMOTE_HOST} "rm *remote_*"
    
    #############################################################
    #                RESULTS PROCESSING SECTION                 #
    #############################################################
    echo "process results" | tee -a "${OUTPUT_FILE}"
    grep receiver *client* | tee -a "${OUTPUT_FILE}"
    local_clients=$(cat *local_client* | grep receiver | wc -l)
    echo "Calculating local B/W for $local_clients local clients" | tee -a ${OUTPUT_FILE}
    
    link1b_local_bw_lines=$(cat $ip_addr_link1b_local*local_client* | grep receiver | grep -o -P "(?<=Bytes ).*(?= Gbits/sec)")
    link1b_local_bw=0
    for j in $link1b_local_bw_lines; do
        link1b_local_bw=$(echo $link1b_local_bw + "$j" | bc)
    done
    echo "Link1b Local Client(TX) Bandwidth: $link1b_local_bw Gbits/sec" | tee -a ${OUTPUT_FILE}

    link2b_local_bw_lines=$(cat $ip_addr_link2b_local*local_client* | grep receiver | grep -o -P "(?<=Bytes ).*(?= Gbits/sec)")
    link2b_local_bw=0
    for j in $link2b_local_bw_lines; do
        link2b_local_bw=$(echo $link2b_local_bw + "$j" | bc)
    done
    echo "Link2b Local Client(TX) Bandwidth: $link2b_local_bw Gbits/sec" | tee -a ${OUTPUT_FILE}
    
    local_bw_lines=$(cat *local_client* | grep receiver | grep -o -P "(?<=Bytes ).*(?= Gbits/sec)")
    local_bw=0
    for j in $local_bw_lines; do
        local_bw=$(echo $local_bw + "$j" | bc)
    done
    echo "Total Local Client(TX) Bandwidth: $local_bw Gbits/sec" | tee -a ${OUTPUT_FILE}
    
    remote_clients=$(cat *remote_client* | grep receiver | wc -l)
    echo "Calculating Remote B/W for $remote_clients clients" | tee -a ${OUTPUT_FILE}

    link1b_remote_bw_lines=$(cat $ip_addr_link1b_remote*remote_client* | grep receiver | grep -o -P "(?<=Bytes ).*(?= Gbits/sec)")
    link1b_remote_bw=0
    for j in $link1b_remote_bw_lines; do
        link1b_remote_bw=$(echo $link1b_remote_bw + "$j" | bc)
    done
    echo "Link1b Remote Client(RX) Bandwidth: $link1b_remote_bw Gbits/sec" | tee -a ${OUTPUT_FILE}

    link2b_remote_bw_lines=$(cat $ip_addr_link2b_remote*remote_client* | grep receiver | grep -o -P "(?<=Bytes ).*(?= Gbits/sec)")
    link2b_remote_bw=0
    for j in $link2b_remote_bw_lines; do
        link2b_remote_bw=$(echo $link2b_remote_bw + "$j" | bc)
    done
    echo "Link2b Remote Client(RX) Bandwidth: $link2b_remote_bw Gbits/sec" | tee -a ${OUTPUT_FILE}

    remote_bw_lines=$(cat *remote_client* | grep receiver | grep -o -P "(?<=Bytes ).*(?= Gbits/sec)")
    remote_bw=0
    for j in $remote_bw_lines; do
        remote_bw=$(echo $remote_bw + "$j" | bc)
    done
    echo "Total Remote Client(RX) Bandwidth: $remote_bw Gbits/sec" | tee -a ${OUTPUT_FILE}


    total_clients=$(cat *client* | grep receiver | wc -l)
    echo "Calculating total B/W for $total_clients clients" | tee -a ${OUTPUT_FILE}
    
    bw_lines=$(cat *client* | grep receiver | grep -o -P "(?<=Bytes ).*(?= Gbits/sec)")
    
    total_bw=0
    for j in $bw_lines; do
        total_bw=$(echo $total_bw + "$j" | bc)
    done
    echo "Total Bandwidth: $total_bw Gbits/sec" | tee -a ${OUTPUT_FILE}
    
    cd - || return
    echo "Iteration ${i}: Stopping iteration."
    sleep 5
    
done #this done correspond's to main body loop
exit 0
