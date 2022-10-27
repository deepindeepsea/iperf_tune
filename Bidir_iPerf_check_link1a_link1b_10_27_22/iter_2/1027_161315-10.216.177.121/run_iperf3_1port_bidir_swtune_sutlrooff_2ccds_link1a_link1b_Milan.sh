#!/bin/bash

##THIS SCRIPT HAS BEEN MODIFIED FOR MULTEVENT COLLECTION.

#####################Script Variables#####################
#Note: still need to modify CPU pinnings in main body
DESIRED_ITERATIONS=${DESIRED_ITERATIONS:=3}
DEBUG_MESSAGE_PAUSE_TIME=1

##Local Host Corresponds to SUT
#LOCAL_HOST=${LOCAL_HOST:="10.228.88.29"} #Quartz-653f as of 1/7/2022
LOCAL_HOST=${LOCAL_HOST:="10.216.177.121"}


##Remote Host Corresponds to Ldgen
#REMOTE_HOST=${REMOTE_HOST:="10.228.89.9"} #ethx-a84a as of 1/7/2022
REMOTE_HOST=${REMOTE_HOST:="10.216.177.3"} #Milan as of 10/21/2022

#RUNTIME=430 # Duration to run iperf
RUNTIME=120 # Duration to run iperf

FIRST_RUN_AFTER_BOOT=TRUE  ##Set this to true the first time after a boot

##iPerf3 Testing Network
ip_addr_link1a_local="192.168.2.2" #link1a IP local
ip_addr_link1b_local="192.168.4.2" #link1b IP Local
ip_addr_link1a_remote="192.168.2.3" #link1a IP remote
ip_addr_link1b_remote="192.168.4.3" #link1b IP remote

if [ $FIRST_RUN_AFTER_BOOT == TRUE ]; then
  bash ./set_nic_interfaces.sh 
  scp -r set_nic_interfaces.sh ${REMOTE_HOST}:/root
  ssh -p 22 root@${REMOTE_HOST} "bash ./set_nic_interfaces.sh"
