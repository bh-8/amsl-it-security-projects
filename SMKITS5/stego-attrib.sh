#!/bin/bash

#Script Version
SCRIPT_VERSION=3.70

#   //////////////////////
#  //  STATIC DEFINES  //
# //////////////////////

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

#sha1 sum of empty string
EMPTY_SHA1="da39a3ee5e6b4b0d3255bfef95601890afd80709"

#embedding data links
LINK_EMBEDDING_SHORT="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/shortEmbedding.txt"
LINK_EMBEDDING_MIDDLE="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/middleEmbedding.txt"
LINK_EMBEDDING_LONG="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/longEmbedding.txt"
LINK_EMBEDDING_LOWENTROPY="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/lowEntropyEmbedding.txt"
LINK_EMBEDDING_BINARY="https://raw.githubusercontent.com/birne420/amsl-it-security-projects/main/SMKITS5/embeddingData/binaryEmbedding"

#local embedding data paths
EMBEDDING_SHORT=$(realpath ./embeddingShort.txt)
EMBEDDING_MIDDLE=$(realpath ./embeddingMiddle.txt)
EMBEDDING_LONG=$(realpath ./embeddingLong.txt)
EMBEDDING_LOWENTROPY=$(realpath ./embeddingLowEntropy.txt)
EMBEDDING_BINARY=$(realpath ./embeddingBinary)

#passphrases
PASSPHRASE_SHORT="TEST"
PASSPHRASE_LONG="THIS_IS_A_PRETTY_LONG_PASSPHRASE_TRUST_ME_ITS_HUGE"

#passphrase wordlist location
PASSPHRASE_WORDLIST=$(realpath ./passphrases.txt)

#   ///////////////////////
#  //  CONSOLE UTILITY  //
# ///////////////////////

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
    echo "    -r, --randomize                  Use random subset of cover files"
    echo "    -c, --clean                      Clean output directory prior new analysis"
    echo "    -d, --delete                     Delete analysis data after evaluation"
    echo "    -f, --fast                       Skip f5 embedding and stegoveritas analysis"
    echo "    -v, --verbose                    Print everything"
    echo ""
    echo "    -h, --help"
    exit 1
}

#print error and exit
function printErrorAndExit {
    printError "${1}"
    exit 2
}

#formatted print line
function printLine0 {
    echo -e "${COL_1}> ${COL_3}[${COL_1}${1}${COL_3}]${COL_OFF} ${2}"
}
function printLine1 {
    echo -e "  ${COL_1}> ${COL_3}[${COL_1}${1}${COL_3}]${COL_OFF} ${2}"
}
function printLine2 {
    echo -e "    ${COL_2}> ${COL_3}[${COL_2}${1}${COL_3}]${COL_OFF} ${2}"
}
function printLine3 {
    if [ $PARAM_VERBOSE -eq 1 ]; then
        echo -e "      ${COL_3}> ${COL_3}[${COL_3}${1}${COL_3}]${COL_OFF} ${2}"
    fi
}

#format path
function formatPath {
    RETURN_FPATH="${COL_OFF}'${COL_3}${1}${COL_OFF}'"
}

#get current timestamp
function formatCurrentTimestamp {
    DATETIME_NOW=$(date "+%F %H:%M:%S")
    RETURN_TIMESTAMP="${COL_3}$DATETIME_NOW${COL_OFF}"
}

#   /////////////////////////
#  //  EMBEDDING UTILITY  //
# /////////////////////////

#return corresponding embedding type
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

#return default hashes of embeds
function getEmbeddingTypeHash {
    case ${1} in
        *Short*) RETURN_EBDHASH=$EMBEDDING_SHORT_SHA1 ;;
        *Long*) RETURN_EBDHASH=$EMBEDDING_LONG_SHA1 ;;
        *Middle*) RETURN_EBDHASH=$EMBEDDING_MIDDLE_SHA1 ;;
        *LowEntropy*) RETURN_EBDHASH=$EMBEDDING_LOWENTROPY_SHA1 ;;
        *Binary*) RETURN_EBDHASH=$EMBEDDING_BINARY_SHA1 ;;
        *) RETURN_EBDHASH=null ;;
    esac
}

#return corresponding key
function getKeyByType {
    case ${1} in
        shortKey) RETURN_KEY=$PASSPHRASE_SHORT ;;
        longKey) RETURN_KEY=$PASSPHRASE_LONG ;;
        *) RETURN_KEY=null ;;
    esac
}

#   /////////////////////////
#  //  QUALITY ASSURANCE  //
# /////////////////////////

#docker should not be available inside docker environment, if so, script might run outside of docker!
if command -v docker &> /dev/null; then
    printErrorAndExit "This script is meant to be executed in a docker environment!"
fi

#check for help
if [ $# -eq 0 ] || [ $1 = "--help" ] || [ $1 = "-h" ]; then
    printHelpAndExit
fi

#variables to store parameters
PARAM_INPUT="./coverData"
PARAM_OUTPUT="./out-stego-attrib"
PARAM_SIZE=1
PARAM_RANDOMIZE=0
PARAM_CLEAN=0
PARAM_DELETE=0
PARAM_FAST=0
PARAM_VERBOSE=0

#parse parameters
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
                printErrorAndExit "Parameter '$param' requires a path to a directory!"
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
        --delete|-d)
            PARAM_DELETE=1 ;;
        --fast|-f)
            PARAM_FAST=1 ;;
        --verbose|-v)
            PARAM_VERBOSE=1 ;;
        *) ;;
    esac

    i=$j
done

PARAM_INPUT=$(realpath $PARAM_INPUT)
PARAM_OUTPUT=$(realpath $PARAM_OUTPUT)

#final output file location
EVALUATION_OUTPUT_FILE=$PARAM_OUTPUT/out.csv

#check if size is an integer
if ! [[ $PARAM_SIZE =~ $RE_NUMERIC ]] || [ $PARAM_SIZE -le 0 ]; then
    printErrorAndExit "'$PARAM_SIZE' is not a numeric expression or too small!"
fi

