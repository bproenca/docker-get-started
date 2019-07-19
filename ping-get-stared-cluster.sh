#!/bin/bash
while true; do
	curl -4 http://$1:4000
	echo ""
    echo "Pinging IP: " $1
	sleep 1
done