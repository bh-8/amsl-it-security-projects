#!/bin/bash

##### Static Defines #####

#color codes
COL_OFF='\033[0m'
COL_ERR='\033[1;31m'

COL_1='\033[1;36m'
COL_2='\033[1;33m'
COL_3='\033[0;37m'

COL_YES='\033[1;32m'
COL_NO='\033[1;31m'

#RegExp to validate numeric expression
RE_NUMERIC='^[0-9]+$'

#script output directory for analysis
GENERAL_OUTPUT_DIRECTORY=$(realpath "./out-stego-attrib")

#script output directory for testset
TESTSET_OUTPUT_DIRECTORY=$GENERAL_OUTPUT_DIRECTORY/testset

#example secret text links
SECRET_LINK_SHORT="https://loremipsum.de/downloads/version3.txt"
SECRET_LINK_LONG="https://loremipsum.de/downloads/version5.txt"
SECRET_SHORT=$GENERAL_OUTPUT_DIRECTORY/secret_short.txt
SECRET_LONG=$GENERAL_OUTPUT_DIRECTORY/secret_long.txt

PASSPHRASE_SHORT="EXAMPLE"
PASSPHRASE_LONG="THIS_IS_A_PRETTY_LONG_PASSPHRASE_TRUST_ME_ITS_HUGE"

#print formatted error message
function printError {
    echo -e "${COL_2}> ${COL_3}[${COL_ERR}!${COL_3}] ${COL_ERR}Error${COL_OFF}: ${1}"
}

#print script usage
function printUsage {
    echo -e "${COL_2}Usage${COL_OFF}: ${0} <params>"
}

#print help and exit
function printHelpAndExit {
    printUsage
    echo "    --generate-testset <directory>   Use jpgs in path as cover data for stego"
    echo "    --testset <directory>            Check jpgs in path for stego"
    echo "    -n, --size <n>                   Size of subset (default is 1)"
    echo "    -s, --shuffle                    Use random subset"
    echo "    -c, --clean                      Clean output directory"
    echo "    -h, --help"
    exit
}

#call printError and exit
function printErrorAndExit {
    printError "${1}"
    exit
}

#formats for outputs
function printLine0 {
    echo -e "${COL_1}> ${COL_3}[${COL_1}${1}${COL_3}]${COL_OFF} ${2}"
}
function printLine1 {
    echo -e "  ${COL_2}> ${COL_3}[${COL_2}${1}${COL_3}]${COL_OFF} ${2}"
}
function printLine2 {
    echo -e "    ${COL_3}> ${COL_3}[${COL_3}${1}${COL_3}]${COL_OFF} ${2}"
}
function formatPath {
    RETVAL="${COL_OFF}'${COL_3}${1}${COL_OFF}'"
}
#TODO: currently unused:
function formatCurrentTimestamp {
    DATETIME_NOW=$(date "+%F %H:%M:%S")
    RETVAL="${COL_3}$DATETIME_NOW${COL_OFF}"
}

#target image extension
GENERAL_IMAGE_EXTENSION=*.jpg

#docker should not be available inside docker environment, if so, script might run outside of docker!
if command -v docker &> /dev/null
then
    printErrorAndExit "This script is meant to be executed in a docker environment!"
fi

##### Dynamic Parameters #####

#check for help
if [ $# -eq 0 ] || [ $1 = "--help" ] || [ $1 = "-h" ]; then
    printHelpAndExit
fi

#variables to store parameters
PARAM_GENERATE_TESTSET=""
PARAM_TESTSET=""
PARAM_SIZE=1
PARAM_SHUFFLE=0
PARAM_CLEAN=0

#loop parameters
i=1
for param in $@; do
    j=$((i+1))
    next_param=${!j}

    case $param in
        --generate-testset)
            #check if path is given
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires a path to a directory!"
            fi
            PARAM_GENERATE_TESTSET=$next_param ;;
        --testset)
            #check if path is given
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires a path to a directory!"
            fi
            PARAM_TESTSET=$next_param ;;
        --size|-n)
            #check if number is given
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires an integer!"
            fi
            PARAM_SIZE=$next_param ;;
        --shuffle|-s)
            PARAM_SHUFFLE=1 ;;
        --clean|-c)
            PARAM_CLEAN=1 ;;
        *) ;;
    esac

    i=$j
done

##### Check Environment #####

#script needs at least --generate-testset or/and --testset parameter to do something
if [ -z $PARAM_GENERATE_TESTSET ] && [ -z $PARAM_TESTSET ]; then
    printErrorAndExit "Parameter '--generate-testset' or '--testset' not specified!"