clear
echo ""
echo -e "${COL_3}  #################################################${COL_OFF}"
echo -e "${COL_3}  #                                               #${COL_OFF}"
echo -e "${COL_3}  #              ${COL_OFF}SMKITS: ${COL_1}StegoDetect${COL_3}              #${COL_OFF}"
echo -e "${COL_3}  #       ${COL_2}Attribution of potential embedded${COL_3}       #${COL_OFF}"
echo -e "${COL_3}  #             ${COL_2}hidden communication.${COL_3}             #${COL_OFF}"
echo -e "${COL_3}  #                     v${COL_1}$SCRIPT_VERSION${COL_3}                     #${COL_OFF}"
echo -e "${COL_3}  #                                               #${COL_OFF}"
echo -e "${COL_3}  #################################################${COL_OFF}"
echo ""

#check, if imagemagick is installed
if ! command -v compare &> /dev/null; then
    printLine0 "apt" "ImageMagick/compare not found. Installing now..."
    apt update
    apt install imagemagick imagemagick-doc -y
fi

#check if fixed modules available
if [ ! -f "./jphide-auto" ]; then
    formatPath "./jphide-auto"
    printErrorAndExit "Could not find $RETURN_FPATH. Make sure the environment setup was successful!"
fi
if [ ! -f "./jpseek-auto" ]; then
    formatPath "./jpseek-auto"
    printErrorAndExit "Could not find $RETURN_FPATH. Make sure the environment setup was successful!"
fi
if [ ! -f "./stegbreak-fix" ]; then
    formatPath "./stegbreak-fix"
    printErrorAndExit "Could not find $RETURN_FPATH. Make sure the environment setup was successful!"
fi
if [ ! -f "./stegbreak-rules.ini" ]; then
    formatPath "./stegbreak-rules.ini"
    printErrorAndExit "Could not find $RETURN_FPATH. Make sure the environment setup was successful!"
fi
if [ ! -f "/usr/local/share/stegbreak/rules.ini" ]; then
    mkdir "/usr/local/share/stegbreak"
    cp "./stegbreak-rules.ini" "/usr/local/share/stegbreak/rules.ini"
fi

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

#delete
if [ $PARAM_DELETE -eq 1 ]; then
    printLine0 "--delete" "Analysis data will be deleted!"
fi

#fast
if [ $PARAM_FAST -eq 1 ]; then
    printLine0 "--fast" "f5 and stegoveritas will be skipped!"
fi

#verbose
if [ $PARAM_VERBOSE -eq 1 ]; then
    printLine0 "--verbose" "advanced log output enabled!"
fi

#check if cover data directory exists
if [ ! -d $PARAM_INPUT ]; then
    formatPath $PARAM_INPUT
    printErrorAndExit "Could not find cover data at $RETURN_FPATH!"
fi

#count jpg files in cover directory
JPGS_FOUND_COVER=$(find $PARAM_INPUT -maxdepth 1 -type f -name "*.jpg" | wc -l)

#check if there are any jpg files available
if [ $JPGS_FOUND_COVER -eq 0 ]; then
    formatPath *.jpg
    printErrorAndExit "Cover image directory does not contain any $RETURN_FPATH files."
fi

#check if subset size is smaller or equal number of available files
if [ $PARAM_SIZE -gt $JPGS_FOUND_COVER ]; then
    printErrorAndExit "There are only ${COL_2}$JPGS_FOUND_COVER${COL_OFF} objects in specified directory!"
fi

formatPath $PARAM_INPUT
printLine0 "--input" "Cover location is set to $RETURN_FPATH."

formatPath $PARAM_OUTPUT
printLine0 "--output" "Output location is set to $RETURN_FPATH."

#make sure output directory exists
if [ ! -d "$PARAM_OUTPUT" ]; then
    mkdir $PARAM_OUTPUT
fi

formatPath *.jpg
printLine0 "main/start" "Going to embed, analyse and evaluate ${COL_2}$PARAM_SIZE${COL_OFF} of a total of ${COL_2}$JPGS_FOUND_COVER${COL_OFF} available $RETURN_FPATH-covers."

#capture timestamp
formatCurrentTimestamp
printLine0 "main" "Started at $RETURN_TIMESTAMP."
TIMESTAMP_MAIN_START=$(date +%s)

#retrieve example embedding data
if [ ! -f $EMBEDDING_SHORT ]; then
    formatPath $EMBEDDING_SHORT
    printLine1 "download" "Downloading example data $RETURN_FPATH to embed..."
    wget -N "$LINK_EMBEDDING_SHORT" -O "$EMBEDDING_SHORT" &> /dev/null
fi
if [ ! -f $EMBEDDING_MIDDLE ]; then
    formatPath $EMBEDDING_MIDDLE
    printLine1 "download" "Downloading example data $RETURN_FPATH to embed..."
    wget -N "$LINK_EMBEDDING_MIDDLE" -O "$EMBEDDING_MIDDLE" &> /dev/null
fi
if [ ! -f $EMBEDDING_LONG ]; then
    formatPath $EMBEDDING_LONG
    printLine1 "download" "Downloading example data $RETURN_FPATH to embed..."
    wget -N "$LINK_EMBEDDING_LONG" -O "$EMBEDDING_LONG" &> /dev/null
fi
if [ ! -f $EMBEDDING_LOWENTROPY ]; then
    formatPath $EMBEDDING_LOWENTROPY
    printLine1 "download" "Downloading example data $RETURN_FPATH to embed..."
    wget -N "$LINK_EMBEDDING_LOWENTROPY" -O "$EMBEDDING_LOWENTROPY" &> /dev/null
fi
if [ ! -f $EMBEDDING_BINARY ]; then
    formatPath $EMBEDDING_BINARY
    printLine1 "download" "Downloading example data $RETURN_FPATH to embed..."
    wget -N "$LINK_EMBEDDING_BINARY" -O "$EMBEDDING_BINARY" &> /dev/null
fi

#get original sha1 sums of embedding data
EMBEDDING_SHORT_SHA1=$(sha1sum $EMBEDDING_SHORT | cut -d " " -f1)
EMBEDDING_MIDDLE_SHA1=$(sha1sum $EMBEDDING_MIDDLE | cut -d " " -f1)
EMBEDDING_LONG_SHA1=$(sha1sum $EMBEDDING_LONG | cut -d " " -f1)
EMBEDDING_LOWENTROPY_SHA1=$(sha1sum $EMBEDDING_LOWENTROPY | cut -d " " -f1)
EMBEDDING_BINARY_SHA1=$(sha1sum $EMBEDDING_BINARY | cut -d " " -f1)

