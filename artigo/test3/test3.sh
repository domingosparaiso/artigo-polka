#!/bin/bash
# executar "./test3.sh rxr" no core4
# executar "./test3.sh txr" no core1
# executar "./test3.sh rxh" no host2
# executar "./test3.sh txh" no host1

declare -g OPT=$1
declare -g INTERFACE="enp0s8"    # interface de saída do host1 para o edge1
declare -g IP_HOST="40.40.2.2"   # ip do host2
declare -g IP_ROUTER="10.10.2.2" # ip do core4
declare -g IPERFTIME=20
declare -g SLEEPTIME=20
declare -g DELAY=2
declare -g SAMPLES=3 # Número de vezes que o teste será realizado.
SSHCONNECTION=$(cat ssh_connection.txt)
SCRIPT_TUNNEL="~/artigo-polka/artigo/tunnel.sh"


iperfrxrouter() {
	echo "Iniciando o servidor iperf UDP..."
	iperf -s -u -p 5000 & # UDP
	echo ""
	read -p "Para cancelar o servidor tecle <ENTER>"
	killall iperf
}

iperfrxhost() {
	echo "Iniciando o servidor iperf TCP..."
	iperf -s -t -p 5000 & # TCP
	echo ""
	read -p "Para cancelar o servidor tecle <ENTER>"
	killall iperf
}

tunnel() {
	echo "Tunnel: $1"
	ssh ${SSHCONNECTION} "${SCRIPT_TUNNEL} $1" > /dev/null
}

iperftxrouter() {
	iperf -c ${IP_ROUTER} -N -u -b 50m -p 5000 1>/dev/null
	read -p "Para cancelar o servidor tecle <ENTER>"
	killall iperf
}

iperftxhost() {
	FILENAME="$1"
	BANDWIDTH="$2"
	tunnel 1
	bwm-ng -t 1000 -o csv -u bytes -T rate -C ',' > tmp.bwm &
	sleep ${DELAY}
	for tun in 1 2 3; do
		if [ "${tun}" != "1" ]; then
			tunnel ${tun}
		fi
		iperf -c ${IP_HOST} -t ${IPERFTIME} -N -t -b ${BANDWIDTH}m -p 5000 1>/dev/null &  ### TCP
		sleep $((${SLEEPTIME} - ${DELAY})) 2> /dev/null
		killall iperf
	done
	killall bwm-ng
	mkdir -p test2/${BANDWIDTH}
	grep ${INTERFACE} tmp.bwm > test2/${BANDWIDTH}/${FILENAME}.csv
	rm tmp.bwm
	sleep "${DELAY}"
}

main() {
	if [ "${OPT}" == "txh" ]; then
		killall iperf
		killall bwm-ng
		for j in $(seq 10 10 40); do
			echo "Considerando uma banda de ${j}Mbits/s"
			for i in $(seq 1 $SAMPLES); do
				start_time=$(date +%s)
				echo "Sample # ${i}: Started in: ${start_time}"
				iperftxhost "a${i}" "$j"
				end_time=$(date +%s)
				echo "Sample # ${i}: Finished in: ${end_time}"
			done
		done
	fi

	if [ "${OPT}" == "txr" ]; then
		iperftxrouter
	fi

	if [ "${OPT}" == "rxh" ]; then
		iperfrxhost
	fi

	if [ "${OPT}" == "rxr" ]; then
		iperfrxrouter
	fi

	if [ "${OPT}" == "" ]; then
		echo "Informe txh (tx-host), txr (tx-router), rxh (rx-host) ou rxr (rx-router)"
	fi
}

main
