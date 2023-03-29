#!/bin/bash

#TEMPO=sec
#TEMPO=min

export CMD="sh ipv4 vrf v1 rates\nexit"
declare -i RATE=0
declare -i BYTES=0
declare -i CONTP=0
declare -i CONTL=0
declare -a LISTA
CORES=$(cat networks.txt | cut -f1 -d: | grep '^core[0-9]*' | sort -u)
EDGES=$(cat networks.txt | cut -f1 -d: | grep '^edge[0-9]*' | sort -u)
while true; do
	CONTL=0
	for TEMPO in sec min; do
		LISTA[${CONTL}]="----------------------------------------"
		CONTL=${CONTL}+1
		LISTA[${CONTL}]="${TEMPO}"
		CONTL=${CONTL}+1
		CONTP=1
		for ROUTER in ${CORES} ${EDGES}; do
			LINHA1=$(echo -e "${CMD}" | nc localhost 230${CONTP} | grep -a "^1${TEMPO}")
			RTX=$(echo ${LINHA1} | cut -f2 -d\  )
			RRX=$(echo ${LINHA1} | cut -f3 -d\  )
			BTX=$(echo ${LINHA1} | cut -f5 -d\  )
			BRX=$(echo ${LINHA1} | cut -f6 -d\  )
			if [ "${RTX}" == "" -o "${RRX}" == "" ]; then
				SRATE="-"
			else
				RATE=$RTX+$RRX
				SRATE=$(echo ${RATE})
				SRATE="${RTX}\t${RRX}"
			fi
			if [ "${BTX}" == "" -o "${BRX}" == "" ]; then
				SBYTES="-"
			else
				BYTES=$BTX+$BRX
				SBYTES=$(echo ${BYTES})
				SBYTES="${BTX}\t${BRX}"
			fi
			LISTA[${CONTL}]="${ROUTER}:\t${SRATE}\t${SBYTES}"
			CONTP=${CONTP}+1
			CONTL=${CONTL}+1
		done

	done
	clear
	echo -e "ROUTER:\tRATE\t\tBYTES"
	echo -e "\tTX\tRX\tTX\tRX"
	for str in ${LISTA[@]}; do
		echo -e "${str}"
	done
done

