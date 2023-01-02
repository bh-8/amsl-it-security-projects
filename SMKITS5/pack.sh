#!/bin/bash

archiveName=./stego-release.tar.gz
archiveInclude="common.sh coverData/ dev-artifacts/ docs/ embeddingData/ README.md stego-attrib.sh stego-attrib-test.sh stego-attrib-test-protocol.txt stego-docker.sh stego-docker-importDefaults.sh stego-utils-buildTestset.sh stego-utils-generateDiagrams.sh stego-utils-recompress.sh"

if [ -f $archiveName ]; then
    rm -f $archiveName
fi

tar -vczf $archiveName $archiveInclude

exit 0