fi
# Multevent command
# Note: multevent GN core and l3 files have a problem with multevent version 3.0.13.1
#/home/amd/fix_freq_aggressive_RS.sh
cpupower frequency-set -r -g performance
ssh -p 22 root@${REMOTE_HOST} "cpupower frequency-set -r -g performance"
mst start
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
    OUTPUT_DIR=./Bidir_iPerf_check_link1a_link1b_10_27_22/iter_${i}/${PREFIX}
    #OUTPUT_DIR=./check_4_14_22/${PREFIX}
    LOCAL_MREPORT_LOG="RS_mreport_${PREFIX}"
    REMOTE_MREPORT_LOG="GN_mreport_${PREFIX}"
    
    echo "Iteration ${i}: Pinning iperf processes to cores"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    #Iperf pinning
    # Forwared direction
    SERVER_IFACE0_LOCAL_PIN="0-7"
    CLIENT_IFACE0_LOCAL_PIN="0-7"
    SERVER_IFACE0_REMOTE_PIN="0-7"
    CLIENT_IFACE0_REMOTE_PIN="0-7"
    

    SERVER_IFACE1_LOCAL_PIN="8-15"
    CLIENT_IFACE1_LOCAL_PIN="8-15"
    SERVER_IFACE1_REMOTE_PIN="8-15"
    CLIENT_IFACE1_REMOTE_PIN="8-15"
    
    echo "Iteration ${i}: ethtool & sysctl"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    #/opt/AMD/avt/AVT_Linux_Internal_2.7.19/AVTCMD -module pmm "cclk_control_force(2500)"
    
    killall -9 iperf3 ; rm *remote_*
    ip addr flush link1a
    ip addr add  ${ip_addr_link1a_local}/24 dev link1a
    ethtool -K link1a lro on
    ethtool -K link1a hw-tc-offload off
    ethtool -K link1a ntuple on
    ethtool -K link1a tx-nocache-copy off
    ethtool -G link1a rx 8192 tx 8192
    ethtool -s link1a speed 100000 duplex full autoneg off
    ethtool -L link1a combined 63
    ip link set link1a mtu 1500
    systemctl start irqbalance
    sleep 5
    systemctl stop irqbalance
    for f in /sys/class/net/link1a/queues/rx-*/rps_flow_cnt; do echo 1024 >"$f"; done
    bash /usr/sbin/set_irq_affinity_cpulist.sh "128-135" link1a >/dev/null
    
    ip addr flush link1b
    ip addr add  ${ip_addr_link1b_local}/24 dev link1b
    ethtool -K link1b lro on
    ethtool -K link1b hw-tc-offload off
    ethtool -K link1b ntuple on
    ethtool -K link1b tx-nocache-copy off
    ethtool -G link1b rx 8192 tx 8192
    ethtool -s link1b speed 100000 duplex full autoneg off
    ethtool -L link1b combined 63
    ip link set link1b mtu 1500
    sysctl -w net.core.rmem_max=212992
    sysctl -w net.core.wmem_max=212992
    sysctl -w net.core.rmem_default=212992
    sysctl -w net.core.wmem_default=212992
    sysctl -w net.core.netdev_max_backlog=25000
    sysctl -w net.core.busy_poll=50
    sysctl -w net.core.busy_read=50
    sysctl -w net.core.netdev_budget=300
    sysctl -w net.core.rps_sock_flow_entries=65536
    for f in /sys/class/net/link1b/queues/rx-*/rps_flow_cnt; do echo 1024 >"$f"; done
    bash /usr/sbin/set_irq_affinity_cpulist.sh "136-143" link1b >/dev/null
    
    
    echo "Iteration ${i}: SSH'ing into Ldgen & Configuring"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    ssh -p 22 root@${REMOTE_HOST} "killall -9 iperf3 ; rm *remote_*"
    ssh -p 22 ${REMOTE_HOST} "ip addr flush link1a; ip addr add ${ip_addr_link1a_remote}/24 dev link1a"
    ssh -p 22 ${REMOTE_HOST} "ethtool -K link1a lro on"
    ssh -p 22 ${REMOTE_HOST} "ethtool -K link1a hw-tc-offload off"
    ssh -p 22 ${REMOTE_HOST} "ethtool -K link1a ntuple on"
    ssh -p 22 ${REMOTE_HOST} "ethtool -K link1a tx-nocache-copy off"
    ssh -p 22 ${REMOTE_HOST} "ethtool -G link1a rx 8192 tx 8192"
    ssh -p 22 ${REMOTE_HOST} "ethtool -s link1a speed 100000 duplex full autoneg off"
    ssh -p 22 ${REMOTE_HOST} "ethtool -L link1a combined 63"
    ssh -p 22 ${REMOTE_HOST} "ip link set link1a mtu 1500"
    ssh -p 22 ${REMOTE_HOST} "for f in /sys/class/net/link1a/queues/rx-*/rps_flow_cnt; do echo 1024 > \$f; done"
    ssh -p 22 ${REMOTE_HOST} "systemctl start irqbalance"
    sleep 5
    ssh -p 22 ${REMOTE_HOST} "systemctl stop irqbalance"
    ssh -p 22 ${REMOTE_HOST} "/usr/sbin/set_irq_affinity_cpulist.sh \
    '128-135' link1a  >/dev/null"
    
    ssh -p 22 ${REMOTE_HOST} "ip addr flush link1b; ip addr add ${ip_addr_link1b_remote}/24 dev link1b"
    ssh -p 22 ${REMOTE_HOST} "ethtool -K link1b lro on"
    ssh -p 22 ${REMOTE_HOST} "ethtool -K link1b hw-tc-offload off"
    ssh -p 22 ${REMOTE_HOST} "ethtool -K link1b ntuple on"
    ssh -p 22 ${REMOTE_HOST} "ethtool -K link1b tx-nocache-copy off"
    ssh -p 22 ${REMOTE_HOST} "ethtool -G link1b rx 8192 tx 8192"
    ssh -p 22 ${REMOTE_HOST} "ethtool -s link1b speed 100000 duplex full autoneg off"
    ssh -p 22 ${REMOTE_HOST} "ethtool -L link1b combined 63"
    ssh -p 22 ${REMOTE_HOST} "ip link set link1b mtu 1500"
    ssh -p 22 ${REMOTE_HOST} "for f in /sys/class/net/link1b/queues/rx-*/rps_flow_cnt; do echo 1024 > \$f; done"
    ssh -p 22 ${REMOTE_HOST} "/usr/sbin/set_irq_affinity_cpulist.sh \
    '136-143' link1b  >/dev/null"
    ssh -p 22 ${REMOTE_HOST} "sysctl -w net.core.rmem_max=212992"
    ssh -p 22 ${REMOTE_HOST} "sysctl -w net.core.wmem_max=212992"
    ssh -p 22 ${REMOTE_HOST} "sysctl -w net.core.rmem_default=212992"
    ssh -p 22 ${REMOTE_HOST} "sysctl -w net.core.wmem_default=212992"
    ssh -p 22 ${REMOTE_HOST} "sysctl -w net.core.netdev_max_backlog=25000"
    ssh -p 22 ${REMOTE_HOST} "sysctl -w net.core.busy_poll=50"
    ssh -p 22 ${REMOTE_HOST} "sysctl -w net.core.busy_read=50"
    ssh -p 22 ${REMOTE_HOST} "sysctl -w net.core.netdev_budget=300"
    ssh -p 22 ${REMOTE_HOST} "sysctl -w net.core.rps_sock_flow_entries=65536"
    echo "Iteration ${i}: Results Directory Creation"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    # Check and create results directory
    if [ ! -d "${OUTPUT_DIR}" ]; then
        mkdir -p "${OUTPUT_DIR}"
    fi
    
    cp $0 "${OUTPUT_DIR}"
    cd "${OUTPUT_DIR}" || return
    sleep 1
    
    echo "Beginning of run at ${CURTIME}" | tee "${OUTPUT_FILE}"
    
    # Server creation
    ###############################################################################
    
    echo "Iteration ${i}: Server Creation & Numactl"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    echo "Starting servers:" | tee -a "${OUTPUT_FILE}"
    numactl -C ${SERVER_IFACE0_LOCAL_PIN} iperf3 --server --bind ${ip_addr_link1a_local} --port 25000 >${ip_addr_link1a_local}_local_server_25000.out &
    numactl -C ${SERVER_IFACE0_LOCAL_PIN} iperf3 --server --bind ${ip_addr_link1a_local} --port 25001 >${ip_addr_link1a_local}_local_server_25001.out &
    numactl -C ${SERVER_IFACE0_LOCAL_PIN} iperf3 --server --bind ${ip_addr_link1a_local} --port 25002 >${ip_addr_link1a_local}_local_server_25002.out &
    numactl -C ${SERVER_IFACE0_LOCAL_PIN} iperf3 --server --bind ${ip_addr_link1a_local} --port 25003 >${ip_addr_link1a_local}_local_server_25003.out &
                                        
    numactl -C ${SERVER_IFACE1_LOCAL_PIN} iperf3 --server --bind ${ip_addr_link1b_local} --port 25004 >${ip_addr_link1b_local}_local_server_25000.out &
    numactl -C ${SERVER_IFACE1_LOCAL_PIN} iperf3 --server --bind ${ip_addr_link1b_local} --port 25005 >${ip_addr_link1b_local}_local_server_25001.out &
    numactl -C ${SERVER_IFACE1_LOCAL_PIN} iperf3 --server --bind ${ip_addr_link1b_local} --port 25006 >${ip_addr_link1b_local}_local_server_25002.out &
    numactl -C ${SERVER_IFACE1_LOCAL_PIN} iperf3 --server --bind ${ip_addr_link1b_local} --port 25007 >${ip_addr_link1b_local}_local_server_25003.out &
    
    ssh -p 22 ${REMOTE_HOST} bash -c "'
    numactl -C ${SERVER_IFACE0_REMOTE_PIN} iperf3 --server --bind ${ip_addr_link1a_remote} --port 25000 >${ip_addr_link1a_remote}_remote_server_25000.out &
    numactl -C ${SERVER_IFACE0_REMOTE_PIN} iperf3 --server --bind ${ip_addr_link1a_remote} --port 25001 >${ip_addr_link1a_remote}_remote_server_25001.out &
    numactl -C ${SERVER_IFACE0_REMOTE_PIN} iperf3 --server --bind ${ip_addr_link1a_remote} --port 25002 >${ip_addr_link1a_remote}_remote_server_25002.out &
    numactl -C ${SERVER_IFACE0_REMOTE_PIN} iperf3 --server --bind ${ip_addr_link1a_remote} --port 25003 >${ip_addr_link1a_remote}_remote_server_25003.out &
                                        
    numactl -C ${SERVER_IFACE1_REMOTE_PIN} iperf3 --server --bind ${ip_addr_link1b_remote} --port 25004 >${ip_addr_link1b_remote}_remote_server_25000.out &
    numactl -C ${SERVER_IFACE1_REMOTE_PIN} iperf3 --server --bind ${ip_addr_link1b_remote} --port 25005 >${ip_addr_link1b_remote}_remote_server_25001.out &
    numactl -C ${SERVER_IFACE1_REMOTE_PIN} iperf3 --server --bind ${ip_addr_link1b_remote} --port 25006 >${ip_addr_link1b_remote}_remote_server_25002.out &
    numactl -C ${SERVER_IFACE1_REMOTE_PIN} iperf3 --server --bind ${ip_addr_link1b_remote} --port 25007 >${ip_addr_link1b_remote}_remote_server_25003.out &
    '" &
    sleep 5
    
    # Client creation
    ###############################################################################
    
    echo "Iteration ${i}: Client Creation & Numactl"
    sleep ${DEBUG_MESSAGE_PAUSE_TIME}
    
    
    echo "Starting clients " | tee -a "${OUTPUT_FILE}"
    numactl -C "${CLIENT_IFACE0_LOCAL_PIN}" iperf3 --client ${ip_addr_link1a_remote} --interval 10 --bind ${ip_addr_link1a_local} --time ${RUNTIME} --len=128K --port 25000 -Z >${ip_addr_link1a_local}_local_client_25000.out &
    numactl -C "${CLIENT_IFACE0_LOCAL_PIN}" iperf3 --client ${ip_addr_link1a_remote} --interval 10 --bind ${ip_addr_link1a_local} --time ${RUNTIME} --len=128K --port 25001 -Z >${ip_addr_link1a_local}_local_client_25001.out &
    numactl -C "${CLIENT_IFACE0_LOCAL_PIN}" iperf3 --client ${ip_addr_link1a_remote} --interval 10 --bind ${ip_addr_link1a_local} --time ${RUNTIME} --len=128K --port 25002 -Z >${ip_addr_link1a_local}_local_client_25002.out &
    numactl -C "${CLIENT_IFACE0_LOCAL_PIN}" iperf3 --client ${ip_addr_link1a_remote} --interval 10 --bind ${ip_addr_link1a_local} --time ${RUNTIME} --len=128K --port 25003 -Z >${ip_addr_link1a_local}_local_client_25003.out &
    
    numactl -C "${CLIENT_IFACE1_LOCAL_PIN}" iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25004 -Z >${ip_addr_link1b_local}_local_client_25000.out &
    numactl -C "${CLIENT_IFACE1_LOCAL_PIN}" iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25005 -Z >${ip_addr_link1b_local}_local_client_25001.out &
    numactl -C "${CLIENT_IFACE1_LOCAL_PIN}" iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25006 -Z >${ip_addr_link1b_local}_local_client_25002.out &
    numactl -C "${CLIENT_IFACE1_LOCAL_PIN}" iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25007 -Z >${ip_addr_link1b_local}_local_client_25003.out &
    
    ssh -p 22 ${REMOTE_HOST} bash -c "'
    numactl -C ${CLIENT_IFACE0_REMOTE_PIN} iperf3 --client ${ip_addr_link1a_local} --interval 10 --bind ${ip_addr_link1a_remote} --time ${RUNTIME} --len=128K --port 25000 -Z >${ip_addr_link1a_remote}_remote_client_25000.out &
    numactl -C ${CLIENT_IFACE0_REMOTE_PIN} iperf3 --client ${ip_addr_link1a_local} --interval 10 --bind ${ip_addr_link1a_remote} --time ${RUNTIME} --len=128K --port 25001 -Z >${ip_addr_link1a_remote}_remote_client_25001.out &
    numactl -C ${CLIENT_IFACE0_REMOTE_PIN} iperf3 --client ${ip_addr_link1a_local} --interval 10 --bind ${ip_addr_link1a_remote} --time ${RUNTIME} --len=128K --port 25002 -Z >${ip_addr_link1a_remote}_remote_client_25002.out &
    numactl -C ${CLIENT_IFACE0_REMOTE_PIN} iperf3 --client ${ip_addr_link1a_local} --interval 10 --bind ${ip_addr_link1a_remote} --time ${RUNTIME} --len=128K --port 25003 -Z >${ip_addr_link1a_remote}_remote_client_25003.out &

    numactl -C ${CLIENT_IFACE1_REMOTE_PIN} iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25004 -Z >${ip_addr_link1b_remote}_remote_client_25000.out &
    numactl -C ${CLIENT_IFACE1_REMOTE_PIN} iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25005 -Z >${ip_addr_link1b_remote}_remote_client_25001.out &
    numactl -C ${CLIENT_IFACE1_REMOTE_PIN} iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25006 -Z >${ip_addr_link1b_remote}_remote_client_25002.out &
    numactl -C ${CLIENT_IFACE1_REMOTE_PIN} iperf3 --client ${ip_addr_link1b_local} --interval 10 --bind ${ip_addr_link1b_remote} --time ${RUNTIME} --len=128K --port 25007 -Z >${ip_addr_link1b_remote}_remote_client_25003.out &
    '" &
    
    # Multevent section
    if [[ RUN_MULTEVENT -eq 1 ]]
    then
        echo "Multevent will be collected for this run" | tee -a ${OUTPUT_FILE}
        set -x
        ssh ${REMOTE_HOST} "${REMOTE_MULTEVENT_CMD}" &
        ${LOCAL_MULTEVENT_CMD}
        
        mkdir "${LOCAL_MREPORT_LOG}"
        mv *csv* "${LOCAL_MREPORT_LOG}"
        ssh ${REMOTE_HOST} "mreport -F ${REMOTE_INI_DIR}/GN/CB_BR/cb_core_all.ini Core_outfile*csv >mreport_core.csv"
        ssh ${REMOTE_HOST} "mreport -F ${REMOTE_INI_DIR}/GN/UMC/gn_umc_v10.ini UMC_outfile*csv >mreport_UMC.csv"
        ssh ${REMOTE_HOST} "mreport -F ${REMOTE_INI_DIR}/GN/CB_BR/BR_L3_v6.ini L3_outfile*csv >mreport_L3.csv"
        ssh ${REMOTE_HOST} "mreport -F ${REMOTE_INI_DIR}/GN/DF/GN_multevent_files/df_gn_all.ini DF_outfile*csv >mreport_DF.csv"
        ssh ${REMOTE_HOST} "mkdir ${REMOTE_MREPORT_LOG}; mv *csv* ${REMOTE_MREPORT_LOG}"
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

    local_bw_lines=$(cat *local_client* | grep receiver | grep -o -P "(?<=Bytes ).*(?= Gbits/sec)")

    local_bw=0
    for j in $local_bw_lines; do
        local_bw=$(echo $local_bw + "$j" | bc)
    done
    echo "Local Client(TX) Bandwidth: $local_bw Gbits/sec" | tee -a ${OUTPUT_FILE}
    remote_clients=$(cat *remote_client* | grep receiver | wc -l)
    echo "Calculating Remote B/W for $remote_clients clients" | tee -a ${OUTPUT_FILE}
    remote_bw_lines=$(cat *remote_client* | grep receiver | grep -o -P "(?<=Bytes ).*(?= Gbits/sec)")
    remote_bw=0
    for j in $remote_bw_lines; do
        remote_bw=$(echo $remote_bw + "$j" | bc)
    done
    echo "Remote Client(RX) Bandwidth: $remote_bw Gbits/sec" | tee -a ${OUTPUT_FILE}


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
grep "Total" iPerf3-1port_1C01Bios_Bidir_IRQ*/*/1port_Bidir_iter*out
exit 0
