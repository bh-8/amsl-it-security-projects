#!/bin/bash

##### TODO KW 46
# - --generate-testset und --testset vereinen zu einem input command ()
# - testset-directory umbenennen zu stego-files
# - stegoanalysis tools direkt nach erzeugen der cover bilder durchführen und ergebnisse in stego-analysis-directory speichern
# - auswertung der analysis ergebnisse durchführen und abschließendes ergebnis in CSV (o.ä.) schreiben

# FAST mode switch
# OUTPUT switch

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

#example secret text links
LINK_EMBEDDING_SHORT="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/shortEmbedding.txt"
LINK_EMBEDDING_LONG="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/longEmbedding.txt"
LINK_EMBEDDING_LOWENTROPY="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/lowEntropyEmbedding.txt"
LINK_EMBEDDING_BINARY="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/binaryEmbedding"
EMBEDDING_SHORT=$(realpath ./embeddingShort.txt)
EMBEDDING_LONG=$(realpath ./embeddingLong.txt)
EMBEDDING_LOWENTROPY=$(realpath ./embeddingLowEntropy.txt)
EMBEDDING_BINARY=$(realpath ./embeddingBinary)

PASSPHRASE_SHORT="TEST"
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
    echo "    -i, --input <directory>          Path to cover files-directory"
    echo "    -o, --output <directory>         Specify output location (default is './out-stego-attrib')"
    echo ""
    echo "    -n, --size <n>                   Number of cover files to analyse (default is 1)"
    echo "    -s, --shuffle                    Use random subset of cover files"
    echo "    -c, --clean                      Clean output directory prior new analysis"
    echo "    -f, --fast                       Skip f5 embedding and stegoveritas analysis"
    echo "    -v, --verbose                    Print everything"
    echo "    -h, --help"
    exit
}

#call printError and exit
function printErrorAndExit {
    printError "${1}"
    exit 1
}

#formats for outputs
function printLine0 {
    echo -e "${COL_1}> ${COL_3}[${COL_1}${1}${COL_3}]${COL_OFF} ${2}"
}
function printLine1 {
    echo -e "  ${COL_1}> ${COL_3}[${COL_1}${1}${COL_3}]${COL_OFF} ${2}"
}
function printLine2 {
    if [ $PARAM_VERBOSE -eq 1 ]; then
        echo -e "    ${COL_2}> ${COL_3}[${COL_2}${1}${COL_3}]${COL_OFF} ${2}"
    fi
}
function printLine3 {
    if [ $PARAM_VERBOSE -eq 1 ]; then
        echo -e "      ${COL_3}> ${COL_3}[${COL_3}${1}${COL_3}]${COL_OFF} ${2}"
    fi
}
function formatPath {
    RETVAL="${COL_OFF}'${COL_3}${1}${COL_OFF}'"
}
#TODO: currently unused:
function formatCurrentTimestamp {
    DATETIME_NOW=$(date "+%F %H:%M:%S")
    RETVAL="${COL_3}$DATETIME_NOW${COL_OFF}"
}

function getEmbeddingTypeText {
    case ${1} in
        *Short*) RETVAL=shortEbd ;;
        *Long*) RETVAL=longEbd ;;
        *LowEntropy*) RETVAL=lowEntropyEbd ;;
        *Binary*) RETVAL=binaryEbd ;;
        *) RETVAL=null ;;
    esac
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
PARAM_INPUT=""
PARAM_OUTPUT=$(realpath "./out-stego-attrib")
PARAM_SIZE=1
PARAM_SHUFFLE=0
PARAM_CLEAN=0
PARAM_FAST=0
PARAM_VERBOSE=0

#loop parameters
i=1
for param in $@; do
    j=$((i+1))
    next_param=${!j}

    case $param in
        --input|-i)
            #check if path is given
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires a path to a directory container cover files!"
            fi
            PARAM_INPUT=$next_param ;;
        --output|-o)
            #check if path is given
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires a path to a directory container cover files!"
            fi
            PARAM_OUTPUT=$next_param ;;
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
        --fast|-f)
            PARAM_FAST=1 ;;
        --verbose|-v)
            PARAM_VERBOSE=1 ;;
        *) ;;
    esac

    i=$j
done

