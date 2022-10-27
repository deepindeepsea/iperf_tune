#!/bin/bash

##THIS SCRIPT HAS BEEN MODIFIED FOR MULTEVENT COLLECTION.

#####################Script Variables#####################
DESIRED_ITERATIONS=${DESIRED_ITERATIONS:=3}
DEBUG_MESSAGE_PAUSE_TIME=1

##Local Host Corresponds to SUT
LOCAL_HOST=${LOCAL_HOST:="10.227.24.144"} #Onyx 7598 as of 1/7/2022

##Remote Host Corresponds to Ldgen
REMOTE_HOST=${REMOTE_HOST:="10.227.30.251"} # Ethanol 650d as of 1/7/2022

FIRST_RUN_AFTER_BOOT=TRUE  ##Set this to true the first time after a boot

#RUNTIME=430 # Duration to run iperf
RUNTIME=120 # Duration to run iperf


##iPerf3 Testing Network
ip_addr_link1b_local="192.168.2.2" #link1b IP local
ip_addr_link2b_local="192.168.4.2" #link2b IP Local
ip_addr_link1b_remote="192.168.2.3" #link1b IP remote
ip_addr_link2b_remote="192.168.4.3" #link2b IP remote

if [ $FIRST_RUN_AFTER_BOOT == TRUE ]; then
  bash ./set_nic_interfaces.sh 
  scp -r set_nic_interfaces.sh ${REMOTE_HOST}:/root
  ssh -p 22 root@${REMOTE_HOST} "bash ./set_nic_interfaces.sh"
fi
# Multevent command
RUN_MULTEVENT=0
MULTEVENT_TIME=$((RUNTIME-20))

###Relaxed Ordering At IOM####################
ARX write -n DF --register IOMConfig -b srcdncswrszanyppw --value 0x1
ssh root@${REMOTE_HOST} "ARX write -n DF --register IOMConfig -b srcdncswrszanyppw --value 0x1" || exit 1
#ARX write -n DF --register IOMControl -b FrcIomNoSdpRdRspRule --value 0x0
#ssh root@${REMOTE_HOST} "ARX write -n DF --register IOMControl -b FrcIomNoSdpRdRspRule --value 0x0" || exit 1

LOCAL_INI_DIR="/home/amd/asasikum/SWIFT/workloads/iniFiles"
LOCAL_MULTEVENT_CMD="MultEvent \
cpu \
-m 16 \
core --ini ${LOCAL_INI_DIR}/RS/PS_DG/ps_core_all.ini \
l3 --ini ${LOCAL_INI_DIR}/RS/PS_DG/DG_L3_v5.ini \
umc --ini ${LOCAL_INI_DIR}/RS/UMC/RS_umc_v1_SPGfix_subchannel.ini \
df -s 0 --ini ${LOCAL_INI_DIR}/RS/DF/df_stones_b0_multevent_files/df_rs_all.ini \
pcierx --ini ${LOCAL_INI_DIR}/RS/NBIO/RS_NBIO_PCIE_RXtile_v2.ini \
pcietx --ini ${LOCAL_INI_DIR}/RS/NBIO/RS_NBIO_PCIE_TXtile_v2.ini \
iohc --ini ${LOCAL_INI_DIR}/RS/NBIO/RS_NBIO_IOHC_all.ini  \
iommul2 --ini ${LOCAL_INI_DIR}/RS/NBIO/RS_NBIO_IOMMUL2_v3.ini \
iommul1pcie --ini ${LOCAL_INI_DIR}/RS/NBIO/RS_NBIO_IOMMU_L1PCIE_v3.ini \
-O ./ \
report -R -f 3 -l 1 \
-t ${MULTEVENT_TIME}"
REMOTE_INI_DIR="/home/amd/asasikum/SWIFT/workloads/iniFiles"
REMOTE_MULTEVENT_CMD="MultEvent \
cpu \
-m 16 \
core --ini ${REMOTE_INI_DIR}/RS/PS_DG/ps_core_all.ini \
l3 --ini ${REMOTE_INI_DIR}/RS/PS_DG/DG_L3_v5.ini \
umc --ini ${REMOTE_INI_DIR}/RS/UMC/RS_umc_v1_SPGfix_subchannel.ini \
df -s 0 --ini ${REMOTE_INI_DIR}/RS/DF/df_stones_b0_multevent_files/df_rs_all.ini \
pcierx --ini ${REMOTE_INI_DIR}/RS/NBIO/RS_NBIO_PCIE_RXtile_v2.ini \
pcietx --ini ${REMOTE_INI_DIR}/RS/NBIO/RS_NBIO_PCIE_TXtile_v2.ini \
iohc --ini ${REMOTE_INI_DIR}/RS/NBIO/RS_NBIO_IOHC_all.ini  \
iommul2 --ini ${REMOTE_INI_DIR}/RS/NBIO/RS_NBIO_IOMMUL2_v3.ini \
iommul1pcie --ini ${REMOTE_INI_DIR}/RS/NBIO/RS_NBIO_IOMMU_L1PCIE_v3.ini \
-O ./ \
report -R -f 3 -l 1 \
-t ${MULTEVENT_TIME}"