fi

#check if size is an integer
if ! [[ $PARAM_SIZE =~ $RE_NUMERIC ]] || [ $PARAM_SIZE -le 0 ]; then
    printErrorAndExit "'$PARAM_SIZE' is not a numeric expression or too small!"
fi

##### Print Header #####

clear
echo ""
echo -e "${COL_3}  #################################################${COL_OFF}"
echo -e "${COL_3}  #                                               #${COL_OFF}"
echo -e "${COL_3}  #              ${COL_OFF}SMKITS: ${COL_1}StegoDetect${COL_3}              #${COL_OFF}"
echo -e "${COL_3}  #       ${COL_2}Attribution of potential embedded${COL_3}       #${COL_OFF}"
echo -e "${COL_3}  #             ${COL_2}hidden communication.${COL_3}             #${COL_OFF}"
echo -e "${COL_3}  #                                               #${COL_OFF}"
echo -e "${COL_3}  #################################################${COL_OFF}"
echo ""

#perform cleanup
if [ $PARAM_CLEAN -eq 1 ]; then
    printLine0 "--clean" "Cleaning output directory..."
    if [ -d "$GENERAL_OUTPUT_DIRECTORY" ]; then
        rm -dr "$GENERAL_OUTPUT_DIRECTORY"
    fi
fi

#set parameter for sorting/shuffle
SORTING_PARAM="-dr"
if [ $PARAM_SHUFFLE -eq 1 ]; then
    SORTING_PARAM="-R"
    printLine0 "--shuffle" "Image selection will be randomized."
fi

######################################
##### Perform testset generation #####
######################################

