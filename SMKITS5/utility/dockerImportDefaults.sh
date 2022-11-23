#!/bin/bash

docker_scr=./stego-docker.sh

if [ ! -f $docker_scr ]; then
    echo "Error: '$docker_scr' not found!"
    exit 2
fi

$docker_scr --import ./stego-attrib.sh
$docker_scr --import ./coverData
cp ./utility/jpfix/jphide-auto ./jphide-auto
cp ./utility/jpfix/jpseek-auto ./jpseek-auto
$docker_scr --import ./jphide-auto
$docker_scr --import ./jpseek-auto
rm -f ./jphide-auto
rm -f ./jpseek-auto
cp ./utility/stegbreakfix/stegbreak ./stegbreak-fix
$docker_scr --import ./stegbreak-fix
rm -f ./stegbreak-fix

exit