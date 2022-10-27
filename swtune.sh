    ethtool -K link1a lro on
    ethtool -K link1a hw-tc-offload off
    ethtool -K link1a ntuple on
    ethtool -K link1a tx-nocache-copy off
    ethtool -G link1a rx 8192 tx 8192
    ethtool -s link1a speed 100000 duplex full autoneg off
    ethtool -L link1a combined 63

    ethtool -K link1b lro on
    ethtool -K link1b hw-tc-offload off
    ethtool -K link1b ntuple on
    ethtool -K link1b tx-nocache-copy off
    ethtool -G link1b rx 8192 tx 8192
    ethtool -s link1b speed 100000 duplex full autoneg off
    ethtool -L link1b combined 63

    ip link set link1a mtu 1500
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
    for f in /sys/class/net/link1a/queues/rx-*/rps_flow_cnt; do echo 1024 >"$f"; done
    for f in /sys/class/net/link1b/queues/rx-*/rps_flow_cnt; do echo 1024 >"$f"; done
#    bash bidir_set_nic_irq_affinity_lrooff.sh > /dev/null
    cpupower frequency-set -r -g performance
