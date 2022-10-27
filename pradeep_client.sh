#!/bin/bash
ip_addr_link1b_local="192.168.2.2" #link1b IP local
ip_addr_link2b_local="192.168.4.2" #link2b IP Local
ip_addr_link2b_remote="192.168.4.3" #link1b IP remote
ip_addr_link1b_remote="192.168.2.3" #link2b IP remote
RUNTIME=120

 echo "Starting client:" 
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