# Note: multevent GN core and l3 files have a problem with multevent version 3.0.13.1
#ARX write --namespace Core_X86_Msr --register ChL2RangeLock0 -b Lock --value 1 ; ARX write --namespace Core_X86_Msr --register ChL2RangeLock0 -b Enable --value 1
cpupower frequency-set -r -g performance
ssh -p 22 root@${REMOTE_HOST} "cpupower frequency-set -r -g performance"

###Comment the following three lines for MM######################
#/home/amd/fix_freq_aggressive_RS.sh
#scp /home/amd/fix_freq_aggressive_RS.sh ${REMOTE_HOST}:/home/amd/
#ssh -p 22 root@${REMOTE_HOST} "/home/amd/fix_freq_aggressive_RS.sh"
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
    REMOTE_MREPORT_LOG="/home/amd/asasikum/Manzi_iperf3_scripts/RS_Ldgen_mreport_${PREFIX}_iter_${i}"
    
    echo "Iteration ${i}: Pinning iperf processes to cores"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    
    
    
    
    
    echo "Iteration ${i}: ethtool & sysctl"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    
    killall -9 iperf3 ; rm /root/*remote_*
    ip addr flush link1b
    ip addr add ${ip_addr_link1b_local}/24 dev link1b
    ethtool -s link1b speed 200000 duplex full autoneg off
    ip addr flush link2b
    ip addr add ${ip_addr_link2b_local}/24 dev link2b
    ethtool -s link2b speed 200000 duplex full autoneg off
    systemctl start irqbalance
    echo "Iteration ${i}: SSH'ing into Ldgen & Configuring"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
   
    ssh -p 22 root@${REMOTE_HOST} "killall -9 iperf3 ; rm *remote_*"
    ssh -p 22 ${REMOTE_HOST} "ip addr flush link1b; ip addr add ${ip_addr_link1b_remote}/24 dev link1b"
    ssh -p 22 ${REMOTE_HOST} "ethtool -s link1b speed 200000 duplex full autoneg off"
    ssh -p 22 ${REMOTE_HOST} "ip addr flush link2b; ip addr add ${ip_addr_link2b_remote}/24 dev link2b"
    ssh -p 22 ${REMOTE_HOST} "ethtool -s link2b speed 200000 duplex full autoneg off"
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
    
    ssh -p 22 ${REMOTE_HOST} bash -c "'
    iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25000  >${ip_addr_link1b_remote}_remote_client_25000.out  &
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
    
    # Multevent section
    if [[ RUN_MULTEVENT -eq 1 ]]
    then
        echo "Multevent will be collected for this run" | tee -a ${OUTPUT_FILE}
        set -x
        ssh ${REMOTE_HOST} "${REMOTE_MULTEVENT_CMD}" &
        ${LOCAL_MULTEVENT_CMD}

        sleep $((RUNTIME - MULTEVENT_TIME + 5)) # Sleeping extra 5 seconds after the run
        mkdir "${LOCAL_MREPORT_LOG}"
        mv *csv* "${LOCAL_MREPORT_LOG}"
        ssh ${REMOTE_HOST} "mkdir -p ${REMOTE_MREPORT_LOG}; mv *csv* ${REMOTE_MREPORT_LOG}"
        scp -r ${REMOTE_HOST}:"${REMOTE_MREPORT_LOG}" .
        ssh ${REMOTE_HOST} "rm -rf ${REMOTE_MREPORT_LOG}"
        echo "Multevent collection done" | tee -a "${OUTPUT_FILE}"
        set +x
        sleep $((RUNTIME - MULTEVENT_TIME + 5)) # Sleeping extra 5 seconds after the run
    else
        sleep $((RUNTIME + 5)) # Sleeping extra 5 seconds after the run
    fi
    
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
