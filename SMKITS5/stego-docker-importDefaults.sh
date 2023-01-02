#!/bin/bash
##################################################
# Script: stego-utils-importDefaults.sh
# Syntax: ./stego-utils-importDefaults.sh
# Ausfuehrungsumgebung: physischer Projektordner, aber es muss eine Instanz des virtuellen Containers laufen, in die importiert werden soll!
# Beschreibung: importiert alle benoetigten Daten in den Docker-Container
##################################################
# Konstanten:

# Link zum Basis-Script, um Daten zu importieren
docker_scr=./stego-docker.sh

##################################################

if [ ! -f $docker_scr ]; then
    echo "Error: '$docker_scr' not found!"
    exit 2
fi

#import script and cover data
$docker_scr --import ./common.sh
$docker_scr --import ./stego-attrib.sh
$docker_scr --import ./stego-attrib-test.sh
$docker_scr --import ./stego-attrib-test-protocol.txt
$docker_scr --import ./stego-utils-recompress.sh
$docker_scr --import ./stego-utils-generateDiagrams.sh
$docker_scr --import ./coverData

#copy file in docker /data directory
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
#importDockerRoot "./dev-artifacts/jpfix/jphide-auto" "./jphide-auto"
#importDockerRoot "./dev-artifacts/jpfix/jpseek-auto" "./jpseek-auto"

#copy stegbreak fixed data
importDockerRoot "./dev-artifacts/stegbreakfix/stegbreak-fix" "./stegbreak-fix"
importDockerRoot "./dev-artifacts/stegbreakfix/rules.ini" "./stegbreak-rules.ini"

#copy embedding data
importDockerRoot "./embeddingData/binaryEmbedding" "./embeddingBinary"
importDockerRoot "./embeddingData/longEmbedding.txt" "./embeddingLong.txt"
importDockerRoot "./embeddingData/lowEntropyEmbedding.txt" "./embeddingLowEntropy.txt"
importDockerRoot "./embeddingData/middleEmbedding.txt" "./embeddingMiddle.txt"
importDockerRoot "./embeddingData/shortEmbedding.txt" "./embeddingShort.txt"

echo "Done!"

exit 0