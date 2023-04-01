#!/bin/bash

declare -i NIC=0

lista() {
	while read LINHA; do
		TMP=$(echo $LINHA | cut -f2 -d\  | cut -f1 -d:)
		NIC=${TMP}-1
		NETNAME=$(echo $LINHA | cut -f2 -d\')
		echo "${NETNAME}:${VM} (eth${NIC})"
	done < <(vboxmanage showvminfo ${1} | grep 'Internal Network' | cut -f1,4 -d: | cut -f1,2 -d\' )
}
N0=""
VMS=$(cat networks.txt | cut -f1 -d: | sort -u)
for VM in ${VMS}; do
	lista "${VM}"
done | sort | while read LINHA; do
	N=$(echo $LINHA | cut -f1 -d:)
	if [ "${N}" != "${N0}" ]; then
		echo "${N}"
		N0="${N}"
	fi
	echo -n -e "\t"
	echo $LINHA | cut -f2 -d:
done
