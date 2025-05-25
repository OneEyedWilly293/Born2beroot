#!/bin/bash

# Get architecture and kenerl version
ARCH=$(uname -a)

# Get number of physical CPU (sockets)
PHYS_CPU=$(lscpu | grep "Socket(s):" | awk '{print $2}')
# lscpu prints: "Socket(s): 1" for 1 physical CPU

# Get number of virtual CPUs (logical processors/threads)
VIRT_CPU=$(nproc --all)
# nproc --all prints the number of logical CPUs (threads)

# Get memory usage: used and total, and usage percentage
MEM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/^Mem:/ {print $3}')
MEM_PERC=$(awk "BEGIN {printf \"%.2f\", (${MEM_USED}/${MEM_TOTAL})*100}")
# free: display amount of free and used memory in the system -m:mebibytes | awk: scripting language for text processing 

# Get disk usage: used and total, and usage percentage (for '/')
DISK_TOTAL=$(df -BG --output=size / | tail -1 | tr -dc '0-9')
DISK_USED=$(df -BG --output=used / | tail -1 | tr -dc '0-9')
DISK_PERC=$(df -h / | awk 'NR==2 {print $5}')
#df: report file system disk space usage

# Get CPU load
cpul=$(vmstat 1 2 | tail -1 | awk '{printf $15}')
cpu_op=$(expr 100 - $cpul)
cpu_fin=$(printf "%.1f" $cpu_op)


# Get last boot date/time
LAST_BOOT=$(who -b | awk '{print $3 " " $4}')
#who: show who is logged on -b : boot

# Check if LVM is active
LVM_USE=$(lsblk | grep "lvm" > /dev/null && echo "yes" || echo "no")

# Get number of active TCP connections
TCP_CONN=$(ss -t | grep ESTAB | wc -l)

# Get number of logged-in users
USER_LOG=$(users | wc -w)

# Get IPv4 and MAC address (for eth0 or first interface with an IP)
IP_ADDR=$(hostname -I | awk '{print $1}')
MAC_ADDR=$(ip link | awk '/ether/ {print $2; exit}')

# Get number of sudo commands executed
SUDO_LOG=$(journalctl _COMM=sudo | grep COMMAND | wc -l)

# Print all information using wall so it appears on all terminals
wall << EOF
#Architecture: $ARCH
#CPU physical: $PHYS_CPU
#vCPU: $VIRT_CPU
#Memory Usage: ${MEM_USED}/${MEM_TOTAL}MB (${MEM_PERC}%)
#Disk Usage: ${DISK_USED}/${DISK_TOTAL}Gb (${DISK_PERC})
#CPU load: $cpu_fin%
#Last boot: $LAST_BOOT
#LVM use: $LVM_USE
#Connections TCP: $TCP_CONN ESTABLISHED
#User log: $USER_LOG
#Network: IP $IP_ADDR ($MAC_ADDR)
#Sudo: $SUDO_LOG cmd
EOF

