#!/bin/bash

CORES=$(cat networks.txt | cut -f1 -d: | grep '^core[0-9]*' | sort -u)
EDGES=$(cat networks.txt | cut -f1 -d: | grep '^edge[0-9]*' | sort -u)
HOSTS=$(cat networks.txt | cut -f1 -d: | grep '^host[0-9]*' | sort -u)
HOSTNUM=""
ACTION=""
declare -A COMPUTERS
declare -i CONT=0
for index in ${CORES} ${EDGES} ${HOSTS}; do
	CONT=${CONT}+1
	COMPUTERS[${index}]=${CONT}
done
while [ "$1" != "" ]; do
	if [ "$1" == "-c" ]; then
		EDGES=""
		HOSTS=""
		shift
	fi
	if [ "$1" == "-e" ]; then
		CORES=""
		HOSTS=""
		shift
	fi
	if [ "$1" == "-h" ]; then
		CORES=""
		EDGES=""
		shift
	fi
	if [ "$1" == "-l" ]; then
		declare -i num
		shift
		EDGES=""
		CORES=""
		HOSTS=""
		for r in $1; do
			if [ "${COMPUTERS[${r}]}" != "" ]; then
				HOSTNUM="${HOSTNUM} ${COMPUTERS[${r}]}"
			else
				num=$r
				HOSTNUM="${HOSTNUM} ${num}"
			fi
		done
		echo ${HOSTNUM}
		shift
	fi
	if [ "$1" == "-x" -o "$1" == "-t" ]; then
		if [ "${ACTION}" != "" ]; then
			echo "Somente uma ação pode ser selecionada \"-x\" ou \"-t\"."
			exit
		fi
	fi
	if [ "$1" == "-x" ]; then
		ACTION=$1
		shift
		CMD="$1"
		shift
	fi
	if [ "$1" == "-t" ]; then
		ACTION=$1
		shift
		ORIG="$1"
		shift
		TMP="$1"
		DEST="/rtr/"
		if [ "${TMP:0:1}" != "-" ]; then
			DEST="$1"
			shift
		fi
	fi
done
if [ "${CORES}" == "" -a "${EDGES}" == "" -a "${HOSTS}" == "" -a "${HOSTNUM}" == "" ]; then
	echo "Escolha apenas um filtro -c, -e, -h ou -l. Para executar em todos, não selecione opção"
	exit
fi
LISTA="${CORES} ${EDGES} ${HOSTS} ${HOSTNUM}"
if [ "${ACTION}" == "" ]; then
	echo "Ferramenta para execução de comandos e cópia de arquivos."
	echo "remote.sh [ -c | -e | -h | -l \"lista\" ] [ -x \"comando\" ] [ -t orig [ dest ] ]"
	echo ""
	echo "Filtra computadores de destino:"
	echo "-c             Apenas nos cores"
	echo "-e             Apenas nos edges"
	echo "-h             Apenas nos hosts"
	echo "-l \"lista\"   Apenas nos computadores da lista"
	echo ""
	echo "Seleciona ação:"
	echo "-x \"comando\" Executa o comando"
	echo "-t orig [dest] Copia o arquivo local orig para dest na máquina remota"
	echo "               se dest não for informado, usa \"/rtr\" como padrão"
	exit
fi
for I in ${LISTA}; do
	COMPUTER_NAME=${I}
	COMPUTER_NUM=${I}
	for index in "${!COMPUTERS[@]}"; do
		value=${COMPUTERS[${index}]}
		if [ "${index}" == "${I}" ]; then
			COMPUTER_NUM=${value}
		fi
		if [ "${value}" == "${I}" ]; then
			COMPUTER_NAME=${index}
		fi
	done
	if [ "${ACTION}" == "-x" ]; then
		echo "Executando comando \"${CMD}\" na máquina ${COMPUTER_NAME}"
		ssh -p 220${COMPUTER_NUM} root@localhost "${CMD}"
	fi
	if [ "${ACTION}" == "-t" ]; then
		echo "Transferindo arquivo \"${ORIG}\" para \"${DEST}\" na máquina ${COMPUTER_NAME}"
		scp -P 220${COMPUTER_NUM} ${ORIG} root@localhost:${DEST}
	fi
done
