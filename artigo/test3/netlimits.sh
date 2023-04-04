#!/bin/bash

declare -g -a LIMIT_TUNNEL=[0,0,0,0]
remove_limits() {
	for VM in ${1}; do
		# Removendo grupos das interfaces
		for INTERFACE in 1 2 3 4 5 6 7 8; do
			vboxmanage modifyvm ${VM} --nicbandwidthgroup${INTERFACE} none
		done
		# Removendo os limites existentes
		while read LIMITE; do
			if [ "${LIMITE}" != "<none>" -a "${LIMITE}" != "" ]; then
				vboxmanage bandwidthctl ${VM} remove ${LIMITE}
			fi
		done < <(vboxmanage bandwidthctl ${VM} list | cut -f2 -d\')
	done
}

add_limits() {
	while read LIN; do
		VM=$(echo ${LIN} | cut -f1 -d:)
		INTERFACE=$(echo ${LIN} | cut -f2 -d:)
		LIMIT=$(echo ${LIN} | cut -f3 -d:)
		# Adicionando os novos limites
		vboxmanage bandwidthctl ${VM} add Limit${INTERFACE} --type network --limit ${LIMIT_TUNNEL[${LIMIT}]}m
		# Aplicando os limites nas interfaces
		vboxmanage modifyvm ${VM} --nicbandwidthgroup${INTERFACE} Limit${INTERFACE}
	done < <(cat netlimits.txt | grep -v '=')
}


update_limits() {
	while read LIN; do
		VM=$(echo ${LIN} | cut -f1 -d:)
		INTERFACE=$(echo ${LIN} | cut -f2 -d:)
		LIMIT=$(echo ${LIN} | cut -f3 -d:)
		# Atualizando os limites
		vboxmanage bandwidthctl ${VM} set Limit${INTERFACE} --limit ${LIMIT_TUNNEL[${LIMIT}]}m
	done < <(cat netlimits.txt | grep -v '=')
}

list_limits() {
	for VM in ${1}; do
		L=0
		while read LIN; do
			LIMITE=$(echo ${LIN} | cut -f2 -d\') 
			if [ "${LIMITE}" != "<none>" -a "${LIMITE}" != "" ]; then
				if [ "${L}" == "0" ]; then
					L=1
					echo "VM: ${VM}"
				fi
				VELO=$(echo ${LIN} | cut -f5 -d: | cut -f2-3 -d\ )
				NIC=${LIMITE:5:1}
				echo -e "\tNIC${NIC}: ${VELO}"
			fi
		done < <(vboxmanage bandwidthctl ${VM} list | grep -v '^<none>' | grep -v '^$')
	done
}

LIST=$(cat netlimits.txt | grep -v '=' | cut -f1 -d: | sort -u)
while read LIM; do
	INDX=$(echo ${LIM} | cut -f1 -d=)
	VELO=$(echo ${LIM} | cut -f2 -d=)
	LIMIT_TUNNEL[${INDX}]=${VELO}
done < <(cat netlimits.txt | grep '=')
if [ "$1" == "-i" ]; then
	list_limits "${LIST}"
elif [ "$1" == "-c" ]; then
	remove_limits "${LIST}"
elif [ "$1" == "-u" ]; then
	update_limits
	list_limits "${LIST}"
elif [ "$1" == "-l" ]; then
	remove_limits "${LIST}"
	add_limits
	list_limits "${LIST}"
else
	echo "Informe uma das opções:"
	echo " -i Informações sobre os limites"
	echo " -u Atualizar os limites definidos (com as máquinas rodando)"
	echo " -c Apagar todos os limites de todas as máquinas"
	echo " -l Criar as regras e definir os limites"
fi

