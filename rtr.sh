#!/bin/bash

INTERFACES=$(ip a | grep ': <' | cut -f2 -d: | cut -f2 -d\ )
if [ -f interface_map.txt ]; then
  while read LINHA; do
    IFACE=$(echo $LINHA | cut -f1 -d:)
    for I in ${INTERFACES}; do
      if [ "${IFACE}" == "${I}" ]; then
        echo "Interfaces ${I}"
        ./tcp-offload-off.sh ${I}
      fi
    done
  done < interface_map.txt
fi

java -jar rtr.jar routersc router-hw.txt router-sw.txt
