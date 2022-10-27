#!/bin/bash
RUNTIME=120
ip_addr_link1b_local="192.168.2.2" #link1b IP local
ip_addr_link1a_local="192.168.2.2" #link1b IP local
ip_addr_link2b_local="192.168.4.2" #link2b IP Local
ip_addr_link2a_local="192.168.4.2" #link2b IP Local
ip_addr_link2b_remote="192.168.2.3" #link1b IP remote
ip_addr_link2a_remote="192.168.2.3" #link1b IP remote
ip_addr_link1b_remote="192.168.4.3" #link2b IP remote
ip_addr_link1a_remote="192.168.4.3" #link2b IP remote

#ifconfig link1a 192.168.2.2 up
#ifconfig link1b 192.168.4.2 up

SERVER_IFACE0_LOCAL_PIN="0-7"
SERVER_IFACE1_LOCAL_PIN="8-15"
#CLIENT_IFACE0_LOCAL_PIN="0-7"
#CLIENT_IFACE1_LOCAL_PIN="8-15"

 echo "Starting client:" 
    numactl -C $SERVER_IFACE0_LOCAL_PIN iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25000  -Z >${ip_addr_link1b_local}_local_client_25000.out &
    numactl -C $SERVER_IFACE0_LOCAL_PIN iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25001  -Z >${ip_addr_link1b_local}_local_client_25001.out &
    numactl -C $SERVER_IFACE0_LOCAL_PIN iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25002  -Z >${ip_addr_link1b_local}_local_client_25002.out &
    numactl -C $SERVER_IFACE0_LOCAL_PIN iperf3 --client ${ip_addr_link1b_remote} --interval 10 --bind ${ip_addr_link1b_local} --time ${RUNTIME} --len=128K --port 25003  -Z >${ip_addr_link1b_local}_local_client_25003.out &
    numactl -C $SERVER_IFACE1_LOCAL_PIN iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25000  -Z >${ip_addr_link2b_local}_local_client_25000.out &
    numactl -C $SERVER_IFACE1_LOCAL_PIN iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25001  -Z >${ip_addr_link2b_local}_local_client_25001.out &
    numactl -C $SERVER_IFACE1_LOCAL_PIN iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25002  -Z >${ip_addr_link2b_local}_local_client_25002.out &
    numactl -C $SERVER_IFACE1_LOCAL_PIN iperf3 --client ${ip_addr_link2b_remote} --interval 10 --bind ${ip_addr_link2b_local} --time ${RUNTIME} --len=128K --port 25003  -Z >${ip_addr_link2b_local}_local_client_25003.out &

#
 #  numactl -C "$CLIENT_IFACE0_LOCAL_PIN" iperf3 --client ${ip_addr_link1a_remote} --interval 10 --bind ${ip_addr_link1a_local} --time ${RUNTIME} --len=128K --port 25004 -Z >${ip_addr_link1a_local}_local_client_25004.out &
 #   numactl -C "$CLIENT_IFACE0_LOCAL_PIN" iperf3 --client ${ip_addr_link1a_remote} --interval 10 --bind ${ip_addr_link1a_local} --time ${RUNTIME} --len=128K --port 25005 -Z >${ip_addr_link1a_local}_local_client_25005.out &
#    numactl -C "$CLIENT_IFACE0_LOCAL_PIN" iperf3 --client ${ip_addr_link1a_remote} --interval 10 --bind ${ip_addr_link1a_local} --time ${RUNTIME} --len=128K --port 25006 -Z >${ip_addr_link1a_local}_local_client_25006.out &
#    numactl -C "$CLIENT_IFACE0_LOCAL_PIN" iperf3 --client ${ip_addr_link1a_remote} --interval 10 --bind ${ip_addr_link1a_local} --time ${RUNTIME} --len=128K --port 25007 -Z >${ip_addr_link1a_local}_local_client_25007.out &
#     numactl -C "$CLIENT_IFACE1_LOCAL_PIN" iperf3 --client ${ip_addr_link2a_remote} --interval 10 --bind ${ip_addr_link2a_local} --time ${RUNTIME} --len=128K --port 25004 -Z >${ip_addr_link2a_local}_local_client_25004.out &
#    numactl -C "$CLIENT_IFACE1_LOCAL_PIN" iperf3 --client ${ip_addr_link2a_remote} --interval 10 --bind ${ip_addr_link2a_local} --time ${RUNTIME} --len=128K --port 25005 -Z >${ip_addr_link2a_local}_local_client_25005.out &
#    numactl -C "$CLIENT_IFACE1_LOCAL_PIN" iperf3 --client ${ip_addr_link2a_remote} --interval 10 --bind ${ip_addr_link2a_local} --time ${RUNTIME} --len=128K --port 25006 -Z >${ip_addr_link2a_local}_local_client_25006.out &
#    numactl -C "$CLIENT_IFACE1_LOCAL_PIN" iperf3 --client ${ip_addr_link2a_remote} --interval 10 --bind ${ip_addr_link2a_local} --time ${RUNTIME} --len=128K --port 25007 -Z >${ip_addr_link2a_local}_local_client_25007.out &