#script output directory for testset
TESTSET_OUTPUT_DIRECTORY=$PARAM_OUTPUT/tmp-stego-files
ANALYSIS_OUTPUT_DIRECTORY=$PARAM_OUTPUT/tmp-stego-analysis
EVALUATION_OUTPUT_FILE=$PARAM_OUTPUT/out.csv

##### Check Environment #####

#script needs at least --generate-testset or/and --testset parameter to do something
if [ -z $PARAM_INPUT ]; then
    printErrorAndExit "Parameter '--input' not specified, please give me some cover files to work with!"
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

#set parameter for sorting/shuffle
SORTING_PARAM="-dr"
if [ $PARAM_SHUFFLE -eq 1 ]; then
    SORTING_PARAM="-R"
    printLine0 "--shuffle" "Image selection will be randomized."
fi

#perform cleanup
if [ $PARAM_CLEAN -eq 1 ]; then
    printLine0 "--clean" "Cleaning output directory..."
    if [ -d "$PARAM_OUTPUT" ]; then
        rm -dr "$PARAM_OUTPUT"
    fi
    rm -f $EMBEDDING_SHORT
    rm -f $EMBEDDING_LONG
    rm -f $EMBEDDING_LOWENTROPY
    rm -f $EMBEDDING_BINARY
fi

#fast
if [ $PARAM_FAST -eq 1 ]; then
    printLine0 "--fast" "f5 and stegoveritas will be skipped!"
fi

#verbose
if [ $PARAM_VERBOSE -eq 1 ]; then
    printLine0 "--verbose" "advanced log output enabled!"
fi

#######################################
##### EMBED, ANALYSIS, EVALUATION #####
#######################################

