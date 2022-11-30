#!/bin/bash

docker_scr=./stego-docker.sh

if [ ! -f $docker_scr ]; then
    echo "Error: '$docker_scr' not found!"
    exit 2
fi

$docker_scr --import ./stego-attrib.sh
$docker_scr --import ./coverData

#JPHIDE: not implemented, its broken!
#cp ./utility/jpfix/jphide-auto ./jphide-auto
#cp ./utility/jpfix/jpseek-auto ./jpseek-auto
#$docker_scr --import ./jphide-auto
#$docker_scr --import ./jpseek-auto
#rm -f ./jphide-auto
#rm -f ./jpseek-auto

cp ./utility/stegbreakfix/stegbreak-fix ./stegbreak-fix
cp ./utility/stegbreakfix/rules.ini ./stegbreak-rules.ini
$docker_scr --import ./stegbreak-fix
$docker_scr --import ./stegbreak-rules.ini
rm -f ./stegbreak-fix
rm -f ./stegbreak-rules.ini

exit