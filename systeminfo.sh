#!/bin/bash
#
# Script for check System Information on RHEL
#
# Jati Nurohman | jatinurohman19@gmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version, with the following exception:
# the text of the GPL license may be omitted.

SERVER=$(hostname -A)
IPADDR=$(ip addr | grep "state UP" -A2 | tail -1 | awk '{print $2}' | cut -d "/" -f 1)
MODEL=$(cat /proc/cpuinfo | grep "model name" | sort -u | cut -d ":" -f 2 | sed 's/ //')
SOKET=$(cat /proc/cpuinfo | grep "physical id" | sort -u | wc -l)
MEMTYPE=$(dmidecode -t 17 | grep Type | head -1 | awk '{print $2}')
MEM=$(head -1 /proc/meminfo | awk '$3=="kB"{$2=$2/1024;$3="MB";} 1' | cut -d " " -f 2,3)
DISK=$(fdisk -l | grep Disk | head -1 | awk -F '[:, ]' '{print $4,$5}')
ED=$(subscription-manager list --installed | grep "Ends:" | awk '{print $2}' | head -1)
EXPIRED=$( echo $ED | cut -d "/" -f 2)'-'$(echo $ED | cut -d "/" -f 1)'-'$(echo $ED | cut -d "/" -f 3)
PN=$(dmidecode -t 1 | grep Product | cut -d " " -f 3-4)
SN=$(dmidecode -t 1 | grep Serial | cut -d " " -f 3)
OS=$(cat /etc/redhat-release | cut -d ' ' -f 1-5)
RILIS=$(cat /etc/redhat-release | cut -d ' ' -f 7-8)
KERNEL=$(uname -r)
ARCH=$(uname -m)

echo "+-------------------+"
echo " SERVER INFORMATION"
echo "+-------------------+"
echo "Hostname (FQDN) : "$SERVER
echo "IP              : "$IPADDR
echo "Sistem Operasi  : "$OS
echo "Rilis           : "$RILIS
echo "Versi Kernel    : "$KERNEL
echo "Arsitektur      : "$ARCH
echo "Lisensi Expired : "$EXPIRED
echo "Seri Server     : "$PN
echo "Serial Number   : "$SN
echo "Tipe Prosesor   : "$MODEL
echo "Jumlah Prosesor : "$SOKET
echo "Tipe Memori     : "$MEMTYPE
echo "Total Memori    : "$MEM
echo "Total Storage   : "$DISK
echo "+-------------------+"