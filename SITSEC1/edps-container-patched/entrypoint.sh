#!/bin/bash
internalOutput="/home/wec/edps-results"
volumeOutput="/home/wec/edps-output"

if [ "$#" -ne 1 ]; then
    echo "Error: No URL argument specified!"
    exit 255
fi
targetUrl="$@"
outId="$(echo $targetUrl | rev | cut -d "." -f 2 | cut -d "/" -f 1 | rev)-$(date +%s)"

echo "==> WEC permissions: $(id wec)"

echo "==> Executing './bin/website-evidence-collector.js --overwrite --output $internalOutput --testssl --testssl-executable /home/wec/testssl.sh/testssl.sh $targetUrl'..."
./bin/website-evidence-collector.js --overwrite --output $internalOutput --testssl --testssl-executable /home/wec/testssl.sh/testssl.sh $targetUrl
returnCode=$?

echo "==> Copying and Archiving results..."

cp -r $internalOutput $volumeOutput/edps-$outId

cd ../
tar -cvzf "$volumeOutput/edps-$outId.tar.gz" $(echo $internalOutput | rev | cut -d "/" -f 1 | rev)

if [ -f "$volumeOutput/edps-$outId.tar.gz" ]; then
    echo "==> Results saved to '$volumeOutput/edps-$outId.tar.gz'."
else
    echo "==> Failed!"
    exit 254
fi
exit $returnCode