#if testset generation is required
if [ ! -z $PARAM_GENERATE_TESTSET ]; then
    PARAM_GENERATE_TESTSET=$(realpath $PARAM_GENERATE_TESTSET)

    #check if cover data directory exists
    if [ ! -d $PARAM_GENERATE_TESTSET ]; then
        formatPath $PARAM_GENERATE_TESTSET
        printErrorAndExit "Could not find cover data at $RETVAL!"
    fi

    #count jpg files in cover directory
    JPGS_FOUND_COVER=$(find $PARAM_GENERATE_TESTSET -maxdepth 1 -type f -name $GENERAL_IMAGE_EXTENSION | wc -l)

    #check if there are any jpg files available
    if [ $JPGS_FOUND_COVER -eq 0 ]; then
        formatPath $GENERAL_IMAGE_EXTENSION
        printErrorAndExit "Cover image directory does not contain any $RETVAL files."
    fi

    #check if subset size is smaller or equal number of available files
    if [ $PARAM_SIZE -gt $JPGS_FOUND_COVER ]; then
        printErrorAndExit "There are only ${COL_2}$JPGS_FOUND_COVER${COL_OFF} objects in specified directory!"
    fi

    formatPath $PARAM_GENERATE_TESTSET
    printLine0 "--generate-testset" "Cover location is $RETVAL."
    formatPath $GENERAL_IMAGE_EXTENSION
    printLine0 "embedding started" "Going to embed data to ${COL_2}$PARAM_SIZE${COL_OFF} of a total of ${COL_2}$JPGS_FOUND_COVER${COL_OFF} available $RETVAL-file-samples..."

    #make sure output directory exists
    if [ ! -d "$GENERAL_OUTPUT_DIRECTORY" ]; then
        mkdir $GENERAL_OUTPUT_DIRECTORY
    fi

    #retrieve example text to embed
    #TODO: no download if exists!!!!!!!!!!!!!!
    wget -N "$SECRET_LINK_SHORT" -O "$SECRET_SHORT" &> /dev/null
    wget -N "$SECRET_LINK_LONG" -O "$SECRET_LONG" &> /dev/null

    BASENAME_EXTENSION=${GENERAL_IMAGE_EXTENSION:1}

    #Loop samples
    C=0
    find $PARAM_GENERATE_TESTSET -maxdepth 1 -type f -name $GENERAL_IMAGE_EXTENSION | sort $SORTING_PARAM | tail -$PARAM_SIZE | while read SAMPLE; do
        C=$((C+1))
        
        SAMPLE_BASENAME_NO_EXT=$(basename $SAMPLE $BASENAME_EXTENSION)
        SAMPLE_BASENAME=$(basename $SAMPLE)

        formatPath $SAMPLE
        printLine0 "embed stego" "${COL_2}$C${COL_OFF}/${COL_2}$PARAM_SIZE${COL_OFF}: Embedding data in cover $RETVAL..."
        
        #create output directories
        if [ ! -d "$GENERAL_OUTPUT_DIRECTORY" ]; then
            mkdir $GENERAL_OUTPUT_DIRECTORY
        fi
        if [ ! -d "$TESTSET_OUTPUT_DIRECTORY" ]; then
            mkdir $TESTSET_OUTPUT_DIRECTORY
        fi


        #copy original cover to testset
        NEW_COVER_LOCATION=$TESTSET_OUTPUT_DIRECTORY/$SAMPLE_BASENAME
        cp $SAMPLE $NEW_COVER_LOCATION
        formatPath $NEW_COVER_LOCATION
        printLine1 "copy" "Original cover copied to $RETVAL"
        
        #doing stego
        printLine1 "jphide" "TODO: interactive prompt needs to be answered automatically!"
        #jphide cover.jpg stego.jpg secret.txt
        STEGO_LOCATION=$TESTSET_OUTPUT_DIRECTORY/$SAMPLE_BASENAME_NO_EXT-jphide
        #printf "$PASSPHRASE_SHORT\n$PASSPHRASE_SHORT" | jphide $NEW_COVER_LOCATION $STEGO_LOCATION-short$BASENAME_EXTENSION $SECRET_SHORT
        #printf "$PASSPHRASE_SHORT\n$PASSPHRASE_SHORT" | jphide $NEW_COVER_LOCATION $STEGO_LOCATION-long$BASENAME_EXTENSION $SECRET_LONG

        printLine1 "jsteg"
        STEGO_LOCATION=$TESTSET_OUTPUT_DIRECTORY/$SAMPLE_BASENAME_NO_EXT-jsteg
        jsteg hide $NEW_COVER_LOCATION $SECRET_SHORT $STEGO_LOCATION-short$BASENAME_EXTENSION
        jsteg hide $NEW_COVER_LOCATION $SECRET_LONG $STEGO_LOCATION-long$BASENAME_EXTENSION

        printLine1 "outguess"
        STEGO_LOCATION=$TESTSET_OUTPUT_DIRECTORY/$SAMPLE_BASENAME_NO_EXT-outguess
        outguess -k $PASSPHRASE_SHORT -d $SECRET_SHORT $NEW_COVER_LOCATION $STEGO_LOCATION-short-short$BASENAME_EXTENSION
        outguess -k $PASSPHRASE_SHORT -d $SECRET_LONG $NEW_COVER_LOCATION $STEGO_LOCATION-short-long$BASENAME_EXTENSION
        outguess -k $PASSPHRASE_LONG -d $SECRET_SHORT $NEW_COVER_LOCATION $STEGO_LOCATION-long-short$BASENAME_EXTENSION
        outguess -k $PASSPHRASE_LONG -d $SECRET_LONG $NEW_COVER_LOCATION $STEGO_LOCATION-long-long$BASENAME_EXTENSION

        printLine1 "outguess-0.13"
        STEGO_LOCATION=$TESTSET_OUTPUT_DIRECTORY/$SAMPLE_BASENAME_NO_EXT-outguess-0.13
        outguess-0.13 -k $PASSPHRASE_SHORT -d $SECRET_SHORT $NEW_COVER_LOCATION $STEGO_LOCATION-short-short$BASENAME_EXTENSION
        outguess-0.13 -k $PASSPHRASE_SHORT -d $SECRET_LONG $NEW_COVER_LOCATION $STEGO_LOCATION-short-long$BASENAME_EXTENSION
        outguess-0.13 -k $PASSPHRASE_LONG -d $SECRET_SHORT $NEW_COVER_LOCATION $STEGO_LOCATION-long-short$BASENAME_EXTENSION
        outguess-0.13 -k $PASSPHRASE_LONG -d $SECRET_LONG $NEW_COVER_LOCATION $STEGO_LOCATION-long-long$BASENAME_EXTENSION

        printLine1 "steghide"
        STEGO_LOCATION=$TESTSET_OUTPUT_DIRECTORY/$SAMPLE_BASENAME_NO_EXT-steghide
        steghide embed -f -ef $SECRET_SHORT -cf $NEW_COVER_LOCATION -p $PASSPHRASE_SHORT -sf $STEGO_LOCATION-short-short$BASENAME_EXTENSION
        steghide embed -f -ef $SECRET_LONG -cf $NEW_COVER_LOCATION -p $PASSPHRASE_SHORT -sf $STEGO_LOCATION-short-long$BASENAME_EXTENSION
        steghide embed -f -ef $SECRET_SHORT -cf $NEW_COVER_LOCATION -p $PASSPHRASE_LONG -sf $STEGO_LOCATION-long-short$BASENAME_EXTENSION
        steghide embed -f -ef $SECRET_LONG -cf $NEW_COVER_LOCATION -p $PASSPHRASE_LONG -sf $STEGO_LOCATION-long-long$BASENAME_EXTENSION

        printLine1 "f5"
        STEGO_LOCATION=$TESTSET_OUTPUT_DIRECTORY/$SAMPLE_BASENAME_NO_EXT-f5
        #TODO: no password too????
        f5 -t e -i $NEW_COVER_LOCATION -o $STEGO_LOCATION-short-short$BASENAME_EXTENSION -p $PASSPHRASE_SHORT -d '$(cat $SECRET_SHORT)'
        f5 -t e -i $NEW_COVER_LOCATION -o $STEGO_LOCATION-short-long$BASENAME_EXTENSION -p $PASSPHRASE_SHORT -d '$(cat $SECRET_LONG)'
        f5 -t e -i $NEW_COVER_LOCATION -o $STEGO_LOCATION-long-short$BASENAME_EXTENSION -p $PASSPHRASE_LONG -d '$(cat $SECRET_SHORT)'
        f5 -t e -i $NEW_COVER_LOCATION -o $STEGO_LOCATION-long-long$BASENAME_EXTENSION -p $PASSPHRASE_LONG -d '$(cat $SECRET_LONG)'
    done

    formatPath $GENERAL_IMAGE_EXTENSION
    printLine0 "embedding finished" "Embedded data to ${COL_2}$PARAM_SIZE${COL_OFF} $RETVAL-file-samples."
