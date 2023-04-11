#!/bin/bash
# Executar no host1

SAMPLES=10
IP=40.40.2.2
DELAY=60
SSHCONNECTION=$(cat ssh_connection.txt)
SCRIPT_TUNNEL="~/wpeif-2023/artigo/tunnel.sh"
tunel()
{
	echo "Tunnel: $1"
	ssh ${SSHCONNECTION} "${SCRIPT_TUNNEL} $1" > /dev/null
}

main()
{
	if [ "$1" == "" ]; then
		echo "Informe o nome do arquivo de saída"
		exit
	fi
	FILENAME="$1"
	for i in `seq $SAMPLES`
	do
		echo "Starting: Ping $i"
		tunel 1
		ping $IP > ping.log &
		for t in 1 2; do
			if [ "$t" != "1" ]; then
				tunel $t
			fi
			sleep $DELAY
		done
		echo "Ending: Ping $i"
		killall ping 2>/dev/null
		cat ping.log | head -n -4 | tail -n +2 | cut -d ' ' -f 7 | sed 's/time=//g' > a${i}_${FILENAME};
		rm ping.log
	done
}

main "$@"

