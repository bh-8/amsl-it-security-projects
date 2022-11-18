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

#example secret text links
LINK_EMBEDDING_SHORT="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/shortEmbedding.txt"
LINK_EMBEDDING_MIDDLE="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/middleEmbedding.txt"
LINK_EMBEDDING_LONG="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/longEmbedding.txt"
LINK_EMBEDDING_LOWENTROPY="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/lowEntropyEmbedding.txt"
LINK_EMBEDDING_BINARY="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/binaryEmbedding"
EMBEDDING_SHORT=$(realpath ./embeddingShort.txt)
EMBEDDING_MIDDLE=$(realpath ./embeddingMiddle.txt)
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
    echo "    -r, --randomize                    Use random subset of cover files"
    echo "    -c, --clean                      Clean output directory prior new analysis"
    echo "    -f, --fast                       Skip f5 embedding and stegoveritas analysis"
    echo "    -v, --verbose                    Print everything"
    echo ""
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
        *Short*) RETURN_EBDTEXT=shortEbd ;;
        *Long*) RETURN_EBDTEXT=longEbd ;;
        *Middle*) RETURN_EBDTEXT=middleEbd ;;
        *LowEntropy*) RETURN_EBDTEXT=lowEntropyEbd ;;
        *Binary*) RETURN_EBDTEXT=binaryEbd ;;
        *) RETURN_EBDTEXT=null ;;
    esac
}
function getKeyByType {
    case ${1} in
        shortKey) RETURN_KEY=$PASSPHRASE_SHORT ;;
        longKey) RETURN_KEY=$PASSPHRASE_LONG ;;
        *) RETURN_KEY=null ;;
    esac
}

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
PARAM_RANDOMIZE=0
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
        --randomize|-r)
            PARAM_RANDOMIZE=1 ;;
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
if [ $PARAM_RANDOMIZE -eq 1 ]; then
    SORTING_PARAM="-R"
    printLine0 "--randomize" "Image selection will be randomized."
fi

