#!/bin/bash

docker_scr=./stego-docker.sh

if [ ! -f $docker_scr ]; then
    echo "Error: '$docker_scr' not found!"
    exit 2
fi

$docker_scr --import ./stego-attrib.sh

exit