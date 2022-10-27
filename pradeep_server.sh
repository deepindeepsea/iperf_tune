#!/bin/bash
ip_addr_link1b_local="192.168.2.2" #link1b IP local
ip_addr_link2b_local="192.168.4.2" #link2b IP Local
ip_addr_link2b_remote="192.168.2.3" #link1b IP remote
ip_addr_link1b_remote="192.168.4.3" #link2b IP remote


 echo "Starting servers:" 
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
