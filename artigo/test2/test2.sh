#!/bin/bash
# executar "./test2.sh rx" no host2
# executar "./test2.sh tx" no host1

declare -g RUN=5
declare -g OPT=$1
declare -g INTERFACE="enp0s8"  # interface de saída do host1 para o edge1
declare -g IP="40.40.2.2"      # ip do host2
declare -g IPERFTIME=60
declare -g SLEEPTIME=60
declare -g DELAY=2
declare -g SAMPLES=20 # Número de vezes que o teste será realizado.
SSHCONNECTION=$(cat ssh_connection.txt)
SCRIPT_TUNNEL="~/artigo-polka/artigo/tunnel.sh"

iperfrx () {
	iperf -s -u -p 5000 # UDP
}

tunnel() {
	echo "Tunnel: $1"
	ssh ${SSHCONNECTION} "${SCRIPT_TUNNEL} $1" > /dev/null
}

iperftx () {
	FILENAME="$1"
	BANDWIDTH="$2"
	tunnel 1
	bwm-ng -t 1000 -o csv -u bytes -T rate -C ',' > tmp.bwm &
	sleep ${DELAY}
	for tun in 1 2 3; do
		if [ "${tun}" != "1" ]; then
			tunnel ${tun}
		fi
		iperf -c $IP -t ${IPERFTIME} -N -u -b ${BANDWIDTH}m -p 5000 1>/dev/null &  ### UDP
		sleep $((${SLEEPTIME} - ${DELAY})) 2> /dev/null
		killall iperf
	done
	killall bwm-ng
	mkdir -p data/run${RUN}/${BANDWIDTH}
	grep ${INTERFACE} tmp.bwm > data/run${RUN}/${BANDWIDTH}/${FILENAME}.csv
	rm tmp.bwm
	sleep "${DELAY}"
}

main() {
	if [ "${OPT}" == "tx" ]; then
		killall iperf
		killall bwm-ng
		for j in 10 20 30 40; do
			echo "Considerando uma banda de ${j}Mbits/s"
			for i in $(seq 1 $SAMPLES); do
				start_time=$(date +%s)
				echo "Sample # ${i}: Started in: ${start_time}"
				iperftx "a${i}" "$j"
				end_time=$(date +%s)
				echo "Sample # ${i}: Finished in: ${end_time}"
			done
		done
	fi
	
	if [ "${OPT}" == "rx" ]; then
		iperfrx
	fi

	if [ "${OPT}" == "" ]; then
		echo "Informe tx ou rx"
	fi
}

main
