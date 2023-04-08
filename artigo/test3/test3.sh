#!/bin/bash

declare -g RUN=4
declare -g BANDWIDTH_LIST="100"
declare -g INTERFACE="enp0s8"    # interface de saída do host1 para o edge1
declare -g IP_HOST="40.40.2.2"   # ip do host2
declare -g IPERFTIME=240
declare -g SLEEPTIME=240
declare -g DELAY=2
declare -g SAMPLES=10 # Número de vezes que o teste será realizado.
declare -g HOST1=8
declare -g HOST2=9
declare -g -a LIMIT_TUNNEL=[0,0,0,0]

SCRIPT_FLUXO=~/artigo-polka/artigo/test3/fluxo.sh

scpexec() {
	PORT=$1
	echo "scp -P 220${PORT} root@localhost:$2 $3"
	scp -P 220${PORT} root@localhost:$2 $3
}

sshexec() {
	PORT=$1
	CMD=$2
	PARALLEL=$3
	if [ "${PARALLEL}" == "P" ]; then
		echo "ssh -p 220${PORT} root@localhost \"${CMD}\" &"
		ssh -p 220${PORT} root@localhost "${CMD}" &
	else
		echo "ssh -p 220${PORT} root@localhost \"${CMD}\""
		ssh -p 220${PORT} root@localhost "${CMD}"
	fi
}

stopbwmcore() {
	CORE=$(echo $1 | cut -f1 -d:)
	INTERFACE=$(echo $1 | cut -f2 -d:)
	SAMPLE=$2
	BANDWIDTH=$3
	echo "Finalizando bwm-ng pela porta 220${CORE}"
	sshexec ${CORE} "killall bwm-ng 2> /dev/null ; grep ${INTERFACE} tmp.bwm > a${SAMPLE}-a${CORE}.csv"
	mkdir -p data/run${RUN}/${BANDWIDTH}/${SAMPLE}
	scpexec ${CORE} a${SAMPLE}-a${CORE}.csv data/run${RUN}/${BANDWIDTH}/${SAMPLE}/a${CORE}.csv
}

startbwmcore() {
	CORE=$(echo $1 | cut -f1 -d:)
	echo "Iniciando bwm-ng pela porta 220${CORE}"
	sshexec ${CORE} "bwm-ng -t 5000 -o csv -u bytes -T rate -C ',' > tmp.bwm"
}

startiperfservers() {
	echo "Iniciando os servidores iperf TCP..."
	sshexec ${HOST2} "iperf3 -s -p 5000" P # TCP
	sshexec ${HOST2} "iperf3 -s -p 5001" P # TCP
	sshexec ${HOST2} "iperf3 -s -p 5002" P # TCP
	echo ""
	echo "Servidores iniciados..."
}

stopiperfservers() {
	echo "Parando os servidores iperf TCP..."
	sshexec ${HOST2} "killall iperf3" A # TCP
	echo ""
	echo "Servidores parados..."
}


trocafluxo() {
	echo "-----------------------"
	echo " Configurando fluxo: $1"
	echo "-----------------------"
	${SCRIPT_FLUXO} $1 > /dev/null
}

iperftxhost() {
	SAMPLE="$1"
	BANDWIDTH="$2"
	trocafluxo 1
	while read C; do
		$0 startbwmcore ${C} &
	done < <(cat core-routers.txt | grep -v '^#')
#	echo "Iniciando bwm-ng no host2"
#	echo "-------------------------"
#	sshexec ${HOST2} "bwm-ng -t 1000 -o csv -u bytes -T rate -C ',' > tmp.bwm" P
	sleep ${DELAY}
	for fluxo in 1 2; do
		if [ "${fluxo}" != "1" ]; then
			trocafluxo ${fluxo}
		fi
#	sshexec ${HOST1} "iperf3 -c ${IP_HOST} -t ${IPERFTIME} -N -u -b ${BANDWIDTH}m -p 5000 --tos 32  1>/dev/null" P  ### UDP
#	sshexec ${HOST1} "iperf3 -c ${IP_HOST} -t ${IPERFTIME} -N -u -b ${BANDWIDTH}m -p 5001 --tos 64  1>/dev/null" P  ### UDP
#	sshexec ${HOST1} "iperf3 -c ${IP_HOST} -t ${IPERFTIME} -N -u -b ${BANDWIDTH}m -p 5002 --tos 128 1>/dev/null" P  ### UDP
		sshexec ${HOST1} "iperf3 -c ${IP_HOST} -t ${IPERFTIME} -N -p 5000 --tos 32  1>/dev/null" P  ### UDP
		sshexec ${HOST1} "iperf3 -c ${IP_HOST} -t ${IPERFTIME} -N -p 5001 --tos 64  1>/dev/null" P  ### UDP
		sshexec ${HOST1} "iperf3 -c ${IP_HOST} -t ${IPERFTIME} -N -p 5002 --tos 128 1>/dev/null" P  ### UDP
		sleep $((${SLEEPTIME} - ${DELAY})) 2> /dev/null
		sshexec ${HOST1} "killall iperf3"
	done
	while read C; do
		$0 stopbwmcore ${C} ${SAMPLE} ${BANDWIDTH} &
	done < <(cat core-routers.txt | grep -v '^#')
#	echo "Finalizando bwm-ng no host1"
#	sshexec ${HOST2} "killall bwm-ng 2> /dev/null ; grep ${INTERFACE} tmp.bwm > a1.csv"
#	mkdir -p data/run${RUN}/${BANDWIDTH}/${SAMPLE}
#	scpexec ${HOST2} a1.csv data/run${RUN}/${BANDWIDTH}/${SAMPLE}/a1.csv
	sleep "${DELAY}"
}

starttest3() {
	echo "Iniciando o teste..."
	sshexec ${HOST1} "killall iperf3 2> /dev/null ; killall bwm-ng 2> /dev/null" A
	startiperfservers
	for BANDWIDTH in ${BANDWIDTH_LIST}; do
		echo "Considerando uma banda de ${BANDWIDTH}Mbits/s para cada fluxo"
		for i in $(seq 1 $SAMPLES); do
			start_time=$(date +%s)
			echo "================================================================="
			echo "Sample # ${i}: Started in: ${start_time}"
			iperftxhost ${i} ${BANDWIDTH}
			end_time=$(date +%s)
			echo "Sample # ${i}: Finished in: ${end_time}"
		done
	done
	stopiperfservers
}

main() {
	if [ "${1}" == "startbwmcore" ]; then
		startbwmcore ${2}
	elif [ "${1}" == "stopbwmcore" ]; then
		stopbwmcore ${2} ${3} ${4}
	else
		while read LIM; do
			INDX=$(echo ${LIM} | cut -f1 -d=)
			VELO=$(echo ${LIM} | cut -f2 -d=)
			LIMIT_TUNNEL[${INDX}]=${VELO}
		done < <(cat netlimits.txt | grep '=')
		starttest3
	fi
}

main $1 $2 $3 $4
