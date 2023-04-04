#!/bin/bash

CORES=$(cat networks.txt | cut -f1 -d: | grep '^core[0-9]*' | sort -u)
EDGES=$(cat networks.txt | cut -f1 -d: | grep '^edge[0-9]*' | sort -u)
HOSTS=$(cat networks.txt | cut -f1 -d: | grep '^host[0-9]*' | sort -u)
LISTA=""
CMD=""
declare -A COMPUTERS=( [core1]=1 [core2]=2 [core3]=3 [core4]=4 [core5]=5 [edge1]=6 [edge2]=7 [host1]=8 [host2]=9 )
TESTE=$1
while [ "${TESTE}" != "" ]; do
	if [ "${TESTE}" == "-c" ]; then
		LISTA="${CORES}"
	fi
	if [ "${TESTE}" == "-e" ]; then
		LISTA="${EDGES}"
	fi
	if [ "${TESTE}" == "-h" ]; then
		LISTA="${HOSTS}"
	fi
	if [ "${TESTE}" == "-l" ]; then
		shift
		LISTA="$1"
	fi
	if [ "${TESTE}" == "-a" ]; then
		LISTA="${CORES} ${EDGES} ${HOSTS}"
	fi
	if [ "${TESTE}" == "-p" ]; then
		CMD="pause"
	fi
	if [ "${TESTE}" == "-r" ]; then
		CMD="resume"
	fi
	if [ "${TESTE}" == "-t" ]; then
		CMD="savestate"
	fi
	if [ "${TESTE}" == "-o" ]; then
		CMD="poweroff"
	fi
	if [ "${TESTE}" == "-s" ]; then
		CMD="start"
	fi
	shift
	TESTE=$1
done

if [ "${LISTA}" == "" -o "${CMD}" == "" ]; then
	echo "Informe as máquinas virtuais para inicialização."
	echo "controle.sh [-a | -c | -e | -h | -l \"lista\"] [-p | -r]"
	echo ""
	echo "Seleção de máquinas:"
	echo "  -a             Todas as máquinas da topologia"
	echo "  -c             Apenas nos cores"
	echo "  -e             Apenas nos edges"
	echo "  -h             Apenas os hosts"
	echo "  -l \"lista\"   Apenas ar máquinas da lista"
	echo "Comando:"
	echo "  -s             Start"
	echo "  -p             Pause"
	echo "  -r             Resume"
	echo "  -t             Savestate"
	echo "  -o             Poweroff"
	exit
fi


for VM in ${LISTA}; do
	VM_NAME=${VM}
	for r in "${!COMPUTERS[@]}"; do
		if [ "${COMPUTERS[${r}]}" == "${VM}" ]; then
			VM_NAME=${r}
		fi
	done
	echo "Controle: ${CMD} ${VM_NAME}..."
	if [ "${CMD}" == "start" ]; then
		VBoxManage startvm "${VM_NAME}" --type=headless
	else
		VBoxManage controlvm "${VM_NAME}" ${CMD}
	fi
done