#perform cleanup
if [ $PARAM_CLEAN -eq 1 ]; then
    printLine0 "--clean" "Cleaning output directory..."
    if [ -d "$PARAM_OUTPUT" ]; then
        rm -dr "$PARAM_OUTPUT"
    fi
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
    JPGS_FOUND_COVER=$(find $PARAM_INPUT -maxdepth 1 -type f -name "*.jpg" | wc -l)

    #check if there are any jpg files available
    if [ $JPGS_FOUND_COVER -eq 0 ]; then
        formatPath *.jpg
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

    formatPath *.jpg
    printLine0 "main/start" "Going to embed, analyse and evaluate ${COL_2}$PARAM_SIZE${COL_OFF} of a total of ${COL_2}$JPGS_FOUND_COVER${COL_OFF} available $RETVAL-covers."

    #retrieve example embedding data
    if [ ! -f $EMBEDDING_SHORT ]; then
        formatPath $EMBEDDING_SHORT
        printLine1 "download" "Downloading example data $RETVAL to embed..."
        wget -N "$LINK_EMBEDDING_SHORT" -O "$EMBEDDING_SHORT" &> /dev/null
    fi
    if [ ! -f $EMBEDDING_MIDDLE ]; then
        formatPath $EMBEDDING_MIDDLE
        printLine1 "download" "Downloading example data $RETVAL to embed..."
        wget -N "$LINK_EMBEDDING_MIDDLE" -O "$EMBEDDING_MIDDLE" &> /dev/null
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

    #Loop cover directory
    C=0
    find $PARAM_INPUT -maxdepth 1 -type f -name "*.jpg" | sort $SORTING_PARAM | tail -$PARAM_SIZE | while read COVER; do
        C=$((C+1))

        COVER_BASENAME=$(basename $COVER)
        COVER_BASENAME_NO_EXT=$(basename $COVER .jpg)

        formatPath $COVER
        printLine1 "cover/start" "${COL_2}$C${COL_OFF}/${COL_2}$PARAM_SIZE${COL_OFF}: Working on $RETVAL..."

        JPEG_OUTDIR=$PARAM_OUTPUT/$COVER_BASENAME_NO_EXT

        #make sure output directory exists
        if [ ! -d "$JPEG_OUTDIR" ]; then
            mkdir $JPEG_OUTDIR
        fi

        JPEG_COVER=$JPEG_OUTDIR/_cover.jpg

        #copy original cover to testset
        cp $COVER $JPEG_COVER
        formatPath $JPEG_COVER
        printLine2 "copy" "Original cover copied to $RETVAL."
        
        #TODO!!!: analyse cover image..

        #TODO!!! JPHIDE HERE: short and long key

        {
            #jsteg does not support embed keys!
            EMBEDDING_DATA=($EMBEDDING_SHORT $EMBEDDING_MIDDLE $EMBEDDING_LONG $EMBEDDING_LOWENTROPY $EMBEDDING_BINARY)
            STEGO_TOOL=jsteg
            printLine2 $STEGO_TOOL
            for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
                getEmbeddingTypeText $(basename $EMBEDDING_FILE})
                JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL-$RETURN_EBDTEXT-noKey
                JPEG_STEGO=$JPEG_STEGO_NO_EXT.jpg

                #embedding
                printLine3 "exec" "$STEGO_TOOL hide $JPEG_COVER $EMBEDDING_FILE $JPEG_STEGO"
                $STEGO_TOOL hide $JPEG_COVER $EMBEDDING_FILE $JPEG_STEGO &> /dev/null

                #extracting
                printLine3 "exec" "$STEGO_TOOL reveal $JPEG_STEGO $JPEG_STEGO_NO_EXT.out"
                $STEGO_TOOL reveal $JPEG_STEGO $JPEG_STEGO_NO_EXT.out &> /dev/null

                #writing
                SHA1_OUT=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
                echo "$(basename $COVER);$(basename $JPEG_STEGO);$STEGO_TOOL;$RETURN_EBDTEXT;noKey;$SHA1_OUT" >> $JPEG_OUTDIR/_meta.csv
            done
        }
        {
            #outguess does not support binary embeds!
            OUTGUESS_ARR=(outguess outguess-0.13)
            KEY_ARR=(noKey shortKey longKey)
            EMBEDDING_DATA=($EMBEDDING_SHORT $EMBEDDING_MIDDLE $EMBEDDING_LONG $EMBEDDING_LOWENTROPY)
            for STEGO_TOOL in "${OUTGUESS_ARR[@]}"; do
                printLine2 $STEGO_TOOL
                for KEY_TYPE in "${KEY_ARR[@]}"; do
                    for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
                        getEmbeddingTypeText $(basename $EMBEDDING_FILE})
                        JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL-$RETURN_EBDTEXT-$KEY_TYPE
                        JPEG_STEGO=$JPEG_STEGO_NO_EXT.jpg

                        getKeyByType $KEY_TYPE
                        if [ $RETURN_KEY == "null" ]; then
                            #embedding
                            printLine3 "exec" "$STEGO_TOOL -d $EMBEDDING_FILE $JPEG_COVER $JPEG_STEGO"
                            $STEGO_TOOL -d $EMBEDDING_FILE $JPEG_COVER $JPEG_STEGO &> /dev/null

                            #extracting
                            printLine3 "exec" "$STEGO_TOOL -r $JPEG_STEGO $JPEG_STEGO_NO_EXT.out"
                            $STEGO_TOOL -r $JPEG_STEGO $JPEG_STEGO_NO_EXT.out &> /dev/null
                        else
                            #embedding
                            printLine3 "exec" "$STEGO_TOOL -k $RETURN_KEY -d $EMBEDDING_FILE $JPEG_COVER $JPEG_STEGO"
                            $STEGO_TOOL -k $RETURN_KEY -d $EMBEDDING_FILE $JPEG_COVER $JPEG_STEGO &> /dev/null

                            #extracting
                            printLine3 "exec" "$STEGO_TOOL -k $RETURN_KEY -r $JPEG_STEGO $JPEG_STEGO_NO_EXT.out"
                            $STEGO_TOOL -k $RETURN_KEY -r $JPEG_STEGO $JPEG_STEGO_NO_EXT.out &> /dev/null
                        fi

                        #writing
                        SHA1_OUT=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
                        echo "$(basename $COVER);$(basename $JPEG_STEGO);$STEGO_TOOL;$RETURN_EBDTEXT;$KEY_TYPE;$SHA1_OUT" >> $JPEG_OUTDIR/_meta.csv
                    done
                done
            done
        }
        {
            #steghide does not support no keys!
            KEY_ARR=(shortKey longKey)
            EMBEDDING_DATA=($EMBEDDING_SHORT $EMBEDDING_MIDDLE $EMBEDDING_LONG $EMBEDDING_LOWENTROPY $EMBEDDING_BINARY)
            STEGO_TOOL=steghide
            printLine2 $STEGO_TOOL
            for KEY_TYPE in "${KEY_ARR[@]}"; do
                for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
                    getEmbeddingTypeText $(basename $EMBEDDING_FILE})
                    JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL-$RETURN_EBDTEXT-$KEY_TYPE
                    JPEG_STEGO=$JPEG_STEGO_NO_EXT.jpg

                    getKeyByType $KEY_TYPE
                    if [ $RETURN_KEY == "null" ]; then
                        #embedding
                        printLine3 "exec" "$STEGO_TOOL embed -f -ef $EMBEDDING_FILE -cf $JPEG_COVER -sf $JPEG_STEGO"
                        $STEGO_TOOL embed -f -ef $EMBEDDING_FILE -cf $JPEG_COVER -sf $JPEG_STEGO &> /dev/null

                        #extracting
                        printLine3 "exec" "$STEGO_TOOL extract -sf $JPEG_STEGO -xf $JPEG_STEGO_NO_EXT.out"
                        $STEGO_TOOL extract -sf $JPEG_STEGO -xf $JPEG_STEGO_NO_EXT.out &> /dev/null
                    else
                        #embedding
                        printLine3 "exec" "$STEGO_TOOL embed -f -ef $EMBEDDING_FILE -cf $JPEG_COVER -p $RETURN_KEY -sf $JPEG_STEGO"
                        $STEGO_TOOL embed -f -ef $EMBEDDING_FILE -cf $JPEG_COVER -p $RETURN_KEY -sf $JPEG_STEGO &> /dev/null

                        #extracting
                        printLine3 "exec" "$STEGO_TOOL extract -sf $JPEG_STEGO -p $RETURN_KEY -xf $JPEG_STEGO_NO_EXT.out"
                        $STEGO_TOOL extract -sf $JPEG_STEGO -p $RETURN_KEY -xf $JPEG_STEGO_NO_EXT.out &> /dev/null
                    fi

                    #writing
                    SHA1_OUT=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
                    echo "$(basename $COVER);$(basename $JPEG_STEGO);$STEGO_TOOL;$RETURN_EBDTEXT;$KEY_TYPE;$SHA1_OUT" >> $JPEG_OUTDIR/_meta.csv
                done
            done
        }
        {
            if [ $PARAM_FAST -eq 0 ]; then
                KEY_ARR=(noKey shortKey longKey)
                EMBEDDING_DATA=($EMBEDDING_SHORT $EMBEDDING_MIDDLE $EMBEDDING_LONG $EMBEDDING_LOWENTROPY $EMBEDDING_BINARY)
                STEGO_TOOL=f5
                printLine2 $STEGO_TOOL
                for KEY_TYPE in "${KEY_ARR[@]}"; do
                    for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
                        getEmbeddingTypeText $(basename $EMBEDDING_FILE})
                        JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL-$RETURN_EBDTEXT-$KEY_TYPE
                        JPEG_STEGO=$JPEG_STEGO_NO_EXT.jpg

                        getKeyByType $KEY_TYPE
                        if [ $RETURN_KEY == "null" ]; then
                            #embedding
                            printLine3 "exec" "$STEGO_TOOL -t e -i $JPEG_COVER -o $JPEG_STEGO -d '\$(cat $EMBEDDING_FILE)'"
                            $STEGO_TOOL -t e -i $JPEG_COVER -o $JPEG_STEGO -d "$(cat $EMBEDDING_FILE)" &> /dev/null

                            #extracting
                            printLine3 "exec" "$STEGO_TOOL -t x -i $JPEG_STEGO | tee $JPEG_STEGO_NO_EXT.out"
                            $STEGO_TOOL -t x -i $JPEG_STEGO 2> /dev/null | tee $JPEG_STEGO_NO_EXT.out &> /dev/null
                        else
                            #embedding
                            printLine3 "exec" "$STEGO_TOOL -t e -i $JPEG_COVER -o $JPEG_STEGO -p $RETURN_KEY -d '\$(cat $EMBEDDING_FILE)'"
                            $STEGO_TOOL -t e -i $JPEG_COVER -o $JPEG_STEGO -p $RETURN_KEY -d "$(cat $EMBEDDING_FILE)" &> /dev/null

                            #extracting
                            printLine3 "exec" "$STEGO_TOOL -t x -i $JPEG_STEGO -p $RETURN_KEY | tee $JPEG_STEGO_NO_EXT.out"
                            $STEGO_TOOL -t x -i $JPEG_STEGO -p $RETURN_KEY 2> /dev/null | tee $JPEG_STEGO_NO_EXT.out &> /dev/null
                        fi

                        #writing
                        SHA1_OUT=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
                        echo "$(basename $COVER);$(basename $JPEG_STEGO);$STEGO_TOOL;$RETURN_EBDTEXT;$KEY_TYPE;$SHA1_OUT" >> $JPEG_OUTDIR/_meta.csv
                    done
                done
            else
                printLine2 $STEGO_TOOL "skipped due to --fast switch!"
            fi
        }

        formatPath $COVER
        printLine1 "cover/done" "${COL_2}$C${COL_OFF}/${COL_2}$PARAM_SIZE${COL_OFF}: Done with $RETVAL."

        exit

        #################################################################

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
        JPGS_FOUND_TESTSET=$(find $TESTSET_OUTPUT_DIRECTORY -maxdepth 1 -type f -name "*.jpg" | wc -l)

        #check if there are any jpg files available
        if [ $JPGS_FOUND_TESTSET -eq 0 ]; then
            formatPath *.jpg
            printErrorAndExit "Testset directory does not contain any $RETVAL files."
        fi

        printLine1 "analysis/start" "Going to analyse ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} stego samples..."

        DETECT_COUNT_TOTAL=0

        D=0
        find $TESTSET_OUTPUT_DIRECTORY -maxdepth 1 -type f -name "*.jpg" | sort -d | while read SAMPLE; do
            D=$((D+1))

            formatPath $SAMPLE
            printLine1 "analysis" "${COL_2}$D${COL_OFF}/${COL_2}$JPGS_FOUND_TESTSET${COL_OFF}: Analysing image $RETVAL..."
            
            SAMPLE_OUTPUT_DIRECTORY="$ANALYSIS_OUTPUT_DIRECTORY/$(basename $SAMPLE)"

            #General Screening Tools (UNABHÄNGIG VOM VERWENDETEN TOOL!!!!)
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

            RES_FILE=$(cut -d ":" -f2 $SAMPLE_OUTPUT_DIRECTORY/file.out | xargs)

            RES_FILE_FORMAT=$(echo "$RES_FILE" | cut -d "," -f1 | xargs)
            RES_FILE_JFIF=$(echo "$RES_FILE" | cut -d "," -f2 | xargs)
            RES_FILE_SEGLENGTH=$(echo "$RES_FILE" | cut -d "," -f5 | xargs)
            RES_FILE_PRECISION=$(echo "$RES_FILE" | cut -d "," -f7 | xargs)
            RES_FILE_RESOLUTION=$(echo "$RES_FILE" | cut -d "," -f8 | xargs)
            RES_FILE_FRAMES=$(echo "$RES_FILE" | cut -d "," -f9 | xargs)

            RES_EXIFTOOL_FILESIZE=$(grep "File Size" $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | cut -d ":" -f 2 | xargs)
            RES_EXIFTOOL_MIME=$(grep "MIME Type" $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | cut -d ":" -f 2 | xargs)
            RES_EXIFTOOL_JFIF=$(grep "JFIF Version" $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | cut -d ":" -f 2 | xargs)
            RES_EXIFTOOL_ENCODING=$(grep "Encoding Process" $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | cut -d ":" -f 2 | tr "," "/" | xargs)
            RES_EXIFTOOL_SAMPLEBITS=$(grep "Bits Per Sample" $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | cut -d ":" -f 2 | xargs)
            RES_EXIFTOOL_RESOLUTION=$(grep "Image Size" $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | cut -d ":" -f 2 | xargs)
            RES_EXIFTOOL_MEGAPIXELS=$(grep "Megapixels" $SAMPLE_OUTPUT_DIRECTORY/exiftool.out | cut -d ":" -f 2 | xargs)
            
            RES_BINWALK=$(tail -n +4 $SAMPLE_OUTPUT_DIRECTORY/binwalk.out | xargs | cut -d " " -f3-)
            RES_BINWALK_FORMAT=$(echo "$RES_BINWALK" | cut -d "," -f1)
            RES_BINWALK_JFIF=$(echo "$RES_BINWALK" | cut -d "," -f2 | xargs)
            
            #what to do with strings output...
            #TODO: cat $SAMPLE_OUTPUT_DIRECTORY/strings.out

            RES_FOREMOST=$(grep "Length: " $SAMPLE_OUTPUT_DIRECTORY/foremost/audit.txt | cut -d ":" -f2 | xargs)
            
            RES_IDENTIFY_FORMAT=$(grep "Format:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_RESOLUTION=$(grep "Geometry:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_DEPTH=$(grep "Depth:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | cut -d ":" -f2 | xargs)
            
            RES_IDENTIFY_RED_MIN=$(grep -m1 "Minimum:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_RED_MAX=$(grep -m1 "Maximum:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_RED_MEAN=$(grep -m1 "Mean:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_RED_SD=$(grep -m1 "Standard Deviation:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)

            RES_IDENTIFY_GREEN_MIN=$(grep -m2 "Minimum:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_GREEN_MAX=$(grep -m2 "Maximum:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_GREEN_MEAN=$(grep -m2 "Mean:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_GREEN_SD=$(grep -m2 "Standard Deviation:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)

            RES_IDENTIFY_BLUE_MIN=$(grep -m3 "Minimum:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_BLUE_MAX=$(grep -m3 "Maximum:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_BLUE_MEAN=$(grep -m3 "Mean:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            RES_IDENTIFY_BLUE_SD=$(grep -m3 "Standard Deviation:" $SAMPLE_OUTPUT_DIRECTORY/identify.out | tail -n1 | cut -d ":" -f2 | xargs)
            
            #TODO: stegoveritas...
            #TODO: differenzbild mit imagemagick
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
            if [ ! -f "$EVALUATION_OUTPUT_FILE" ]; then
                echo "original image;sample name;file/format;file/jfif;file/segment length;file/precision;file/resolution;file/frames;exiftool/file size;exiftool/mime type;exiftool/jfif;exiftool/encoding;exiftool/bits per sample;exiftool/resolution;exiftool/megapixels;binwalk/format;binwalk/jfif;foremost/extract;identify/format;identify/resolution;identify/bit depth;identify/red min;identify/red max;identify/red mean;identify/red standard deviation;identify/green min;identify/green max;identify/green mean;identify/green standard deviation;identify/blue min;identify/blue max;identify/blue mean;identify/blue standard deviation" > $EVALUATION_OUTPUT_FILE
            fi

            echo "$COVER;$(basename $SAMPLE);$RES_FILE_FORMAT;$RES_FILE_JFIF;$RES_FILE_SEGLENGTH;$RES_FILE_PRECISION;$RES_FILE_RESOLUTION;$RES_FILE_FRAMES;$RES_EXIFTOOL_FILESIZE;$RES_EXIFTOOL_MIME;$RES_EXIFTOOL_JFIF;$RES_EXIFTOOL_ENCODING;$RES_EXIFTOOL_SAMPLEBITS;$RES_EXIFTOOL_RESOLUTION;$RES_EXIFTOOL_MEGAPIXELS;$RES_BINWALK_FORMAT;$RES_BINWALK_JFIF;$RES_FOREMOST;$RES_IDENTIFY_FORMAT;$RES_IDENTIFY_RESOLUTION;$RES_IDENTIFY_DEPTH;$RES_IDENTIFY_RED_MIN;$RES_IDENTIFY_RED_MAX;$RES_IDENTIFY_RED_MEAN;$RES_IDENTIFY_RED_SD;$RES_IDENTIFY_GREEN_MIN;$RES_IDENTIFY_GREEN_MAX;$RES_IDENTIFY_GREEN_MEAN;$RES_IDENTIFY_GREEN_SD;$RES_IDENTIFY_BLUE_MIN;$RES_IDENTIFY_BLUE_MAX;$RES_IDENTIFY_BLUE_MEAN;$RES_IDENTIFY_BLUE_SD" >> $EVALUATION_OUTPUT_FILE
        done

        formatPath *.jpg
        #TODO: display total detect count for this cover
        #printLine1 "analysis/done" "Analysed ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} $RETVAL-file-samples, got a total of ${COL_2}$DETECT_COUNT_TOTAL${COL_OFF} detects!"
        printLine1 "analysis/done" "Analysed ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} $RETVAL-file-samples."

        formatPath $COVER
        printLine0 "cover/done" "Done working on $RETVAL."
    done

    formatPath *.jpg
    printLine0 "main/done" "Worked through ${COL_2}$PARAM_SIZE${COL_OFF} $RETVAL-covers."
fi

exit 0