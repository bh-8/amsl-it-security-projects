#!/bin/bash

##### Static Defines #####

COL_OFF='\033[0m'
COL_ERR='\033[1;31m'

COL_1='\033[0;36m'
COL_2='\033[1;33m'
COL_3='\033[0;37m'

COL_YES='\033[1;32m'
COL_NO='\033[1;31m'

RE_NUMERIC='^[0-9]+$'

function printError {
    echo -e "[${COL_ERR}!${COL_OFF}] ${COL_ERR}Error${COL_OFF}: ${1}"
}

function printUsage {
    echo -e "${COL_2}Usage${COL_OFF}: ${0} <params>"
}

function printHelpAndExit {
    printUsage
    echo "    --help"
    echo "    --testset <directory>   Path to test data (mandatory)"
    echo "    --size <n>              Size of subset (default is 3)"
    echo "    --shuffle               Use random subset"
    echo "    --outfile <file>        Store results in file"
    exit
}

function printErrorAndExit {
    printError "${1}"
    exit
}

function printLine {
    echo -e "${COL_1}> ${COL_OFF}${1}"
}

STEGO_TOOLKIT_INTERFACE_CHECK_JPG="check_jpg.sh"
COVER_IMAGE_EXTENSION="*.jpg"

##### Dynamic Parameters #####

if [ $# -eq 0 ] || [ $1 = "--help" ]; then
    printHelpAndExit
fi

PARAM_TESTSET=""
PARAM_SIZE=3
PARAM_SHUFFLE=0
PARAM_OUTFILE=""

i=1
for param in $@; do
    j=$((i+1))
    next_param=${!j}

    case $param in
        --testset)
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires a path to a directory!"
            fi
            PARAM_TESTSET=$next_param ;;
        --size)
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires an integer!"
            fi
            PARAM_SIZE=$next_param ;;
        --shuffle)
            PARAM_SHUFFLE=1 ;;
        --outfile)
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires a path to a file!"
            fi
            PARAM_OUTFILE=$next_param ;;
        *) ;;
    esac

    i=$j
done

if [ -z $PARAM_TESTSET ]; then
    printErrorAndExit "Parameter '--testset' not specified!"
fi

if [ ! -d $PARAM_TESTSET ]; then
    printErrorAndExit "Could not find test set at '$(realpath $PARAM_TESTSET)'!"
fi

if ! [[ $PARAM_SIZE =~ $RE_NUMERIC ]] || [ $PARAM_SIZE -le 0 ]; then
    printErrorAndExit "'$PARAM_SIZE' is not a numeric expression or too small!"
fi

if [ ! -z $PARAM_OUTFILE ] && [ -f $PARAM_OUTFILE ]; then
    printErrorAndExit "File '$PARAM_OUTFILE' does already exist!"
fi

#TODO!!!!!!!!!!!!!!!!!!!!!!!!!
#--out-format <json/csv>   Format

##### Check Environment #####

#TODO: check automatically???
echo "Info: This script is supposed to run in docker container."

JPGS_FOUND=$(find $PARAM_TESTSET -maxdepth 1 -type f -name $COVER_IMAGE_EXTENSION | wc -l)

if [ $JPGS_FOUND -eq 0 ]; then
    printErrorAndExit "Cover image directory does not contain any '$COVER_IMAGE_EXTENSION' files."
fi

if [ $PARAM_SIZE -gt $JPGS_FOUND ]; then
    printErrorAndExit "There are only ${COL_2}$JPGS_FOUND${COL_OFF} objects in test set!"
fi

##### Print Header #####
echo ""
echo -e "${COL_3}  #################################################${COL_OFF}"
echo -e "${COL_3}  #                                               #${COL_OFF}"
echo -e "${COL_3}  #              ${COL_OFF}SMKITS: ${COL_1}StegoDetect${COL_3}              #${COL_OFF}"
echo -e "${COL_3}  #       ${COL_2}Attribution of potential embedded${COL_3}       #${COL_OFF}"
echo -e "${COL_3}  #             ${COL_2}hidden communication.${COL_3}             #${COL_OFF}"
echo -e "${COL_3}  #                                               #${COL_OFF}"
echo -e "${COL_3}  #################################################${COL_OFF}"
echo ""
printLine "Testset location is '${COL_3}$PARAM_TESTSET${COL_OFF}'."
printLine "Going to analyse ${COL_2}$PARAM_SIZE${COL_OFF}/${COL_2}$JPGS_FOUND${COL_OFF} $COVER_IMAGE_EXTENSION-file-samples..."

