#  set -x

# Use lscpu to get socket number, numa node number, smt status, and pysical cores per socket.
total_cores=$(lscpu | grep "^CPU(s):" | rev | cut -f1 -d' ' | rev)
num_socket=$(lscpu | grep Socket | rev | cut -f1 -d' ' | rev)
cores_per_sock=$(lscpu | grep "Core(s) per socket" | rev | cut -f1 -d' ' | rev)
echo "Trying automatic IRQ pinning"

first_irq_core=0
#first_sibling_irq_core=$((cores_per_sock + first_irq_core))
first_sibling_irq_core=$((0 + first_irq_core))
#last_irq_core=$((first_irq_core + 15))
last_sibling_irq_core=$((first_sibling_irq_core + 63))

# soc0_nic_cores=(
#     $(seq "$first_irq_core" "$last_irq_core")
#     $(seq "$first_sibling_irq_core" "$last_sibling_irq_core")
# )
soc0_nic_cores=(
    $(seq "$first_sibling_irq_core" "$last_sibling_irq_core")
)
echo "${soc0_nic_cores[@]}"
# Group Mellanox CX5 devices by their Sockets
numa0_pcie=""
numa1_pcie=""
pcie_dev=$(lspci | grep Mell | grep 'ConnectX-6\|ConnectX-5' | cut -f1 -d' ')
for device in ${pcie_dev}; do
    node_numa=$(lspci -s ${device} -vv | grep NUMA | rev | cut -f1 -d' ' | rev)
    if [[ node_numa -eq '0' ]]; then
        numa0_pcie="${numa0_pcie} ${device}"
    elif [[ node_numa -eq '1' ]]; then
        numa1_pcie="${numa1_pcie} ${device}"
    else
        echo "Script only does IRQ pinning for dual-socket NPS1 configuration. Consider manual IRQ pinning"
        echo "Check if there is any available Mellanox CX5 or CX6"
        exit 0
    fi
done

# Assign IRQ's of each device according to its socket alignment
systemctl stop irqbalance
eth_key1=mlx5_comp
eth_key2=mlx5

size_soc0_cores=${#soc0_nic_cores[@]}
echo ${numa0_pcie}

count=0
for device in ${numa0_pcie}; do
    for irqn in $(ls /proc/irq/*/$eth_key1* | grep "$eth_key2" | grep "$device" | awk -F "/" '{print $4}' | sort -g); do
        echo "IRQ ${irqn} of device ${device} going to core ${soc0_nic_cores[$count]}"
        echo ${soc0_nic_cores[$count]} >/proc/irq/$irqn/smp_affinity_list
        # echo "IRQ ${irqn} of device ${device} going to core $first_irq_core-$last_irq_core,$first_sibling_irq_core-$last_sibling_irq_core"
        # echo "$first_irq_core-$last_irq_core,$first_sibling_irq_core-$last_sibling_irq_core" >/proc/irq/$irqn/smp_affinity_list
        count=$(((count + 1) % size_soc0_cores))
    done
done