#write passphrases
echo "" > $PASSPHRASE_WORDLIST
echo $PASSPHRASE_SHORT >> $PASSPHRASE_WORDLIST
echo $PASSPHRASE_LONG >> $PASSPHRASE_WORDLIST

#   ////////////////////////
#  //  COVER INSPECTION  //
# ////////////////////////

#Loop cover directory
C=0
find $PARAM_INPUT -maxdepth 1 -type f -name "*.jpg" | sort $SORTING_PARAM | tail -$PARAM_SIZE | while read COVER; do
    C=$((C+1))

    #get cover file names
    COVER_BASENAME=$(basename $COVER)
    COVER_BASENAME_NO_EXT=$(basename $COVER .jpg)

    formatPath $COVER
    printLine0 "cover/start" "${COL_2}$C${COL_OFF}/${COL_2}$PARAM_SIZE${COL_OFF}: Working on $RETURN_FPATH..."

    #capture timestamp
    formatCurrentTimestamp
    printLine1 "cover" "Inspection started at $RETURN_TIMESTAMP."
    TIMESTAMP_COVER_START=$(date +%s)

    #stego output directory
    JPEG_OUTDIR=$PARAM_OUTPUT/$COVER_BASENAME_NO_EXT

    #make sure output directory exists
    if [ -d "$JPEG_OUTDIR" ]; then
        rm -dr $JPEG_OUTDIR
    fi
    mkdir $JPEG_OUTDIR

    #   //////////////////
    #  //  EMBEDDINGS  //
    # //////////////////

    #capture timestamp
    TIMESTAMP_EBD_START=$(date +%s)

    #cover for embeddings
    JPEG_COVER=$JPEG_OUTDIR/original.jpg

    #copy original cover to testset
    cp $COVER $JPEG_COVER
    COVER_SHA1=$(sha1sum $JPEG_COVER | cut -d " " -f1)

    formatPath $JPEG_COVER
    printLine1 "copy" "Original cover copied to $RETURN_FPATH."

    #temporary meta file
    META_EMBEDDING=$JPEG_OUTDIR/embeddings.csv

    echo "cover;cover sha1;stego;stego sha1;stego tool;stego embed;stego key;embed hash;embed hash out" > $META_EMBEDDING
    echo "$COVER;$COVER_SHA1;$JPEG_COVER;$COVER_SHA1;-;-;-;-;-" >> $META_EMBEDDING
    printLine1 "embedding/start" "Embedding data to samples..."

    #check image size
    RESO_CHECK=$(exiftool $JPEG_COVER | grep "Image Size" | cut -d ":" -f2 | xargs)
    RESO_CHECK_W=$(echo $RESO_CHECK | cut -d "x" -f1)
    RESO_CHECK_H=$(echo $RESO_CHECK | cut -d "x" -f2)

    {
        #jphide/jpseek does not support no keys!
        KEY_ARR=(shortKey longKey)
        EMBEDDING_DATA=($EMBEDDING_SHORT $EMBEDDING_MIDDLE $EMBEDDING_LONG $EMBEDDING_LOWENTROPY $EMBEDDING_BINARY)
        STEGO_TOOL=jphide
        printLine2 $STEGO_TOOL
        mkdir $JPEG_OUTDIR/$STEGO_TOOL
        for KEY_TYPE in "${KEY_ARR[@]}"; do
            for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
                getEmbeddingTypeText $(basename $EMBEDDING_FILE})
                getEmbeddingTypeHash $(basename $EMBEDDING_FILE)
                JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL/$RETURN_EBDTEXT-$KEY_TYPE
                JPEG_STEGO=$JPEG_STEGO_NO_EXT.jpg

                getKeyByType $KEY_TYPE
                #embedding
                printLine3 "exec" "./jphide-auto $JPEG_COVER $JPEG_STEGO $EMBEDDING_FILE $RETURN_KEY"
                ./jphide-auto $JPEG_COVER $JPEG_STEGO $EMBEDDING_FILE $RETURN_KEY &> /dev/null

                #extracting
                printLine3 "exec" "./jpseek-auto $JPEG_STEGO $JPEG_STEGO_NO_EXT.out $RETURN_KEY"
                ./jpseek-auto $JPEG_STEGO $JPEG_STEGO_NO_EXT.out $RETURN_KEY &> /dev/null

                #stegbreak
                printLine3 "exec" "./stegbreak-fix -t p -f $PASSPHRASE_WORDLIST $JPEG_STEGO"
                ./stegbreak-fix -t p -f $PASSPHRASE_WORDLIST $JPEG_STEGO &> $JPEG_STEGO.stegbreak

                #writing
                JPEG_STEGO_SHA1=$(sha1sum $JPEG_STEGO | cut -d " " -f1)
                OUT_SHA1=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
                echo "$COVER;$COVER_SHA1;$JPEG_STEGO;$JPEG_STEGO_SHA1;$STEGO_TOOL;$RETURN_EBDTEXT;$KEY_TYPE;$RETURN_EBDHASH;$OUT_SHA1" >> $META_EMBEDDING
            done
        done
    }
    {
        #jsteg does not support embed keys!
        EMBEDDING_DATA=($EMBEDDING_SHORT $EMBEDDING_MIDDLE $EMBEDDING_LONG $EMBEDDING_LOWENTROPY $EMBEDDING_BINARY)
        STEGO_TOOL=jsteg
        printLine2 $STEGO_TOOL
        mkdir $JPEG_OUTDIR/$STEGO_TOOL
        for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
            getEmbeddingTypeText $(basename $EMBEDDING_FILE)
            getEmbeddingTypeHash $(basename $EMBEDDING_FILE)
            JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL/$RETURN_EBDTEXT-noKey
            JPEG_STEGO=$JPEG_STEGO_NO_EXT.jpg

            #embedding
            printLine3 "exec" "$STEGO_TOOL hide $JPEG_COVER $EMBEDDING_FILE $JPEG_STEGO"
            $STEGO_TOOL hide $JPEG_COVER $EMBEDDING_FILE $JPEG_STEGO &> /dev/null

            #extracting
            printLine3 "exec" "$STEGO_TOOL reveal $JPEG_STEGO $JPEG_STEGO_NO_EXT.out"
            $STEGO_TOOL reveal $JPEG_STEGO $JPEG_STEGO_NO_EXT.out &> /dev/null

            #stegbreak
            printLine3 "exec" "./stegbreak-fix -t j $JPEG_STEGO"
            ./stegbreak-fix -t j $JPEG_STEGO &> $JPEG_STEGO.stegbreak

            #writing
            JPEG_STEGO_SHA1=$(sha1sum $JPEG_STEGO | cut -d " " -f1)
            OUT_SHA1=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
            echo "$COVER;$COVER_SHA1;$JPEG_STEGO;$JPEG_STEGO_SHA1;$STEGO_TOOL;$RETURN_EBDTEXT;noKey;$RETURN_EBDHASH;$OUT_SHA1" >> $META_EMBEDDING
        done
    }
    {
        #outguess does not support binary embeds
        OUTGUESS_ARR=(outguess outguess-0.13)
        KEY_ARR=(noKey shortKey longKey)
        EMBEDDING_DATA=($EMBEDDING_SHORT $EMBEDDING_MIDDLE $EMBEDDING_LONG $EMBEDDING_LOWENTROPY $EMBEDDING_BINARY)
        for STEGO_TOOL in "${OUTGUESS_ARR[@]}"; do
            printLine2 $STEGO_TOOL
            mkdir $JPEG_OUTDIR/$STEGO_TOOL
            for KEY_TYPE in "${KEY_ARR[@]}"; do
                for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
                    getEmbeddingTypeText $(basename $EMBEDDING_FILE)
                    getEmbeddingTypeHash $(basename $EMBEDDING_FILE)
                    JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL/$RETURN_EBDTEXT-$KEY_TYPE
                    JPEG_STEGO=$JPEG_STEGO_NO_EXT.jpg

                    getKeyByType $KEY_TYPE
                    if [ $RETURN_KEY == "null" ]; then
                        #embedding
                        printLine3 "exec" "$STEGO_TOOL -d $EMBEDDING_FILE $JPEG_COVER $JPEG_STEGO"
                        $STEGO_TOOL -d $EMBEDDING_FILE $JPEG_COVER $JPEG_STEGO &> /dev/null

                        #extracting
                        printLine3 "exec" "$STEGO_TOOL -r $JPEG_STEGO $JPEG_STEGO_NO_EXT.out"
                        $STEGO_TOOL -r $JPEG_STEGO $JPEG_STEGO_NO_EXT.out &> /dev/null

                        #stegbreak
                        printLine3 "exec" "./stegbreak-fix -t o $JPEG_STEGO"
                        ./stegbreak-fix -t o $JPEG_STEGO &> $JPEG_STEGO.stegbreak
                    else
                        #embedding
                        printLine3 "exec" "$STEGO_TOOL -k $RETURN_KEY -d $EMBEDDING_FILE $JPEG_COVER $JPEG_STEGO"
                        $STEGO_TOOL -k $RETURN_KEY -d $EMBEDDING_FILE $JPEG_COVER $JPEG_STEGO &> /dev/null

                        #extracting
                        printLine3 "exec" "$STEGO_TOOL -k $RETURN_KEY -r $JPEG_STEGO $JPEG_STEGO_NO_EXT.out"
                        $STEGO_TOOL -k $RETURN_KEY -r $JPEG_STEGO $JPEG_STEGO_NO_EXT.out &> /dev/null

                        #stegbreak
                        printLine3 "exec" "./stegbreak-fix -t o -f $PASSPHRASE_WORDLIST $JPEG_STEGO"
                        ./stegbreak-fix -t o -f $PASSPHRASE_WORDLIST $JPEG_STEGO &> $JPEG_STEGO.stegbreak
                    fi

                    #writing
                    JPEG_STEGO_SHA1=$(sha1sum $JPEG_STEGO | cut -d " " -f1)
                    OUT_SHA1=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
                    echo "$COVER;$COVER_SHA1;$JPEG_STEGO;$JPEG_STEGO_SHA1;$STEGO_TOOL;$RETURN_EBDTEXT;$KEY_TYPE;$RETURN_EBDHASH;$OUT_SHA1" >> $META_EMBEDDING
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
        mkdir $JPEG_OUTDIR/$STEGO_TOOL
        for KEY_TYPE in "${KEY_ARR[@]}"; do
            for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
                getEmbeddingTypeText $(basename $EMBEDDING_FILE)
                getEmbeddingTypeHash $(basename $EMBEDDING_FILE)
                JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL/$RETURN_EBDTEXT-$KEY_TYPE
                JPEG_STEGO=$JPEG_STEGO_NO_EXT.jpg

                getKeyByType $KEY_TYPE
                #embedding
                printLine3 "exec" "$STEGO_TOOL embed -f -ef $EMBEDDING_FILE -cf $JPEG_COVER -p $RETURN_KEY -sf $JPEG_STEGO"
                $STEGO_TOOL embed -f -ef $EMBEDDING_FILE -cf $JPEG_COVER -p $RETURN_KEY -sf $JPEG_STEGO &> /dev/null

                #extracting
                printLine3 "exec" "$STEGO_TOOL extract -sf $JPEG_STEGO -p $RETURN_KEY -xf $JPEG_STEGO_NO_EXT.out"
                $STEGO_TOOL extract -sf $JPEG_STEGO -p $RETURN_KEY -xf $JPEG_STEGO_NO_EXT.out &> /dev/null

                #writing
                JPEG_STEGO_SHA1=$(sha1sum $JPEG_STEGO | cut -d " " -f1)
                OUT_SHA1=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
                echo "$COVER;$COVER_SHA1;$JPEG_STEGO;$JPEG_STEGO_SHA1;$STEGO_TOOL;$RETURN_EBDTEXT;$KEY_TYPE;$RETURN_EBDHASH;$OUT_SHA1" >> $META_EMBEDDING
            done
        done
    }
    {
        STEGO_TOOL=f5
        if [ $PARAM_FAST -eq 0 ]; then
            if [ $((RESO_CHECK_W)) -gt 1024 ] || [ $((RESO_CHECK_H)) -gt 1024 ]; then
                printLine2 $STEGO_TOOL "skipped, $RESO_CHECK is larger than 1024x1024!"
            else
                KEY_ARR=(noKey shortKey longKey)
                #f5 does not support binary embeds!
                EMBEDDING_DATA=($EMBEDDING_SHORT $EMBEDDING_MIDDLE $EMBEDDING_LONG $EMBEDDING_LOWENTROPY)
                printLine2 $STEGO_TOOL
                mkdir $JPEG_OUTDIR/$STEGO_TOOL
                for KEY_TYPE in "${KEY_ARR[@]}"; do
                    for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
                        getEmbeddingTypeText $(basename $EMBEDDING_FILE)
                        getEmbeddingTypeHash $(basename $EMBEDDING_FILE)
                        JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL/$RETURN_EBDTEXT-$KEY_TYPE
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
                        JPEG_STEGO_SHA1=$(sha1sum $JPEG_STEGO | cut -d " " -f1)
                        OUT_SHA1=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
                        echo "$COVER;$COVER_SHA1;$JPEG_STEGO;$JPEG_STEGO_SHA1;$STEGO_TOOL;$RETURN_EBDTEXT;$KEY_TYPE;$RETURN_EBDHASH;$OUT_SHA1" >> $META_EMBEDDING
                    done
                done
            fi
        else
            printLine2 $STEGO_TOOL "skipped due to --fast switch!"
        fi
    }

    #print timestamp and diff time
    TIMESTAMP_EBD_END=$(date +%s)
    TIMESTAMP_EBD_DIFF=$((TIMESTAMP_EBD_END-TIMESTAMP_EBD_START))
    TIMESTAMP_EBD_DIFF_M=$((TIMESTAMP_EBD_DIFF/60))
    TIMESTAMP_EBD_DIFF_S=$((TIMESTAMP_EBD_DIFF%60))
    printLine1 "embedding/done" "Embedded data to samples, took $TIMESTAMP_EBD_DIFF_M mins and $TIMESTAMP_EBD_DIFF_S secs."

    #   ////////////////////
    #  //  STEGANALYSIS  //
    # ////////////////////

    #capture timestamp
    TIMESTAMP_STEG_START=$(date +%s)
    
    #diff images of stegoveritas to analyse
    VERITAS_TARGETS=(red_plane green_plane blue_plane Edge-enhance Edge-enhance_More Find_Edges GaussianBlur inverted Max Median Min Mode Sharpen Smooth)

    #count stego samples
    JPGS_FOUND_STEGO=$(find $JPEG_OUTDIR -maxdepth 2 -type f -name "*.jpg" | wc -l)

    if [ $JPGS_FOUND_STEGO -eq 0 ]; then
        printErrorAndExit "No stego files found!"
    fi

    META_ANALYSIS=$PARAM_OUTPUT/$COVER_BASENAME_NO_EXT.csv
    csv_HEADER="cover file;cover sha1;stego file;stego sha1;stego tool;stego embed;stego key;embed hash;embed hash out"
    csv_HEADER="$csv_HEADER;stego file content;extracted data;stegdetect;stegbreak"
    for TARGET in "${VERITAS_TARGETS[@]}"; do
        csv_HEADER="$csv_HEADER;stegoveritas/diff $TARGET"
    done
    csv_HEADER="$csv_HEADER;file/data type"
    csv_HEADER="$csv_HEADER;exiftool/file size;exiftool/camera;exiftool/mime type;exiftool/jfif version;exiftool/encoding;exiftool/color components;exiftool/resolution;exiftool/megapixels"
    csv_HEADER="$csv_HEADER;binwalk/data type;binwalk/jfif version"
    csv_HEADER="$csv_HEADER;strings/header"
    csv_HEADER="$csv_HEADER;foremost/extracted data length;foremost/extracted data hash"
    csv_HEADER="$csv_HEADER;imagemagick/diff image;imagemagick/format;imagemagick/min;imagemagick/max;imagemagick/mean;imagemagick/standard deviation;imagemagick/kurtosis;imagemagick/skewness;imagemagick/entropy"
    echo "$csv_HEADER" > $META_ANALYSIS

    printLine1 "analysis/start" "Analysing ${COL_2}$JPGS_FOUND_STEGO${COL_OFF} samples..."
    DETECT_COUNT_TOTAL=0

    SCREENING_TOOLS=("file" "exiftool" "binwalk" "strings")

    D=0
    while IFS=";" read -r csv_COVER csv_COVER_SHA1 csv_STEGO csv_STEGO_SHA1 csv_STEGO_TOOL csv_STEGO_EMBED csv_STEGO_KEY csv_EMBED_HASH csv_EMBED_HASH_OUT; do
        D=$((D+1))
        formatPath $csv_STEGO
        FORMATTED_SAMPLE=$RETURN_FPATH
        OUT_BASEPATH=$(dirname $csv_STEGO)/$(basename $csv_STEGO)

        csv_STEGO_CONTENT_VALID="-"
        csv_EMBEDDED_DATA_CHECKSUMS="-"
        csv_STEGDETECT="-"
        csv_STEGBREAK="-"
        csv_STEGOVERITAS=""
        for TARGET in "${VERITAS_TARGETS[@]}"; do
            csv_STEGOVERITAS="$csv_STEGOVERITAS;-"
        done
        csv_FILE_FORMAT="-"
        csv_EXIFTOOL_SIZE="-"
        csv_EXIFTOOL_CAMERA="-"
        csv_EXIFTOOL_MIME="-"
        csv_EXIFTOOL_JFIF="-"
        csv_EXIFTOOL_ENCODING="-"
        csv_EXIFTOOL_COLORCOMPONENTS="-"
        csv_EXIFTOOL_RESOLUTION="-"
        csv_EXIFTOOL_MEGAPIXELS="-"
        csv_BINWALK_FORMAT="-"
        csv_BINWALK_JFIF="-"
        csv_STRINGS_HEADER="-"
        csv_FOREMOST_LENGTH="-"
        csv_FOREMOST_SHA1="-"
        csv_IMAGICK_DIFF_MEAN="-"
        csv_IMAGICK_FORMAT="-"
        csv_IMAGICK_OVERALL_MIN="-"
        csv_IMAGICK_OVERALL_MAX="-"
        csv_IMAGICK_OVERALL_MEAN="-"
        csv_IMAGICK_OVERALL_SD="-"
        csv_IMAGICK_OVERALL_KURTOSIS="-"
        csv_IMAGICK_OVERALL_SKEWNESS="-"
        csv_IMAGICK_OVERALL_ENTROPY="-"

        if [ $csv_STEGO_SHA1 == $EMPTY_SHA1 ]; then
            csv_STEGO_CONTENT_VALID="empty"

            printLine2 "skipped" "${COL_2}$D${COL_OFF}/${COL_2}$JPGS_FOUND_STEGO${COL_OFF}: $FORMATTED_SAMPLE is empty!"
        else
            #   /////////////////
            #  //  SCREENING  //
            # /////////////////

            printLine2 "screening" "${COL_2}$D${COL_OFF}/${COL_2}$JPGS_FOUND_STEGO${COL_OFF}: Working on $FORMATTED_SAMPLE..."

            for SCREENING_TOOL in "${SCREENING_TOOLS[@]}"; do
                printLine3 "exec" "$SCREENING_TOOL $csv_STEGO"
                $SCREENING_TOOL $csv_STEGO &> $OUT_BASEPATH.$SCREENING_TOOL
            done
                
            #foremost
            printLine3 "exec" "foremost -o $OUT_BASEPATH.foremost -i $csv_STEGO"
            foremost -o $OUT_BASEPATH.foremost -i $csv_STEGO &> /dev/null

            #imagemagick stuff
            printLine3 "exec" "compare $csv_STEGO $COVER -highlight-color black -compose src $(dirname $csv_STEGO)/$(basename $csv_STEGO .jpg).diff.jpg"
            compare $csv_STEGO $COVER -compose src -highlight-color black $(dirname $csv_STEGO)/$(basename $csv_STEGO .jpg).diff.jpg &> /dev/null
            printLine3 "exec" "identify -verbose $csv_STEGO"
            identify -verbose $csv_STEGO &> $OUT_BASEPATH.identify

            #stegoveritas
            if [ $PARAM_FAST -eq 0 ]; then
                if [ $((RESO_CHECK_W)) -gt 1024 ] || [ $((RESO_CHECK_H)) -gt 1024 ]; then
                    printLine2 "stegoveritas" "skipped, $RESO_CHECK is larger than 1024x1024!"
                else
                    VERITAS_STEGO=$OUT_BASEPATH.stegoveritas

                    printLine3 "exec" "stegoveritas $csv_STEGO -out $VERITAS_STEGO -meta -imageTransform -colorMap -trailing -steghide -xmp -carve"
                    stegoveritas $csv_STEGO -out $VERITAS_STEGO -meta -imageTransform -colorMap -trailing -steghide -xmp -carve &> /dev/null

                    #if stegoveritas directory exists
                    if [ -d $VERITAS_STEGO ]; then
                        VERITAS_COVER=$JPEG_OUTDIR/$(basename $JPEG_COVER).stegoveritas
                        VERITAS_STEGO_OUT=$VERITAS_STEGO/diff
                        mkdir $VERITAS_STEGO_OUT

                        #loop all veritas files
                        find "$VERITAS_STEGO" -maxdepth 1 -type f -name "*.png" | while read VERITAS_DIFF_STEGO; do
                            VERITAS_DIFF_COVER=$VERITAS_COVER/$(basename $JPEG_COVER)_$(basename $VERITAS_DIFF_STEGO | cut -d "_" -f2-)
                            VERITAS_DIFF_OUT=$VERITAS_STEGO_OUT/$(basename $VERITAS_DIFF_STEGO | cut -d "_" -f2-)
                            
                            #create diff images
                            printLine3 "exec" "compare $VERITAS_DIFF_STEGO $VERITAS_DIFF_COVER -compose src -highlight-color black $VERITAS_DIFF_OUT"
                            compare $VERITAS_DIFF_STEGO $VERITAS_DIFF_COVER -compose src -highlight-color black $VERITAS_DIFF_OUT &> /dev/null
                        done
                    fi
                fi
            else
                printLine3 "stegoveritas" "skipped due to --fast switch!"
            fi

            #stegdetect (detect jphide, jsteg, outguess, outguess-0.13, f5)
            printLine3 "exec" "stegdetect -t jopfa $csv_STEGO"
            stegdetect -t jopfa $csv_STEGO &> $OUT_BASEPATH.stegdetect

            #   ///////////////
            #  //  PARSING  //
            # ///////////////

            printLine2 "parsing" "${COL_2}$D${COL_OFF}/${COL_2}$JPGS_FOUND_STEGO${COL_OFF}: Parsing output for $FORMATTED_SAMPLE..."

            csv_STEGO_CONTENT_VALID="ok"
            if [ $csv_EMBED_HASH == $csv_EMBED_HASH_OUT ]; then
                csv_EMBEDDED_DATA_CHECKSUMS="ok"
            else
                if [ $csv_EMBED_HASH_OUT == $EMPTY_SHA1 ]; then
                    csv_EMBEDDED_DATA_CHECKSUMS="empty"
                else
                    csv_EMBEDDED_DATA_CHECKSUMS="corrupted"
                fi
            fi

            #stegoveritas with imagemagick
            if [ -d $OUT_BASEPATH.stegoveritas/diff ]; then
                csv_STEGOVERITAS=""
                for TARGET in "${VERITAS_TARGETS[@]}"; do
                    TARGET_PNG=$OUT_BASEPATH.stegoveritas/diff/$TARGET.png
                    if [ -f $TARGET_PNG ]; then
                        DIFF_VALUE=$(identify -verbose $TARGET_PNG | grep -m1 "mean:" | cut -d ":" -f2 | xargs)
                    else
                        DIFF_VALUE="-"
                    fi
                    csv_STEGOVERITAS="$csv_STEGOVERITAS;$DIFF_VALUE"
                done
            fi
            
            csv_STEGDETECT=$(cut -d ":" -f2 $OUT_BASEPATH.stegdetect | xargs)
            if [ -f $OUT_BASEPATH.stegbreak ]; then
                csv_STEGBREAK=$(cat $OUT_BASEPATH.stegbreak | tr "\n" " " | tr ";" " " | tr "," " " | xargs)
            fi

            csv_FILE_FORMAT=$(cut -d ":" -f2 $OUT_BASEPATH.file | xargs | cut -d "," -f1 | xargs)

            csv_EXIFTOOL_SIZE=$(grep "File Size" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_CAMERA=$(grep "Camera Model Name" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_MIME=$(grep "MIME Type" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_JFIF=$(grep "JFIF Version" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_ENCODING=$(grep "Encoding Process" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | tr "," "/" | xargs)
            csv_EXIFTOOL_COLORCOMPONENTS=$(grep "Color Components" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_RESOLUTION=$(grep "Image Size" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_MEGAPIXELS=$(grep "Megapixels" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)

            TMP_BINWALK=$(tail -n +4 $OUT_BASEPATH.binwalk | xargs | cut -d " " -f3-)
            csv_BINWALK_FORMAT=$(echo "$TMP_BINWALK" | cut -d "," -f1)
            csv_BINWALK_JFIF=$(echo "$TMP_BINWALK" | cut -d "," -f2 | xargs)

            csv_STRINGS_HEADER=$(sed 's/\t/ /g' $OUT_BASEPATH.strings | head -9 | tr "\n" " " | tr "," " " | tr ";" " " | xargs -0)

            csv_FOREMOST_LENGTH=$(grep "Length: " $OUT_BASEPATH.foremost/audit.txt | cut -d ":" -f2 | xargs)
            if [ -f $OUT_BASEPATH.foremost/jpg/00000000.jpg ]; then
                csv_FOREMOST_SHA1=$(sha1sum $OUT_BASEPATH.foremost/jpg/00000000.jpg | cut -d " " -f1)
            fi
            
            csv_IMAGICK_DIFF_MEAN=$(identify -verbose $(dirname $csv_STEGO)/$(basename $csv_STEGO .jpg).diff.jpg | grep -m1 "mean:" | cut -d ":" -f2 | xargs)
            csv_IMAGICK_FORMAT=$(grep "Format:" $OUT_BASEPATH.identify | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_MIN=$(grep "min:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_MAX=$(grep "max:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_MEAN=$(grep "mean:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_SD=$(grep "standard deviation:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_KURTOSIS=$(grep "kurtosis:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_SKEWNESS=$(grep "skewness:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_ENTROPY=$(grep "entropy:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
        fi

        csv_OUT="$csv_COVER;$csv_COVER_SHA1;$csv_STEGO;$csv_STEGO_SHA1;$csv_STEGO_TOOL;$csv_STEGO_EMBED;$csv_STEGO_KEY;$csv_EMBED_HASH;$csv_EMBED_HASH_OUT;$csv_STEGO_CONTENT_VALID;$csv_EMBEDDED_DATA_CHECKSUMS"
        csv_OUT="$csv_OUT;$csv_STEGDETECT"
        csv_OUT="$csv_OUT;$csv_STEGBREAK"
        csv_OUT="$csv_OUT$csv_STEGOVERITAS" #missing ; is intended!
        csv_OUT="$csv_OUT;$csv_FILE_FORMAT"
        csv_OUT="$csv_OUT;$csv_EXIFTOOL_SIZE;$csv_EXIFTOOL_CAMERA;$csv_EXIFTOOL_MIME;$csv_EXIFTOOL_JFIF;$csv_EXIFTOOL_ENCODING;$csv_EXIFTOOL_COLORCOMPONENTS;$csv_EXIFTOOL_RESOLUTION;$csv_EXIFTOOL_MEGAPIXELS"
        csv_OUT="$csv_OUT;$csv_BINWALK_FORMAT;$csv_BINWALK_JFIF"
        csv_OUT="$csv_OUT;$csv_STRINGS_HEADER"
        csv_OUT="$csv_OUT;$csv_FOREMOST_LENGTH;$csv_FOREMOST_SHA1"
        csv_OUT="$csv_OUT;$csv_IMAGICK_DIFF_MEAN;$csv_IMAGICK_FORMAT;$csv_IMAGICK_OVERALL_MIN;$csv_IMAGICK_OVERALL_MAX;$csv_IMAGICK_OVERALL_MEAN;$csv_IMAGICK_OVERALL_SD;$csv_IMAGICK_OVERALL_KURTOSIS;$csv_IMAGICK_OVERALL_SKEWNESS;$csv_IMAGICK_OVERALL_ENTROPY"

        echo "$csv_OUT" >> $META_ANALYSIS
    done < <(tail -n +2 $META_EMBEDDING)

    #print timestamp and diff time (analysis)
    TIMESTAMP_STEG_END=$(date +%s)
    TIMESTAMP_STEG_DIFF=$((TIMESTAMP_STEG_END-TIMESTAMP_STEG_START))
    TIMESTAMP_STEG_DIFF_M=$((TIMESTAMP_STEG_DIFF/60))
    TIMESTAMP_STEG_DIFF_S=$((TIMESTAMP_STEG_DIFF%60))
    printLine1 "analysis/done" "Screening done, took $TIMESTAMP_STEG_DIFF_M mins and $TIMESTAMP_STEG_DIFF_S secs."

    #print timestamp and diff time (cover)
    formatCurrentTimestamp
    TIMESTAMP_COVER_END=$(date +%s)
    TIMESTAMP_COVER_DIFF=$((TIMESTAMP_COVER_END-TIMESTAMP_COVER_START))
    TIMESTAMP_COVER_DIFF_M=$((TIMESTAMP_COVER_DIFF/60))
    TIMESTAMP_COVER_DIFF_S=$((TIMESTAMP_COVER_DIFF%60))

    #   //////////////////
    #  //  EVALUATION  //
    # //////////////////

    printLine1 "evaluation/start" "Evaluating..."

    META_EVALUATION=$PARAM_OUTPUT/evaluation.csv

    eval_TOOLS=(jphide jsteg outguess outguess-0.13 steghide f5)

    if [ ! -f $META_EVALUATION ]; then
        #csv header
        csv_HEADER="analysed image;embedding duration;analysis duration;total duration"
        for eval_TOOL in "${eval_TOOLS[@]}"; do
            csv_HEADER="$csv_HEADER;$eval_TOOL/working samples;$eval_TOOL/not working samples;$eval_TOOL/stegdetect detects"
        done
        echo "$csv_HEADER" > $META_EVALUATION
    fi

    #runtimes
    evalcsv_TIME_EBD="$TIMESTAMP_EBD_DIFF_M mins $TIMESTAMP_EBD_DIFF_S secs"
    evalcsv_TIME_STEG="$TIMESTAMP_STEG_DIFF_M mins $TIMESTAMP_STEG_DIFF_S secs"
    evalcsv_TIME_COVER="$TIMESTAMP_COVER_DIFF_M mins $TIMESTAMP_COVER_DIFF_S secs"

    declare -A evalmap_SAMPLES
    declare -A evalmap_WORKING_SAMPLES
    declare -A evalmap_NOT_WORKING_SAMPLES
    declare -A evalmap_STEGDETECT_COUNT
    declare -A evalmap_STEGDETECT
    for eval_TOOL in "${eval_TOOLS[@]}"; do
        evalmap_SAMPLES[$eval_TOOL]=0
        evalmap_WORKING_SAMPLES[$eval_TOOL]=0
        evalmap_NOT_WORKING_SAMPLES[$eval_TOOL]=""
        evalmap_STEGDETECT_COUNT[$eval_TOOL]=0
        evalmap_STEGDETECT[$eval_TOOL]=""
    done

    Z=0
    while read evalcsv_LINE; do
        IFS=';' read -r -a evalcsv_LINE_ARR <<< "$evalcsv_LINE"
        if [ $Z -eq 1 ]; then
            evalcsv_COVER_FILE=${evalcsv_LINE_ARR[0]}
        fi
        eval_TOOL=${evalcsv_LINE_ARR[4]}
        eval_SAMPLEID=${evalcsv_LINE_ARR[5]}${evalcsv_LINE_ARR[6]}

        #count stego images created for each tool
        evalmap_SAMPLES[$eval_TOOL]=$((evalmap_SAMPLES[$eval_TOOL]+1))

        #if embedding successful
        if [ "${evalcsv_LINE_ARR[9]}" == "ok" ]; then
            #count successful embeds for each tool
            evalmap_WORKING_SAMPLES[$eval_TOOL]=$((evalmap_WORKING_SAMPLES[$eval_TOOL]+1))

            #count stegdetect detects
            if [ "${evalcsv_LINE_ARR[11]}" != "negative" ]; then
                evalmap_STEGDETECT_COUNT[$eval_TOOL]=$((evalmap_STEGDETECT_COUNT[$eval_TOOL]+1))
                evalmap_STEGDETECT[$eval_TOOL]="${evalmap_STEGDETECT[$eval_TOOL]} [$eval_SAMPLEID as ${evalcsv_LINE_ARR[11]}]"
            fi

            #TODO: stegbreak -> so broken, macht das überhaupt sinn?
            #TODO: stegoveritas -> varianz innerhalb eines tools berechnen
            #TODO: file, exitfool, binwalk, strings -> vergleich mit originalcover
            #TODO: foremost, imagemagick
        else
            evalmap_NOT_WORKING_SAMPLES[$eval_TOOL]="${evalmap_NOT_WORKING_SAMPLES[$eval_TOOL]}[$eval_SAMPLEID] "
        fi

        Z=$((Z+1))
    done < $META_ANALYSIS

    evalcsv_TOOLS=""
    for eval_TOOL in "${eval_TOOLS[@]}"; do
        evalcsv_TOOLS="$evalcsv_TOOLS;${evalmap_WORKING_SAMPLES[$eval_TOOL]}/${evalmap_SAMPLES[$eval_TOOL]};${evalmap_NOT_WORKING_SAMPLES[$eval_TOOL]};${evalmap_STEGDETECT_COUNT[$eval_TOOL]}${evalmap_STEGDETECT[$eval_TOOL]}"
    done

    #append line
    echo "$evalcsv_COVER_FILE;$evalcsv_TIME_EBD;$evalcsv_TIME_STEG;$evalcsv_TIME_COVER$evalcsv_TOOLS" >> $META_EVALUATION

    printLine1 "evaluation/done" "Done!"
 
    #delete switch
    if [ $PARAM_DELETE -eq 1 ]; then
        rm -dr $JPEG_OUTDIR
    fi

    printLine1 "cover" "Inspection finished at $RETURN_TIMESTAMP, took $TIMESTAMP_COVER_DIFF_M mins and $TIMESTAMP_COVER_DIFF_S secs."

    formatPath $COVER
    printLine0 "cover/done" "${COL_2}$C${COL_OFF}/${COL_2}$PARAM_SIZE${COL_OFF}: Done with $RETURN_FPATH."
done
formatPath *.jpg
printLine0 "main/done" "Worked through ${COL_2}$PARAM_SIZE${COL_OFF} $RETURN_FPATH-covers."

#print timestamp and diff time
formatCurrentTimestamp
TIMESTAMP_MAIN_END=$(date +%s)
TIMESTAMP_MAIN_DIFF=$((TIMESTAMP_MAIN_END-TIMESTAMP_MAIN_START))
TIMESTAMP_MAIN_DIFF_H=$((TIMESTAMP_MAIN_DIFF/60/60))
TIMESTAMP_MAIN_DIFF_M=$((TIMESTAMP_MAIN_DIFF/60%60))
TIMESTAMP_MAIN_DIFF_S=$((TIMESTAMP_MAIN_DIFF%60))
printLine0 "main" "Finished at $RETURN_TIMESTAMP, took $TIMESTAMP_MAIN_DIFF_H hrs, $TIMESTAMP_MAIN_DIFF_M mins and $TIMESTAMP_MAIN_DIFF_S secs."

exit 0