SORTING_PARAM="-dr"
if [ $PARAM_SHUFFLE -eq 1 ]; then
    SORTING_PARAM="-R"
    printLine "Testset shuffled."
fi

if [ ! -z $PARAM_OUTFILE ]; then
    printLine "Results will be stored in '${COL_3}$PARAM_OUTFILE${COL_OFF}'."
    echo "file;stegdetect;outguess;jsteg">$PARAM_OUTFILE
fi

echo ""

##### Perform Analysis #####

rm -f output*.txt

#Option für bilder in reihenfolge, zufällige auswahl, ...

#Loop samples
find $PARAM_TESTSET -maxdepth 1 -type f -name $COVER_IMAGE_EXTENSION | sort $SORTING_PARAM | tail -$PARAM_SIZE | while read SAMPLE; do
    DATETIME_NOW=$(date "+%F-%H-%M-%S")
    printLine "${COL_3}[${COL_OFF}$DATETIME_NOW${COL_3}] ${COL_2}Analysing${COL_OFF} '${COL_1}$SAMPLE${COL_OFF}'..."
    ANALYSIS_OUTPUT="output$(basename $SAMPLE).txt"

    DETECT_COUNT=0

    #Run stego toolkit on sample file
    $STEGO_TOOLKIT_INTERFACE_CHECK_JPG "$SAMPLE" &> $ANALYSIS_OUTPUT

    ##### StegDetect #####
    #'negative', 'skipped (false positive likely)', ...
    OUT_STEGDETECT=$(grep -A 2 "########## stegdetect ##########" "$ANALYSIS_OUTPUT" | tail -1 | rev | cut -d ':' -f 1 | rev | xargs)
    echo -n -e "  ${COL_2}> ${COL_3}[${COL_1}StegDetect${COL_3}] ${COL_OFF}'${COL_3}$OUT_STEGDETECT${COL_OFF}'"

    if [ ! "$OUT_STEGDETECT" = "negative" ]; then
        echo -e " --> ${COL_NO}Image may has something embedded${COL_OFF}."
        DETECT_COUNT=$((DETECT_COUNT+1))
    else
        echo -e " --> ${COL_YES}No Result${COL_OFF}."
    fi

    ##### OutGuess #####
    #'0', ...
    OUT_OUTGUESS=$(grep -A 6 "########## outguess ##########" "$ANALYSIS_OUTPUT" | tail -1)
    echo -n -e "  ${COL_2}> ${COL_3}[${COL_1}OutGuess${COL_3}] ${COL_OFF}'${COL_3}$OUT_OUTGUESS${COL_OFF}'"

    if [ ! "$OUT_OUTGUESS" = "Probably no result..." ]; then
        echo -e " --> ${COL_NO}Image may has something embedded${COL_OFF}."
        DETECT_COUNT=$((DETECT_COUNT+1))
    else
        echo -e " --> ${COL_YES}No Result${COL_OFF}."
    fi

    ##### jsteg #####
    OUT_JSTEG=$(grep -A 2 "########## jsteg ##########" "$ANALYSIS_OUTPUT" | tail -1)
    echo -n -e "  ${COL_2}> ${COL_3}[${COL_1}JSteg${COL_3}] ${COL_OFF}'${COL_3}$OUT_JSTEG${COL_OFF}'"

    if [ ! "$OUT_JSTEG" = "jpeg does not contain hidden data" ]; then
        echo -e " --> ${COL_NO}Image may has something embedded${COL_OFF}."
        DETECT_COUNT=$((DETECT_COUNT+1))
    else
        echo -e " --> ${COL_YES}No Result${COL_OFF}."
    fi
    
    #Output
    echo -n -e "  ${COL_2}> ${COL_OFF}Detects of sample: ${COL_1}$DETECT_COUNT${COL_OFF}"

    if [ ! $DETECT_COUNT -eq 0 ]; then
        echo -e " --> ${COL_NO}Attributierung${COL_OFF}..."
        #TODO: Attributierung hier!!!!!!!!!!!!!!!!!!!!!!!!!
    else
        echo -e " --> ${COL_YES}No action required${COL_OFF}."
    fi

    #Output file
    #TODO: contain more details, stegoVeritas, resolution, ..
    if [ ! -z $PARAM_OUTFILE ]; then
        echo "$SAMPLE;$OUT_STEGDETECT;$OUT_OUTGUESS;$OUT_JSTEG">>$PARAM_OUTFILE
    fi

    echo ""
done

exit