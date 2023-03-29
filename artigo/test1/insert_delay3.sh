#!/bin/bash

INTERFACE="enp2s0"
#INTERFACE="vboxnet0"

limpa()
{
	tc qdisc del dev ${INTERFACE} root
}

configura()
{
	DST1=$1
	INCREASE1=$2
	DST2=$3
	INCREASE2=$4
	DST3=$5
	INCREASE3=$6
	limpa
	tc qdisc add dev ${INTERFACE} root handle 1: prio
	tc filter add dev ${INTERFACE} parent 1:0 protocol ip prio 1 u32 match ip dst ${DST1} flowid 1:1
	tc filter add dev ${INTERFACE} parent 1:0 protocol ip prio 1 u32 match ip dst ${DST2} flowid 1:2
	tc filter add dev ${INTERFACE} parent 1:0 protocol ip prio 1 u32 match ip dst ${DST3} flowid 1:3
	tc qdisc add dev ${INTERFACE} parent 1:1 handle 10: netem delay ${INCREASE1}ms
	tc qdisc add dev ${INTERFACE} parent 1:2 handle 11: netem delay ${INCREASE2}ms
	tc qdisc add dev ${INTERFACE} parent 1:3 handle 12: netem delay ${INCREASE3}ms
}

if [ "$1" == "-c" ]; then
	# limpar o delay
	echo "clean"
	limpa
else
	# inserir atrasos no roteador MIA
	DELAY1=100
	DELAY2=200
	DELAY3=300
	if [ "$1" != "" ]; then
		DELAY1=$1
	fi
	if [ "$2" != "" ]; then
		DELAY2=$2
	fi
	if [ "$3" != "" ]; then
		DELAY3=$3
	fi
	configura "10.10.1.0/30" "${DELAY1}" "10.10.2.0/30" "${DELAY2}" "10.10.3.0/30" "${DELAY3}"
fi