fi

############################
##### Perform Analysis #####
############################

#if testset analysis is required
if [ ! -z $PARAM_TESTSET ]; then
    PARAM_TESTSET=$(realpath $PARAM_TESTSET)

    #check if given testset directory exists
    if [ ! -d $PARAM_TESTSET ]; then
        formatPath $PARAM_TESTSET
        printErrorAndExit "Could not find test set at $RETVAL!"
    fi

    #count available jpg files in testset
    JPGS_FOUND_TESTSET=$(find $PARAM_TESTSET -maxdepth 1 -type f -name $GENERAL_IMAGE_EXTENSION | wc -l)

    #check if there are any jpg files available
    if [ $JPGS_FOUND_TESTSET -eq 0 ]; then
        formatPath $GENERAL_IMAGE_EXTENSION
        printErrorAndExit "Testset directory does not contain any $RETVAL files."
    fi

    #check if subset size is smaller or equal number of available files
    if [ $PARAM_SIZE -gt $JPGS_FOUND_TESTSET ]; then
        printErrorAndExit "There are only ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} objects in specified directory!"
    fi

    formatPath $PARAM_TESTSET
    printLine0 "--testset" "Testset location is $RETVAL."
    formatPath $GENERAL_IMAGE_EXTENSION
    printLine0 "stego analysis started" "Going to analyse ${COL_2}$PARAM_SIZE${COL_OFF} stego samples of a total of ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} available $RETVAL-file-samples..."

    #make sure output directory exists
    if [ ! -d "$GENERAL_OUTPUT_DIRECTORY" ]; then
        mkdir $GENERAL_OUTPUT_DIRECTORY
    fi

    #Loop samples
    C=0
    find $PARAM_TESTSET -maxdepth 1 -type f -name $GENERAL_IMAGE_EXTENSION | sort $SORTING_PARAM | tail -$PARAM_SIZE | while read SAMPLE; do
        C=$((C+1))

        formatPath $SAMPLE
        printLine0 "stego analysis" "${COL_2}$C${COL_OFF}/${COL_2}$PARAM_SIZE${COL_OFF}: Analysing image $RETVAL..."
        
        SAMPLE_OUTPUT_DIRECTORY="$GENERAL_OUTPUT_DIRECTORY/$(basename $SAMPLE)"

        DETECT_COUNT=0

        #create output directory
        if [ -d "$SAMPLE_OUTPUT_DIRECTORY" ]; then
            rm -dr "$SAMPLE_OUTPUT_DIRECTORY"
        fi
        mkdir "$SAMPLE_OUTPUT_DIRECTORY"

        formatPath $SAMPLE_OUTPUT_DIRECTORY/*
        printLine1 "output" "Data will be saved to $RETVAL."
        
        #General Screening Tools
        printLine1 "general screening tools"
        
        formatPath $SAMPLE
        FPATH_SAMPLE=$RETVAL

        #file <sample>
        printLine2 "exec" "file $FPATH_SAMPLE"
        file $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/file.out

        #exiftool <sample>
        printLine2 "exec" "exiftool $FPATH_SAMPLE"
        exiftool $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/exiftool.out

        #binwalk <sample>
        printLine2 "exec" "binwalk $FPATH_SAMPLE"
        binwalk $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/binwalk.out

        #strings <sample>
        printLine2 "exec" "strings $FPATH_SAMPLE"
        strings $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/strings.out

        #foremost -o <output-dir> -i <sample>
        formatPath $SAMPLE_OUTPUT_DIRECTORY/foremost
        printLine2 "exec" "foremost -i $FPATH_SAMPLE -o $RETVAL"
        foremost -o $SAMPLE_OUTPUT_DIRECTORY/foremost -i $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/foremost.out

        #identify -verbose <sample>
        printLine2 "exec" "identify -verbose $FPATH_SAMPLE"
        identify -verbose $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/identify.out
        
        #Tools detecting steganography
        printLine1 "stego detecting tools"
        
        #stegdetect <sample>
        printLine2 "exec" "stegdetect $FPATH_SAMPLE"
        stegdetect $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/stegdetect.out

        #outguess -r <sample> <output-file>
        formatPath $SAMPLE_OUTPUT_DIRECTORY/outguess.extracted.out
        printLine2 "exec" "outguess -r $FPATH_SAMPLE $RETVAL"
        outguess -r $SAMPLE $SAMPLE_OUTPUT_DIRECTORY/outguess.extracted.out &>$SAMPLE_OUTPUT_DIRECTORY/outguess.out
        
        #outguess-0.13 -r <sample> <output-file>
        formatPath $SAMPLE_OUTPUT_DIRECTORY/outguess-0.13.extracted.out
        printLine2 "exec" "outguess-0.13 -r $FPATH_SAMPLE $RETVAL"
        outguess-0.13 -r $SAMPLE $SAMPLE_OUTPUT_DIRECTORY/outguess-0.13.extracted.out &>$SAMPLE_OUTPUT_DIRECTORY/outguess-0.13.out

        #jsteg reveal <sample>
        printLine2 "exec" "jsteg reveal $FPATH_SAMPLE"
        jsteg reveal $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/jsteg.out

        #stegoveritas <sample> -out <output-dir> -meta -imageTransform -colorMap -trailing -steghide -xmp -carve
        formatPath $SAMPLE_OUTPUT_DIRECTORY/stegoveritas
        printLine2 "exec" "stegoveritas $FPATH_SAMPLE -out $RETVAL -meta -imageTransform -colorMap -trailing -steghide -xmp -carve"
        stegoveritas $SAMPLE -out $SAMPLE_OUTPUT_DIRECTORY/stegoveritas -meta -imageTransform -colorMap -trailing -steghide -xmp -carve &>$SAMPLE_OUTPUT_DIRECTORY/stegoveritas.out

        #Analysis
        printLine1 "evaluation"

        ###########################
        #TODO: CHECK OUT FILES HERE

        #cat $SAMPLE_OUTPUT_DIRECTORY/file.out
        RES_FILE=$(cat $SAMPLE_OUTPUT_DIRECTORY/file.out | cut -d ":" -f 2 | xargs)
        #echo $RES_FILE
        RES_FILE_FORMAT=$(echo "$RES_FILE" | cut -d "," -f 1 | xargs)
        #echo "FILE - FORMAT: '$RES_FILE_FORMAT'"
        RES_FILE_JFIF=$(echo "$RES_FILE" | cut -d "," -f 2 | xargs)
        #echo "FILE - JFIF: '$RES_FILE_JFIF'"
        RES_FILE_RES=$(echo "$RES_FILE" | cut -d "," -f 8 | xargs)
        #echo "FILE - RESOLUTION: '$RES_FILE_RES'"

        #cat $SAMPLE_OUTPUT_DIRECTORY/exiftool.out
        RES_EXIFTOOL_FORMAT=$(cat $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | grep "File Type" | head -1 | cut -d ":" -f 2 | xargs)
        RES_EXIFTOOL_JFIF=$(cat $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | grep "JFIF Version" | cut -d ":" -f 2 | xargs)
        RES_EXIFTOOL_RES=$(cat $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | grep "Image Size" | cut -d ":" -f 2 | xargs)
        
        #echo "EXIFTOOL - FORMAT: '$RES_EXIFTOOL_FORMAT'"
        #echo "EXIFTOOL - JFIF: '$RES_EXIFTOOL_JFIF'"
        #echo "EXIFTOOL - RESOLUTION: '$RES_EXIFTOOL_RES'"

        #echo ""
        #cat $SAMPLE_OUTPUT_DIRECTORY/binwalk.out

        #cat $SAMPLE_OUTPUT_DIRECTORY/strings.out

        #cat $SAMPLE_OUTPUT_DIRECTORY/foremost/audit.txt
        #cat $SAMPLE_OUTPUT_DIRECTORY/identify.out

        ###########################

        #stegdetect
        RES_STEGDETECT=$(cat $SAMPLE_OUTPUT_DIRECTORY/stegdetect.out | cut -d ":" -f 2 | xargs)
        if [ "$RES_STEGDETECT" != "negative" ]; then
            DETECT_COUNT=$((DETECT_COUNT+1))
            printLine2 "stegdetect" "${COL_NO}$RES_STEGDETECT${COL_OFF}"
        else
            printLine2 "stegdetect" "${COL_YES}$RES_STEGDETECT${COL_OFF}"
        fi

        #outguess
        RES_OUTGUESS1=$(tr -d '\0' < $SAMPLE_OUTPUT_DIRECTORY/outguess.extracted.out)
        RES_OUTGUESS1=${#RES_OUTGUESS1}
        if [ $RES_OUTGUESS1 -ne 0 ]; then
            DETECT_COUNT=$((DETECT_COUNT+1))
            printLine2 "outguess" "result length is ${COL_NO}$RES_OUTGUESS1${COL_OFF}"
        else
            printLine2 "outguess" "result length is ${COL_YES}$RES_OUTGUESS1${COL_OFF}"
        fi

        #outguess-0.13
        RES_OUTGUESS2=$(tr -d '\0' < $SAMPLE_OUTPUT_DIRECTORY/outguess-0.13.extracted.out)
        RES_OUTGUESS2=${#RES_OUTGUESS2}
        if [ $RES_OUTGUESS2 -ne 0 ]; then
            DETECT_COUNT=$((DETECT_COUNT+1))
            printLine2 "outguess-0.13" "result length is ${COL_NO}$RES_OUTGUESS2${COL_OFF}"
        else
            printLine2 "outguess-0.13" "result length is ${COL_YES}$RES_OUTGUESS2${COL_OFF}"
        fi

        #jsteg
        RES_JSTEG=$(cat $SAMPLE_OUTPUT_DIRECTORY/jsteg.out)
        if [ "$RES_JSTEG" != "jpeg does not contain hidden data" ]; then
            DETECT_COUNT=$((DETECT_COUNT+1))
            printLine2 "jsteg" "${COL_NO}$RES_JSTEG${COL_OFF}"
        else
            printLine2 "jsteg" "${COL_YES}$RES_JSTEG${COL_OFF}"
        fi

        #TODO: How to analyse stegoveritas results.. --> DO IT HERE!!

        #found something?
        if [ ! $DETECT_COUNT -eq 0 ]; then
            printLine1 "${COL_NO}probably found something" "${COL_NO}$DETECT_COUNT detects${COL_OFF}!"
            #################################################################################

            #STEGBREAK AND STEGHIDE EXTRACT HERE

            #TODO: Break needed???? o: outguess, p: jphide, j: jsteg
            #stegbreak -t o -f wordlist.txt $SAMPLE
            #stegbreak -t p -f wordlist.txt $SAMPLE
            #stegbreak -t j -f wordlist.txt $SAMPLE

            #TODO: steghide: only extract if passphrase is "", otherwise useless
            #echo -e "    ${COL_2}> ${COL_OFF}[steghide extract -sf '${COL_3}$SAMPLE${COL_OFF}' -p '']"
            #steghide extract -sf $SAMPLE -p "" &>$SAMPLE_OUTPUT_DIRECTORY/steghide.out

            #################################################################################
        else
            printLine1 "${COL_YES}all clear"
        fi
    done

    formatPath $GENERAL_IMAGE_EXTENSION
    printLine0 "stego analysis finished" "Analysed ${COL_2}$PARAM_SIZE${COL_OFF} $RETVAL-file-samples."
fi

#TODO: abgleich ergebnisse mit manipulationen

exit