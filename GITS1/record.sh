#!/bin/bash
#Version 6

#Argument supplied?
if [ $# -eq 0 ]; then
    echo "Error: Argument missing, Syntax: ./record.sh <phishingMailIdentifier>"
    echo "Aborted."
    exit
fi

PHISHING_MAIL_IDENTIFIER=$1

##################################################
# Config                                         #
##################################################

LINUX_HOME="/home/${USER}"

#Temporary output directory (will be wiped prior recording)
OUTPUT_DIRECTORY="${LINUX_HOME}/Schreibtisch/gitsRecording-${PHISHING_MAIL_IDENTIFIER}"

#Location of metadata
METADATA_LOCATION="${OUTPUT_DIRECTORY}/metadata.txt"

#Location of mitmproxy executable
MITMPROXY_EXECUTABLE="${LINUX_HOME}/opt/mitmproxy"

#Where to store keys and mitmproxy data (also save wireshark .pcapng file here)
SSLKEYLOGFILE_LOCATION="${OUTPUT_DIRECTORY}/sslkey.log"
MITMPROXY_OUTPUT="${OUTPUT_DIRECTORY}/mitmproxy.log"

#Where to find firefox sql stuff
FIREFOX_DBS="${LINUX_HOME}/.mozilla/firefox/9fwqaeub.tester"

#Where to store firefox sql stuff
FIREFOX_DBS_OUT="${OUTPUT_DIRECTORY}/firefox"

#Where to find thunderbird sql stuff
THUNDERBIRD_DBS="${LINUX_HOME}/.thunderbird/t6qhkkv7.default-default"

#Where to store thunderbird sql stuff
THUNDERBIRD_DBS_OUT="${OUTPUT_DIRECTORY}/thunderbird"

#Where to find evolution sql stuff
EVOLUTION_DBS="${LINUX_HOME}/.cache/evolution"

#Where to store evolution sql stuff
EVOLUTION_DBS_OUT="${OUTPUT_DIRECTORY}/evolution"

##################################################
# Check requirements                             #
##################################################

#Is mitmproxy available?
if [ ! -f $MITMPROXY_EXECUTABLE ]; then
    echo "Warning: mitmproxy not installed"
	read -p "Press [ENTER] to install it now (or Crtl+C to abort)" </dev/tty
	if [ ! -d "${LINUX_HOME}/opt" ]; then
		mkdir "${LINUX_HOME}/opt"
	fi
	echo "Downloading mitmproxy..."
	curl -s -o "${LINUX_HOME}/opt/mitmproxy.tar.gz" https://snapshots.mitmproxy.org/8.1.0/mitmproxy-8.1.0-linux.tar.gz
	echo "Extracting mitmproxy..."
	tar -xf "${LINUX_HOME}/opt/mitmproxy.tar.gz" --directory "${LINUX_HOME}/opt"
fi
if [ ! -f $MITMPROXY_EXECUTABLE ]; then
    echo "Error: Could not find mitmproxy-executable at '${MITMPROXY_EXECUTABLE}'"
    echo "Aborted."
    exit
fi

#Check if required commands installed
function checkCommandExistence() {
    cmd=$1
    
    if ! command -v $cmd &> /dev/null
    then
	    echo "Warning: ${cmd} not installed"
	    read -p "Press [ENTER] to install it now (or Crtl+C to abort)" </dev/tty
	    sudo apt-get update
	    sudo apt-get upgrade
	    sudo apt-get install $cmd
    fi
    if ! command -v $cmd &> /dev/null
    then
        echo "Error: ${cmd} not installed!"
        echo "Aborted."
        exit
    fi
}

checkCommandExistence "wireshark"
checkCommandExistence "thunderbird"
checkCommandExistence "evolution"
checkCommandExistence "sqlite3"

#Is firefox profile available?
if [ ! -d "$FIREFOX_DBS" ]; then
    echo "Error: Could not find firefox profile at '${FIREFOX_DBS}'"
    echo "Aborted."
    exit
fi

#Is thunderbird profile available?
if [ ! -d "$THUNDERBIRD_DBS" ]; then
    echo "Error: Could not find thunderbird profile at '${THUNDERBIRD_DBS}'"
    echo "Aborted."
    exit
fi

#Is evolution data available?
if [ ! -d "$EVOLUTION_DBS" ]; then
    echo "Error: Could not find evolution data at '${EVOLUTION_DBS}'"
    echo "Aborted."
    exit
fi

##################################################
# Preparation                                    #
##################################################

#Re-Set environment variables
unset HTTP_PROXY
unset HTTPS_PROXY
unset SSLKEYLOGFILE
export HTTP_PROXY=http://127.0.0.1:8080/
export HTTPS_PROXY=http://127.0.0.1:8080/
export SSLKEYLOGFILE=$SSLKEYLOGFILE_LOCATION

echo "Environment Variables:"
echo "  - HTTP_PROXY='${HTTP_PROXY}'"
echo "  - HTTPS_PROXY='${HTTPS_PROXY}'"
echo "  - SSLKEYLOGFILE='${SSLKEYLOGFILE}'"

#Delete output directory if exists
if [ -d "$OUTPUT_DIRECTORY" ]; then
    rm -d -r $OUTPUT_DIRECTORY
fi

echo "Finishing preparation:"

#Create output directory
mkdir $OUTPUT_DIRECTORY
echo "  - Created output directory '${OUTPUT_DIRECTORY}'"

#Create SSLKEYLOGFILE
touch $SSLKEYLOGFILE_LOCATION
echo "  - Created new ssl key log file '${SSLKEYLOGFILE_LOCATION}'"

#Ready to start recording
read -p "Press [ENTER] to start recording" </dev/tty

##################################################
# Recording                                      #
##################################################

echo "Starting mitmproxy, Firefox and Wireshark, this could take a while..."
TIMESTAMP_START=$(date +%s)
xterm -e "${MITMPROXY_EXECUTABLE} -w ${MITMPROXY_OUTPUT}" &
firefox -profile $FIREFOX_DBS &> /dev/null &
wireshark &> /dev/null &
thunderbird &> /dev/null &
evolution &> /dev/null &
{
    echo "IMPORTANT:"
    echo "  - Please set ssl key log file in Wireshark to '${SSLKEYLOGFILE_LOCATION}'"
    echo "  - Please start Wireshark recording manually"
    echo "  - Remember to save Wireshark .pcapng file to '${OUTPUT_DIRECTORY}/wireshark.pcapng'"
    echo "  - Timer started. Now do your research!"
    echo "Waiting for processes to be closed:"
    echo "  - mitmproxy"
    echo "  - Firefox"
    echo "  - Wireshark"
    echo "  - Thunderbird"
    echo "  - Evolution"
} & wait

#All closed
TIMESTAMP_END=$(date +%s)
TIMESPAN=$((TIMESTAMP_END-TIMESTAMP_START))
TIMESPAN_MIN=$(($((TIMESPAN/60))+2))
echo "All recordings stopped, took ${TIMESPAN} seconds (~${TIMESPAN_MIN} minutes)"

##################################################
# Dump recent changed databases                  #
##################################################

#Sql dumping
function textifyDatabase() {
    db_path=$1
    db_out=$2
    
    db_name=$(basename ${1})
    for l in $(sqlite3 $db_path "SELECT name FROM sqlite_master WHERE type='table'"); do
        sqlite3 $db_path ".schema ${l}" > "${db_out}/txt/${db_name}-${l}.txt"
        sqlite3 $db_path "SELECT * FROM ${l}" >> "${db_out}/txt/${db_name}-${l}.txt"
    done
}

#Loop directory by file extension
function loopDirectoryDatabases() {
    db_dir=$1
    db_out=$2
    timespan=$3
    
    mkdir $db_out
    mkdir "${db_out}/sqlite"
    mkdir "${db_out}/txt"
    
    counter=0
    for i in $(find $db_dir -mmin -$timespan -type f -name "*.sqlite"); do
        echo "  - ${i}"
        textifyDatabase $i $db_out
        fname=$(basename ${i})
        cp $i "${db_out}/sqlite/${fname}"
        counter=$((counter+1))
    done
    for i in $(find $db_dir -mmin -$timespan -type f -name "*.db"); do
        echo "  - ${i}"
        textifyDatabase $i $db_out
        fname=$(basename ${i})
        cp $i "${db_out}/sqlite/${fname}"
        counter=$((counter+1))
    done
    if [ "$counter" -eq "0" ]; then
        echo "  - nothing changed, nothing dumped"
    fi
    return $counter
}


#Store firefox sql databases
echo "Copying/Dumping firefox dbs..."
loopDirectoryDatabases $FIREFOX_DBS $FIREFOX_DBS_OUT $TIMESPAN_MIN
COUNTER_FIREFOX_DBS=$?

#Store thunderbird sql databases
echo "Copying/Dumping thunderbird dbs..."
loopDirectoryDatabases $THUNDERBIRD_DBS $THUNDERBIRD_DBS_OUT $TIMESPAN_MIN
COUNTER_THUNDERBIRD_DBS=$?

#Store evolution sql databases
echo "Copying/Dumping evolution dbs..."
loopDirectoryDatabases $EVOLUTION_DBS $EVOLUTION_DBS_OUT $TIMESPAN_MIN
COUNTER_EVOLUTION_DBS=$?

##################################################
# Metadata & Archive                             #
##################################################

#Write metadata
TIME_NOW=$(date --debug)
touch $METADATA_LOCATION
echo "Research Object Name (Mail Identifier): ${PHISHING_MAIL_IDENTIFIER}" > $METADATA_LOCATION
echo "Recording time: ${TIME_NOW}" >> $METADATA_LOCATION
echo "Recording duration/length: ${TIMESPAN} seconds" >> $METADATA_LOCATION
echo "Profile user name: ${USER}" >> $METADATA_LOCATION
echo "Probably related database changes (${TIMESPAN_MIN} minutes):" >> $METADATA_LOCATION
echo "  Firefox: ${COUNTER_FIREFOX_DBS}" >> $METADATA_LOCATION
echo "  Thunderbird: ${COUNTER_THUNDERBIRD_DBS}" >> $METADATA_LOCATION
echo "  Evolution: ${COUNTER_EVOLUTION_DBS}" >> $METADATA_LOCATION
echo "Metadata written to '${METADATA_LOCATION}'"

#Archive
OUTPUT_DIRECTORY_NAME=$(basename $OUTPUT_DIRECTORY)
ARCHIVE_LOCATION=$(realpath "${OUTPUT_DIRECTORY}/../${PHISHING_MAIL_IDENTIFIER}.tar.gz")
echo "Processing recorded data..."
cd $OUTPUT_DIRECTORY/..
tar -czvf $ARCHIVE_LOCATION $OUTPUT_DIRECTORY_NAME
echo "Created tar archive at '${ARCHIVE_LOCATION}'"

#EOF

