#!/bin/bash

#docker management script location
docker_scr=./stego-docker.sh

if [ ! -f $docker_scr ]; then
    echo "Error: '$docker_scr' not found!"
    exit 2
fi

#import script and cover data
$docker_scr --import ./stego-attrib.sh
$docker_scr --import ./coverData

#copy file in docker base directory
function importDockerRoot {
    localPath=$1
    dockerFName=$2
    
    #copy file to current location (tmp)
    cp $localPath $dockerFName

    #import file from there
    $docker_scr --import $dockerFName

    #remove temporary file
    rm -f $dockerFName
}

#copy jphide fixed data
#JPHIDE: not implemented, its broken!
#importDockerRoot "./utility/jpfix/jphide-auto" "./jphide-auto"
#importDockerRoot "./utility/jpfix/jpseek-auto" "./jpseek-auto"

#copy stegbreak fixed data
importDockerRoot "./utility/stegbreakfix/stegbreak-fix" "./stegbreak-fix"
importDockerRoot "./utility/stegbreakfix/rules.ini" "./stegbreak-rules.ini"

#copy embedding data
importDockerRoot "./embeddingData/binaryEmbedding" "./embeddingBinary"
importDockerRoot "./embeddingData/longEmbedding.txt" "./embeddingLong.txt"
importDockerRoot "./embeddingData/lowEntropyEmbedding.txt" "./embeddingLowEntropy.txt"
importDockerRoot "./embeddingData/middleEmbedding.txt" "./embeddingMiddle.txt"
importDockerRoot "./embeddingData/shortEmbedding.txt" "./embeddingShort.txt"

exit 0