#!/bin/bash

archiveName=./stego-release.tar.gz
archiveInclude="coverData/ embeddingData/ utility/ slurm-jobscript.sh stego-attrib.sh stego-docker.sh"

if [ -f $archiveName ]; then
    rm -f $archiveName
fi

tar -vczf $archiveName $archiveInclude

exit