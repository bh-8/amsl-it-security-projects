#!/bin/bash

#basic print routines
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

#docker setup routine
function runSetup {
    sudo echo "Permission acquired!"

    #update apt
    sudo apt update

    #install docker
    sudo apt install docker.io -y

    #run config
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER

    printMessage "Done!"

    exit 0
}

#docker pull repository
function runPull {
    #download
    docker pull dominicbreuker/stego-toolkit

    exit 0
}

#docker run routine
function runDockerInstance {
    #run shell in container
    docker run -it --rm -v $(pwd)/data:/data dominicbreuker/stego-toolkit /bin/bash

    exit 0
}

#docker import routine
function runDockerImport {
    importObj="${1}"

    #check if object exists
    if [ ! -d "$importObj" ] && [ ! -f "$importObj" ]; then
        printNotFoundAndExit "$importObj"
    fi

    #get container id
    import_target_container=$(docker container ls | grep stego-toolkit | cut -d ' ' -f 1)
    
    #check if container is up and running
    if [ -z "$import_target_container" ]; then
        echo "Error: Could not find docker container."
        echo "       Make sure there is a docker instance running stego toolkit."
        exit 1
    fi

    printMessage "Importing '${importObj}' to docker container '${import_target_container}:/data'..."

    #copy data
    docker cp $importObj $import_target_container:/data

    exit 0
}

#check params
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

exit 0