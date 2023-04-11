#!/bin/bash

TOPOLOGIA=""
TESTE=""
cd /rtr
if [ "$1" != "" ]; then
	if [ "$1" == "--clean" -o "$1" == "-c" ]; then
		rm -f cfgnet.sh rtr.sh interface_map.txt lista.txt template-* router-*
		echo "Arquivos removidos."
		exit
	else
		if [ "$1" == "--host" -o "$1" == "-h" ]; then
			NEWHOST=$2
			OLDHOST=$(cat /etc/hostname)
			if [ "${NEWHOST}" != "${OLDHOST}" ]; then
				echo "${NEWHOST}" > /etc/hostname
				echo "127.0.0.1 localhost ${NEWHOST}" > /etc/hosts
				hostname ${NEWHOST}
			fi
			exit
		else
			TOPOLOGIA="${1}"
			TESTE="\/${2}"
			echo ${TOPOLOGIA}:${TESTE} > topologia.txt
		fi
	fi
else
	if [ -f topologia.txt ]; then
		TOPOLOGIA=$(cat topologia.txt | cut -f1 -d:)
		TESTE="$(cat topologia.txt | cut -f2 -d:)"
	fi
	if [ "${TOPOLOGIA}" == "" ]; then
		echo "Informe a topologia."
		exit
	fi
fi

ROUTER=$(hostname)
SSHREMOTE=$(cat ssh_connection.txt)
REMOTE="${SSHREMOTE}:~/wpeif-2023/"

scp ${REMOTE}lista.txt .

for ARQ in $(cat lista.txt); do
	ARQ_REMOTO=$(echo ${ARQ} | sed "s/{HOST}/-${ROUTER}/g;s/{TOPOLOGIA}/${TOPOLOGIA}${TESTE}\//g")
	ARQ_LOCAL=$(echo ${ARQ} | sed "s/{HOST}//g;s/{TOPOLOGIA}//g")
	echo "copiando ${ARQ_REMOTO} para ${ARQ_LOCAL}"
	scp ${REMOTE}${ARQ_REMOTO} ${ARQ_LOCAL}
done
rm -f lista.txt
./cfgnet.sh
