#!/bin/bash

INTERFACE="enp2s0"

limpa()
{
	tc qdisc del dev ${INTERFACE} root
}

configura()
{
	DST=$1
	INCREASE=$2
	limpa
	tc qdisc add dev ${INTERFACE} root handle 1: prio
	tc filter add dev ${INTERFACE} parent 1:0 protocol ip prio 1 u32 match ip dst ${DST} flowid 2:1
	tc qdisc add dev ${INTERFACE} parent 1:1 handle 2: netem delay ${INCREASE}ms
}

if [ "$1" == "-c" ]; then
	# limpar o delay
	echo "clean"
	limpa
else
	# inserir atrasos no roteador MIA
	DELAY=100
	if [ "$1" != "" ]; then
		DELAY=$1
	fi
	configura "10.10.2.0/30" "${DELAY}"
fi