if [ ! -z $PARAM_INPUT ]; then
    PARAM_INPUT=$(realpath $PARAM_INPUT)

    #check if cover data directory exists
    if [ ! -d $PARAM_INPUT ]; then
        formatPath $PARAM_INPUT
        printErrorAndExit "Could not find cover data at $RETVAL!"
    fi

    #count jpg files in cover directory
    JPGS_FOUND_COVER=$(find $PARAM_INPUT -maxdepth 1 -type f -name $GENERAL_IMAGE_EXTENSION | wc -l)

    #check if there are any jpg files available
    if [ $JPGS_FOUND_COVER -eq 0 ]; then
        formatPath $GENERAL_IMAGE_EXTENSION
        printErrorAndExit "Cover image directory does not contain any $RETVAL files."
    fi

    #check if subset size is smaller or equal number of available files
    if [ $PARAM_SIZE -gt $JPGS_FOUND_COVER ]; then
        printErrorAndExit "There are only ${COL_2}$JPGS_FOUND_COVER${COL_OFF} objects in specified directory!"
    fi

    formatPath $PARAM_INPUT
    printLine0 "--input" "Cover location is set to $RETVAL."

    formatPath $PARAM_OUTPUT
    printLine0 "--output" "Output location is set to $RETVAL."

    #make sure output directory exists
    if [ ! -d "$PARAM_OUTPUT" ]; then
        mkdir $PARAM_OUTPUT
    fi

    formatPath $GENERAL_IMAGE_EXTENSION
    printLine0 "main/start" "Going to embed, analyse and evaluate ${COL_2}$PARAM_SIZE${COL_OFF} of a total of ${COL_2}$JPGS_FOUND_COVER${COL_OFF} available $RETVAL-covers."

    #retrieve example embedding data
    if [ ! -f $EMBEDDING_SHORT ]; then
        formatPath $EMBEDDING_SHORT
        printLine1 "download" "Downloading example data $RETVAL to embed..."
        wget -N "$LINK_EMBEDDING_SHORT" -O "$EMBEDDING_SHORT" &> /dev/null
    fi
    if [ ! -f $EMBEDDING_LONG ]; then
        formatPath $EMBEDDING_LONG
        printLine1 "download" "Downloading example data $RETVAL to embed..."
        wget -N "$LINK_EMBEDDING_LONG" -O "$EMBEDDING_LONG" &> /dev/null
    fi
    if [ ! -f $EMBEDDING_LOWENTROPY ]; then
        formatPath $EMBEDDING_LOWENTROPY
        printLine1 "download" "Downloading example data $RETVAL to embed..."
        wget -N "$LINK_EMBEDDING_LOWENTROPY" -O "$EMBEDDING_LOWENTROPY" &> /dev/null
    fi
    if [ ! -f $EMBEDDING_BINARY ]; then
        formatPath $EMBEDDING_BINARY
        printLine1 "download" "Downloading example data $RETVAL to embed..."
        wget -N "$LINK_EMBEDDING_BINARY" -O "$EMBEDDING_BINARY" &> /dev/null
    fi

    BASENAME_EXTENSION=${GENERAL_IMAGE_EXTENSION:1}

    #Loop cover directory
    C=0
    find $PARAM_INPUT -maxdepth 1 -type f -name $GENERAL_IMAGE_EXTENSION | sort $SORTING_PARAM | tail -$PARAM_SIZE | while read COVER; do
        C=$((C+1))

        COVER_BASENAME_NO_EXT=$(basename $COVER $BASENAME_EXTENSION)
        COVER_BASENAME=$(basename $COVER)

        formatPath $COVER
        printLine0 "cover/start" "${COL_2}$C${COL_OFF}/${COL_2}$PARAM_SIZE${COL_OFF}: Working on $RETVAL..."
        
        ##### EMBEDDING #####
        printLine1 "embed/start"

        #make sure testset directory exists
        if [ ! -d "$TESTSET_OUTPUT_DIRECTORY" ]; then
            mkdir $TESTSET_OUTPUT_DIRECTORY
        fi

        JPEG_COVER=$TESTSET_OUTPUT_DIRECTORY/$COVER_BASENAME
        JPEG_STEGO_BASE=$TESTSET_OUTPUT_DIRECTORY/$COVER_BASENAME_NO_EXT

        #copy original cover to testset
        cp $COVER $JPEG_COVER
        formatPath $JPEG_COVER
        printLine2 "copy" "Original cover copied to $RETVAL."
        
        #doing stego
        EMBEDDING_TYPES=($EMBEDDING_SHORT $EMBEDDING_LONG $EMBEDDING_LOWENTROPY $EMBEDDING_BINARY)
        
        #TODO: JPHIDE AUTOMATION....?
        #jphide
        STEGO_TOOL=jphide
        #printLine1 $STEGO_TOOL
        #shortKey
        #for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
        #    getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
        #    printLine2 "exec" "jphide $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-shortKey$BASENAME_EXTENSION $EMBEDDING_TYPE"
        #    jphide $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-shortKey$BASENAME_EXTENSION $EMBEDDING_TYPE
        #done
        #longKey
        #for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
        #    getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
        #    printLine2 "exec" "jphide $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-longKey$BASENAME_EXTENSION $EMBEDDING_TYPE"
        #    jphide $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-longKey$BASENAME_EXTENSION $EMBEDDING_TYPE
        #done

        #jsteg does not have embed-key support!
        STEGO_TOOL=jsteg
        printLine2 $STEGO_TOOL
        #noKey
        for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
            getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
            printLine3 "exec" "$STEGO_TOOL hide $JPEG_COVER $EMBEDDING_TYPE $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-noKey$BASENAME_EXTENSION"
            $STEGO_TOOL hide $JPEG_COVER $EMBEDDING_TYPE $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-noKey$BASENAME_EXTENSION &> /dev/null
        done

        #outguess and outguess-0.13
        OUTGUESS_ARR=(outguess outguess-0.13)
        for STEGO_TOOL in "${OUTGUESS_ARR[@]}"; do
            printLine2 $STEGO_TOOL
            #noKey
            for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
                getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
                printLine3 "exec" "$STEGO_TOOL -d $EMBEDDING_TYPE $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-noKey$BASENAME_EXTENSION"
                $STEGO_TOOL -d $EMBEDDING_TYPE $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-noKey$BASENAME_EXTENSION &> /dev/null
            done
            #shortKey
            for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
                getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
                printLine3 "exec" "$STEGO_TOOL -k $PASSPHRASE_SHORT -d $EMBEDDING_TYPE $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-shortKey$BASENAME_EXTENSION"
                $STEGO_TOOL -k $PASSPHRASE_SHORT -d $EMBEDDING_TYPE $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-shortKey$BASENAME_EXTENSION &> /dev/null
            done
            #longKey
            for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
                getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
                printLine3 "exec" "$STEGO_TOOL -k $PASSPHRASE_LONG -d $EMBEDDING_TYPE $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-longKey$BASENAME_EXTENSION"
                $STEGO_TOOL -k $PASSPHRASE_LONG -d $EMBEDDING_TYPE $JPEG_COVER $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-longKey$BASENAME_EXTENSION &> /dev/null
            done
        done
        
        STEGO_TOOL=steghide
        printLine2 $STEGO_TOOL
        #noKey
        for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
            getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
            printLine3 "exec" "$STEGO_TOOL embed -f -ef $EMBEDDING_TYPE -cf $JPEG_COVER -sf $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-noKey$BASENAME_EXTENSION"
            $STEGO_TOOL embed -f -ef $EMBEDDING_TYPE -cf $JPEG_COVER -sf $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-noKey$BASENAME_EXTENSION &> /dev/null
        done
        #shortKey
        for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
            getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
            printLine3 "exec" "$STEGO_TOOL embed -f -ef $EMBEDDING_TYPE -cf $JPEG_COVER -p $PASSPHRASE_SHORT -sf $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-shortKey$BASENAME_EXTENSION"
            $STEGO_TOOL embed -f -ef $EMBEDDING_TYPE -cf $JPEG_COVER -p $PASSPHRASE_SHORT -sf $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-shortKey$BASENAME_EXTENSION &> /dev/null
        done
        #longKey
        for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
            getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
            printLine3 "exec" "$STEGO_TOOL embed -f -ef $EMBEDDING_TYPE -cf $JPEG_COVER -p $PASSPHRASE_LONG -sf $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-longKey$BASENAME_EXTENSION"
            $STEGO_TOOL embed -f -ef $EMBEDDING_TYPE -cf $JPEG_COVER -p $PASSPHRASE_LONG -sf $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-longKey$BASENAME_EXTENSION &> /dev/null
        done


        STEGO_TOOL=f5
        if [ $PARAM_FAST -eq 0 ]; then
            printLine2 $STEGO_TOOL
            #noKey
            for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
                getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
                printLine3 "exec" "f5 -t e -i $JPEG_COVER -o $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-noKey$BASENAME_EXTENSION -d '\$(cat $EMBEDDING_TYPE)'"
                f5 -t e -i $JPEG_COVER -o $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-noKey$BASENAME_EXTENSION -d '$(cat $EMBEDDING_TYPE)' &> /dev/null
            done
            #shortKey
            for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
                getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
                printLine3 "exec" "f5 -t e -i $JPEG_COVER -o $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-shortKey$BASENAME_EXTENSION -p $PASSPHRASE_SHORT -d '\$(cat $EMBEDDING_TYPE)'"
                f5 -t e -i $JPEG_COVER -o $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-shortKey$BASENAME_EXTENSION -p $PASSPHRASE_SHORT -d '$(cat $EMBEDDING_TYPE)' &> /dev/null
            done
            #longKey
            for EMBEDDING_TYPE in "${EMBEDDING_TYPES[@]}"; do
                getEmbeddingTypeText $(basename $EMBEDDING_TYPE})
                printLine3 "exec" "f5 -t e -i $JPEG_COVER -o $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-longKey$BASENAME_EXTENSION -p $PASSPHRASE_LONG -d '\$(cat $EMBEDDING_TYPE)'"
                f5 -t e -i $JPEG_COVER -o $JPEG_STEGO_BASE-$STEGO_TOOL-$RETVAL-longKey$BASENAME_EXTENSION -p $PASSPHRASE_LONG -d '$(cat $EMBEDDING_TYPE)' &> /dev/null
            done
        else
            printLine2 $STEGO_TOOL "skipped due to --fast switch!"
        fi

        printLine1 "embed/done"
        
        ##### ANALYSIS ######

        #make sure analysis directory exists
        if [ ! -d "$ANALYSIS_OUTPUT_DIRECTORY" ]; then
            mkdir $ANALYSIS_OUTPUT_DIRECTORY
        fi
        

        #check if given testset directory exists
        if [ ! -d $TESTSET_OUTPUT_DIRECTORY ]; then
            formatPath $TESTSET_OUTPUT_DIRECTORY
            printErrorAndExit "Could not find test set at $RETVAL!"
        fi

        #count available jpg files in testset
        JPGS_FOUND_TESTSET=$(find $TESTSET_OUTPUT_DIRECTORY -maxdepth 1 -type f -name $GENERAL_IMAGE_EXTENSION | wc -l)

        #check if there are any jpg files available
        if [ $JPGS_FOUND_TESTSET -eq 0 ]; then
            formatPath $GENERAL_IMAGE_EXTENSION
            printErrorAndExit "Testset directory does not contain any $RETVAL files."
        fi

        printLine1 "analysis/start" "Going to analyse ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} stego samples..."

        DETECT_COUNT_TOTAL=0

        D=0
        find $TESTSET_OUTPUT_DIRECTORY -maxdepth 1 -type f -name $GENERAL_IMAGE_EXTENSION | sort -d | while read SAMPLE; do
            D=$((D+1))

            formatPath $SAMPLE
            printLine1 "analysis" "${COL_2}$D${COL_OFF}/${COL_2}$JPGS_FOUND_TESTSET${COL_OFF}: Analysing image $RETVAL..."
            
            SAMPLE_OUTPUT_DIRECTORY="$ANALYSIS_OUTPUT_DIRECTORY/$(basename $SAMPLE)"

            #create output directory
            if [ -d "$SAMPLE_OUTPUT_DIRECTORY" ]; then
                rm -dr "$SAMPLE_OUTPUT_DIRECTORY"
            fi
            mkdir "$SAMPLE_OUTPUT_DIRECTORY"

            formatPath $SAMPLE_OUTPUT_DIRECTORY/*
            printLine2 "output" "Data will be saved to $RETVAL."

            #General Screening Tools
            printLine2 "general screening tools"
            
            formatPath $SAMPLE
            FPATH_SAMPLE=$RETVAL

            #file <sample>
            printLine3 "exec" "file $FPATH_SAMPLE"
            file $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/file.out

            #exiftool <sample>
            printLine3 "exec" "exiftool $FPATH_SAMPLE"
            exiftool $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/exiftool.out

            #binwalk <sample>
            printLine3 "exec" "binwalk $FPATH_SAMPLE"
            binwalk $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/binwalk.out

            #strings <sample>
            printLine3 "exec" "strings $FPATH_SAMPLE"
            strings $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/strings.out

            #foremost -o <output-dir> -i <sample>
            formatPath $SAMPLE_OUTPUT_DIRECTORY/foremost
            printLine3 "exec" "foremost -i $FPATH_SAMPLE -o $RETVAL"
            foremost -o $SAMPLE_OUTPUT_DIRECTORY/foremost -i $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/foremost.out

            #identify -verbose <sample>
            printLine3 "exec" "identify -verbose $FPATH_SAMPLE"
            identify -verbose $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/identify.out
        
            #Tools detecting steganography
            printLine2 "stego detecting tools"

            #stegdetect <sample>
            printLine3 "exec" "stegdetect $FPATH_SAMPLE"
            stegdetect $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/stegdetect.out

            #outguess -r <sample> <output-file>
            formatPath $SAMPLE_OUTPUT_DIRECTORY/outguess.extracted.out
            printLine3 "exec" "outguess -r $FPATH_SAMPLE $RETVAL"
            outguess -r $SAMPLE $SAMPLE_OUTPUT_DIRECTORY/outguess.extracted.out &>$SAMPLE_OUTPUT_DIRECTORY/outguess.out
            
            #outguess-0.13 -r <sample> <output-file>
            formatPath $SAMPLE_OUTPUT_DIRECTORY/outguess-0.13.extracted.out
            printLine3 "exec" "outguess-0.13 -r $FPATH_SAMPLE $RETVAL"
            outguess-0.13 -r $SAMPLE $SAMPLE_OUTPUT_DIRECTORY/outguess-0.13.extracted.out &>$SAMPLE_OUTPUT_DIRECTORY/outguess-0.13.out

            #jsteg reveal <sample>
            printLine3 "exec" "jsteg reveal $FPATH_SAMPLE"
            jsteg reveal $SAMPLE &>$SAMPLE_OUTPUT_DIRECTORY/jsteg.out

            if [ $PARAM_FAST -eq 0 ]; then
                #stegoveritas <sample> -out <output-dir> -meta -imageTransform -colorMap -trailing -steghide -xmp -carve
                formatPath $SAMPLE_OUTPUT_DIRECTORY/stegoveritas
                printLine3 "exec" "stegoveritas $FPATH_SAMPLE -out $RETVAL -meta -imageTransform -colorMap -trailing -steghide -xmp -carve"
                stegoveritas $SAMPLE -out $SAMPLE_OUTPUT_DIRECTORY/stegoveritas -meta -imageTransform -colorMap -trailing -steghide -xmp -carve &>$SAMPLE_OUTPUT_DIRECTORY/stegoveritas.out
            else
                printLine3 "skip" "skipped due to --fast switch!"
            fi

            ##### EVALUATION ######
            printLine2 "evaluation"

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

            DETECT_COUNT=0

            #stegdetect
            RES_STEGDETECT=$(cat $SAMPLE_OUTPUT_DIRECTORY/stegdetect.out | cut -d ":" -f 2 | xargs)
            if [ "$RES_STEGDETECT" != "negative" ]; then
                DETECT_COUNT=$((DETECT_COUNT+1))
                printLine3 "stegdetect" "${COL_NO}$RES_STEGDETECT${COL_OFF}"
            else
                printLine3 "stegdetect" "${COL_YES}$RES_STEGDETECT${COL_OFF}"
            fi

            #outguess
            RES_OUTGUESS1=$(tr -d '\0' < $SAMPLE_OUTPUT_DIRECTORY/outguess.extracted.out)
            RES_OUTGUESS1=${#RES_OUTGUESS1}
            if [ $RES_OUTGUESS1 -ne 0 ]; then
                DETECT_COUNT=$((DETECT_COUNT+1))
                printLine3 "outguess" "result length is ${COL_NO}$RES_OUTGUESS1${COL_OFF}"
            else
                printLine3 "outguess" "result length is ${COL_YES}$RES_OUTGUESS1${COL_OFF}"
            fi

            #outguess-0.13
            RES_OUTGUESS2=$(tr -d '\0' < $SAMPLE_OUTPUT_DIRECTORY/outguess-0.13.extracted.out)
            RES_OUTGUESS2=${#RES_OUTGUESS2}
            if [ $RES_OUTGUESS2 -ne 0 ]; then
                DETECT_COUNT=$((DETECT_COUNT+1))
                printLine3 "outguess-0.13" "result length is ${COL_NO}$RES_OUTGUESS2${COL_OFF}"
            else
                printLine3 "outguess-0.13" "result length is ${COL_YES}$RES_OUTGUESS2${COL_OFF}"
            fi

            #jsteg
            RES_JSTEG=$(cat $SAMPLE_OUTPUT_DIRECTORY/jsteg.out)
            if [ "$RES_JSTEG" != "jpeg does not contain hidden data" ]; then
                DETECT_COUNT=$((DETECT_COUNT+1))
                printLine3 "jsteg" "${COL_NO}$RES_JSTEG${COL_OFF}"
            else
                printLine3 "jsteg" "${COL_YES}$RES_JSTEG${COL_OFF}"
            fi

            #found something?
            if [ ! $DETECT_COUNT -eq 0 ]; then
                printLine2 "${COL_NO}probably found something" "${COL_NO}$DETECT_COUNT detects${COL_OFF}!"
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
                printLine2 "${COL_YES}all clear"
            fi

            DETECT_COUNT_TOTAL=$((DETECT_COUNT_TOTAL+DETECT_COUNT))

            #write evaluation result
            echo "$SAMPLE;$DETECT_COUNT" >> $EVALUATION_OUTPUT_FILE
        done

        #remove data
        rm -dr $TESTSET_OUTPUT_DIRECTORY
        rm -dr $ANALYSIS_OUTPUT_DIRECTORY

        formatPath $GENERAL_IMAGE_EXTENSION
        #TODO: display total detect count for this cover
        #printLine1 "analysis/done" "Analysed ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} $RETVAL-file-samples, got a total of ${COL_2}$DETECT_COUNT_TOTAL${COL_OFF} detects!"
        printLine1 "analysis/done" "Analysed ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} $RETVAL-file-samples."

        formatPath $COVER
        printLine0 "cover/done" "Done working on $RETVAL."
    done

    formatPath $GENERAL_IMAGE_EXTENSION
    printLine0 "main/done" "Worked through ${COL_2}$PARAM_SIZE${COL_OFF} $RETVAL-covers."
fi

exit 0