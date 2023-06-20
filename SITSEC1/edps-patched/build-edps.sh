#!/bin/bash
if [ ! -f "./browser-session.js" ]; then
    wget -O ./browser-session.js https://gitlab.informatik.uni-halle.de/ajpqa/ovgu/-/raw/main/docker/website-evidence-collector/browser-session.js
fi
if [ -f "./browser-session.js" ]; then
    DOCKER_BUILDKIT=1 docker build --tag edps_patched .
    exit 0
else
    echo "Error: File 'browser-session.js' not found!"
    exit 1
fi
