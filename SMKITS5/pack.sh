#!/bin/bash

archiveName=./stego-release.tar.gz
archiveInclude="coverData/ dev-artifacts/ docs/ embeddingData/ dev-artifacts/ common.sh README.md stego-attrib.sh stego-docker.sh stego-docker-importDefaults.sh stego-utils-buildTestset.sh stego-utils-generateDiagrams.sh stego-utils-recompressAndDiffCC.sh stego-utils-testAttrib.sh"

if [ -f $archiveName ]; then
    rm -f $archiveName
fi

tar -vczf $archiveName $archiveInclude

exit 0
