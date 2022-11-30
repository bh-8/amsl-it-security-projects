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

function importDockerRoot {
    localPath=$1
    dockerFName=$2
    
    cp $localPath $dockerFName
    $docker_scr --import $dockerFName
    rm -f $dockerFName
}

importDockerRoot "./utility/stegbreakfix/stegbreak-fix" "./stegbreak-fix"
importDockerRoot "./utility/stegbreakfix/rules.ini" "./stegbreak-rules.ini"

importDockerRoot "./embeddingData/binaryEmbedding" "./embeddingBinary"
importDockerRoot "./embeddingData/longEmbedding.txt" "./embeddingLong.txt"
importDockerRoot "./embeddingData/lowEntropyEmbedding.txt" "./embeddingLowEntropy.txt"
importDockerRoot "./embeddingData/middleEmbedding.txt" "./embeddingMiddle.txt"
importDockerRoot "./embeddingData/shortEmbedding.txt" "./embeddingShort.txt"

exit