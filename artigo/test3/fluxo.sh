#!/bin/bash

if [ "$1" == "1" -o "$1" == "2" ]; then
	echo "Edges na configuração $1..."
	F1="1"
	F2="1"
	F3="1"
	if [ "$1" == "2" ]; then
		F2="2"
		F3="3"
	fi
	echo -e "conf\nipv4 pbr v1 sequence 10 fluxo1 v1 nexthop 30.30.${F1}.2\nipv4 pbr v1 sequence 20 fluxo2 v1 nexthop 30.30.${F2}.2\nipv4 pbr v1 sequence 30 fluxo3 v1 nexthop 30.30.${F3}.2\nexit\nexit" | nc localhost 2306 > /dev/null
	echo -e "conf\nipv4 pbr v1 sequence 10 fluxo1 v1 nexthop 30.30.${F1}.1\nipv4 pbr v1 sequence 20 fluxo2 v1 nexthop 30.30.${F2}.1\nipv4 pbr v1 sequence 30 fluxo3 v1 nexthop 30.30.${F3}.1\nexit\nexit" | nc localhost 2307 > /dev/null
	echo -e "sh ipv4 pbr v1\nexit" | nc localhost 2306
	echo -e "sh ipv4 pbr v1\nexit" | nc localhost 2307
else
	if [ "$1" == "-i" ]; then
		echo -e "sh ipv4 pbr v1\nexit" | nc localhost 2306
		echo -e "sh ipv4 pbr v1\nexit" | nc localhost 2307
	else
		echo "Informe a configuração (1 ou 2)"
		echo ""
		echo "Configuração 1: todos os fluxos pelo tunnel1"
		echo "Configuração 2: fluxo1 (tos=0x20) pelo tunnel1"
		echo "                fluxo2 (tos=0x40) pelo tunnel2"
		echo "                fluxo3 (tos=0x80) pelo tunnel3"
		echo ""
		echo "-i para informação sobre os fluxos"
	fi
fi
