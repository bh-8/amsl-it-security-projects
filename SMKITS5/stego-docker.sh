#!/bin/bash

function printMessage {
    echo "${1}"
}

function printErrorAndExit {
    echo "Syntax Error: Type '${0} --help' for help."
    exit 1
}

function printNotFoundAndExit {
    echo "Not-found Error: Could not find '${1}'."
    exit 1
}

function printHelpAndExit {
    echo "${0} <action> [parameters...]"
    echo "Actions:   -h, --help"
    echo "           -s, --setup"
    echo "           -p, --pull"
    echo "           -r, --run"
    echo "           -i, --import <directory | file>"
    exit 0
}

function runSetup {
    sudo echo "Permission acquired!"

    printMessage "Updating apt..."
    sudo apt update

    printMessage "Updating apt..."
    sudo apt upgrade -y

    printMessage "apt: docker.io"
    sudo apt install docker.io -y

    printMessage "Configuring docker..."
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

    printMessage "Done!"

    exit 0
}

function runPull {
    docker pull dominicbreuker/stego-toolkit

    exit 0
}

function runDockerInstance {
    docker run -it --rm -v $(pwd)/data:/data dominicbreuker/stego-toolkit /bin/bash

    exit 0
}

function runDockerImport {
    importObj="${1}"
    if [ ! -d "$importObj" ] && [ ! -f "$importObj" ]; then
        printNotFoundAndExit "$importObj"
    fi

    import_target_container=$(docker container ls | grep stego-toolkit | cut -d ' ' -f 1)
    
    if [ -z "$import_target_container" ]; then
        echo "Error: Could not find docker container."
        echo "       Make sure there is a docker instance running stego toolkit."
        exit 1
    fi

    printMessage "Importing '${importObj}' to docker container '${import_target_container}:/data'..."

    docker cp $importObj $import_target_container:/data

    exit 0
}

#Action supplied?
if [ $# -gt 0 ]; then
    case ${1} in
        --help|-h) printHelpAndExit;;
        --setup|-s) runSetup;;
        --pull|-p) runPull;;
        --run|-r) runDockerInstance;;
        --import|-i) runDockerImport "${2}";;
        *) printErrorAndExit;;
    esac
else
    printErrorAndExit
fi

exit