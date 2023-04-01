#!/bin/bash

if [ "$1" == "" ];then
	echo "Informe o diretório onde estão localizados os arquivos de configuração da topologia que deseja configurar."
	exit
fi

declare -i CONTPF
CONTPF=1
if [ -f $1/networks.txt ]; then
	LASTVM=""
	while read LINHA; do
		if [ "${LINHA}" != "" ]; then
			# nome da VM
			VM=$(echo ${LINHA} | cut -f1 -d:)
			if [ "${LASTVM}" != "${VM}" ]; then
				echo "Limpando interfaces de ${VM}..."
				# na primeira vez, remove todas as interfaces
				LASTVM=${VM}
				for NIC in 1 2 3 4 5 6 7 8; do
					VBoxManage modifyvm "${VM}" --nic${NIC} null
					VBoxManage modifyvm "${VM}" --nic${NIC} none
				done
			fi
			NIC=""
			INTERFACE=$(echo ${LINHA} | cut -f2 -d:)
			MACADDRESS=$(echo ${LINHA} | cut -f3 -d:)
			NETWORK=$(echo ${LINHA} | cut -f4 -d:)
			case ${INTERFACE} in
			eth0)
				NIC=1
				;;
			eth1)
				NIC=2
				;;
			eth2)
				NIC=3
				;;
			eth3)
				NIC=4
				;;
			eth4)
				NIC=5
				;;
			eth5)
				NIC=6
				;;
			esac
			if [ "${NIC}" != "" ]; then
				echo "Configurando ${INTERFACE} na rede ${NETWORK}"
				VBoxManage modifyvm "${VM}" --nictype${NIC} 82540EM
				VBoxManage modifyvm "${VM}" --macaddress${NIC} "${MACADDRESS}"
				VBoxManage modifyvm "${VM}" --cableconnected${NIC} on
				if [ "${NETWORK}" == "NAT" ]; then
					VBoxManage modifyvm "${VM}" --nic${NIC} nat
					VBoxManage modifyvm "${VM}" --nat-pf${NIC} delete "SSH" 2> /dev/null
					VBoxManage modifyvm "${VM}" --nat-pf${NIC} delete "TELNET" 2> /dev/null
					if [ ${CONTPF} -le 9 ]; then
						NUMPF=0${CONTPF}
					else
						NUMPF=${CONTPF}
					fi
					VBoxManage modifyvm "${VM}" --nat-pf${NIC} SSH,tcp,,22${NUMPF},10.0.2.15,22
					VBoxManage modifyvm "${VM}" --nat-pf${NIC} TELNET,tcp,,23${NUMPF},10.0.2.15,23
					CONTPF=${CONTPF}+1
					echo "Configurando interface NAT na sequencia ${NUMPF}"
				else
					VBoxManage modifyvm "${VM}" --nic${NIC} intnet
					VBoxManage modifyvm "${VM}" --intnet${NIC} "${NETWORK}"
					VBoxManage modifyvm "${VM}" --nic-promisc${NIC}=allow-all
				fi
			fi
		fi
	done < $1/networks.txt
else
	echo "Arquivo '$1/networks.txt' não encontrado"
fi
