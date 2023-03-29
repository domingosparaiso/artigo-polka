#!/bin/bash

for VM in core1 edge1 edge2 host1 host2; do
	echo "Iniciando ${VM}..."
	VBoxManage startvm "${VM}" --type=headless
done
