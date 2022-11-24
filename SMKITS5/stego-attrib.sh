#!/bin/bash

#Script Version 3.45

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
    echo "    -r, --randomize                    Use random subset of cover files"
    echo "    -c, --clean                      Clean output directory prior new analysis"
    echo "    -f, --fast                       Skip f5 embedding and stegoveritas analysis"
    echo "    -v, --verbose                    Print everything"
    echo ""
    echo "    -h, --help"
    exit
}

#print error and exit
function printErrorAndExit {
    printError "${1}"
    exit 1
}

#formatted print line
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

#format path
function formatPath {
    RETURN_FPATH="${COL_OFF}'${COL_3}${1}${COL_OFF}'"
}
#TODO: currently unused:
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

    #cover for embeddings
    JPEG_COVER=$JPEG_OUTDIR/original.jpg

    #copy original cover to testset
    cp $COVER $JPEG_COVER
    COVER_SHA1=$(sha1sum $JPEG_COVER | cut -d " " -f1)

    formatPath $JPEG_COVER
    printLine1 "copy" "Original cover copied to $RETURN_FPATH."

    #temporary meta file
    META_EMBEDDING=$JPEG_OUTDIR/_metaEmbedding.csv

    echo "cover;cover sha1;stego;stego sha1;stego tool;stego embed;stego key;embed hash;embed hash out" > $META_EMBEDDING
    echo "$COVER;$COVER_SHA1;$JPEG_COVER;$COVER_SHA1;-;-;-;-;-" >> $META_EMBEDDING
    printLine1 "embedding/start" "Embedding data to samples..."

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
        else
            printLine2 $STEGO_TOOL "skipped due to --fast switch!"
        fi
    }

    printLine1 "embedding/done" "Embedded data to samples."

    #   ////////////////////
    #  //  STEGANALYSIS  //
    # ////////////////////

    #count stego samples
    JPGS_FOUND_STEGO=$(find $JPEG_OUTDIR -maxdepth 2 -type f -name "*.jpg" | wc -l)

    if [ $JPGS_FOUND_STEGO -eq 0 ]; then
        printErrorAndExit "No stego files found!"
    fi

    META_ANALYSIS=$JPEG_OUTDIR/_metaAnalysis.csv
    #TODO: add more attributes due to analysis!!!
    echo "cover file;cover sha1;stego file;stego sha1;stego tool;stego embed;stego key;embed hash;embed hash out;stego file content;embedded data;stegdetect;stegbreak;file/data type;exiftool/file size;exiftool/camera;exiftool/mime type;exiftool/jfif version;exiftool/encoding;exiftool/bits per sample;exiftool/color components;exiftool/resolution;exiftool/megapixels;binwalk/data type;binwalk/jfif version;strings/header;foremost/extracted data length;foremost/extracted data hash;imagemagick/diff image avg grey;imagemagick/format;imagemagick/resolution;imagemagick/depth;imagemagick/min;imagemagick/max;imagemagick/mean;imagemagick/standard deviation;imagemagick/kurtosis;imagemagick/skewness;imagemagick/entropy;imagemagick/red min;imagemagick/red max;imagemagick/red mean;imagemagick/red standard deviation;imagemagick/green min;imagemagick/green max;imagemagick/green mean;imagemagick/green standard deviation;imagemagick/blue min;imagemagick/blue max;imagemagick/blue mean;imagemagick/blue standard deviation" > $META_ANALYSIS

    printLine1 "analysis/start" "Analysing ${COL_2}$JPGS_FOUND_STEGO${COL_OFF} samples..."
    DETECT_COUNT_TOTAL=0

    SCREENING_TOOLS=("file" "exiftool" "binwalk" "strings")

    D=0
    while IFS=";" read -r csv_COVER csv_COVER_SHA1 csv_STEGO csv_STEGO_SHA1 csv_STEGO_TOOL csv_STEGO_EMBED csv_STEGO_KEY csv_EMBED_HASH csv_EMBED_HASH_OUT; do
        D=$((D+1))
        formatPath $csv_STEGO
        FORMATTED_SAMPLE=$RETURN_FPATH
        OUT_BASEPATH=$(dirname $csv_STEGO)/$(basename $csv_STEGO)

        #DEPRECATED: exiftool/bits per pixel; IMAGICK: bit depth

        csv_STEGO_CONTENT_VALID="-"
        csv_EMBEDDED_DATA_CHECKSUMS="-"
        csv_STEGDETECT="-"
        csv_STEGBREAK="-"
        csv_FILE_FORMAT="-"
        csv_EXIFTOOL_SIZE="-"
        csv_EXIFTOOL_CAMERA="-"
        csv_EXIFTOOL_MIME="-"
        csv_EXIFTOOL_JFIF="-"
        csv_EXIFTOOL_ENCODING="-"
        csv_EXIFTOOL_BITSPERSAMPLE="-"
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
        csv_IMAGICK_RESOLUTION="-"
        csv_IMAGICK_DEPTH="-"
        csv_IMAGICK_OVERALL_MIN="-"
        csv_IMAGICK_OVERALL_MAX="-"
        csv_IMAGICK_OVERALL_MEAN="-"
        csv_IMAGICK_OVERALL_SD="-"
        csv_IMAGICK_OVERALL_KURTOSIS="-"
        csv_IMAGICK_OVERALL_SKEWNESS="-"
        csv_IMAGICK_OVERALL_ENTROPY="-"
        csv_IMAGICK_RED_MIN="-"
        csv_IMAGICK_RED_MAX="-"
        csv_IMAGICK_RED_MEAN="-"
        csv_IMAGICK_RED_SD="-"
        csv_IMAGICK_GREEN_MIN="-"
        csv_IMAGICK_GREEN_MAX="-"
        csv_IMAGICK_GREEN_MEAN="-"
        csv_IMAGICK_GREEN_SD="-"
        csv_IMAGICK_BLUE_MIN="-"
        csv_IMAGICK_BLUE_MAX="-"
        csv_IMAGICK_BLUE_MEAN="-"
        csv_IMAGICK_BLUE_SD="-"

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
                        VERITAS_DIFF_OUT=$VERITAS_STEGO_OUT/$(basename $VERITAS_DIFF_STEGO)
                        
                        #create diff images
                        printLine3 "exec" "compare $VERITAS_DIFF_STEGO $VERITAS_DIFF_COVER -compose src -highlight-color black $VERITAS_DIFF_OUT"
                        compare $VERITAS_DIFF_STEGO $VERITAS_DIFF_COVER -compose src -highlight-color black $VERITAS_DIFF_OUT &> /dev/null
                    done
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
                csv_EMBEDDED_DATA_CHECKSUMS="valid"
            else
                if [ $csv_EMBED_HASH_OUT == $EMPTY_SHA1 ]; then
                    csv_EMBEDDED_DATA_CHECKSUMS="lost"
                else
                    csv_EMBEDDED_DATA_CHECKSUMS="corrupted"
                fi
            fi

            csv_STEGDETECT=$(cut -d ":" -f2 $OUT_BASEPATH.stegdetect | xargs)
            if [ -f $OUT_BASEPATH.stegbreak ]; then
                csv_STEGBREAK=$(cat $OUT_BASEPATH.stegbreak | tr "\n" " ")
            fi

            csv_FILE_FORMAT=$(cut -d ":" -f2 $OUT_BASEPATH.file | xargs | cut -d "," -f1 | xargs)

            csv_EXIFTOOL_SIZE=$(grep "File Size" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_CAMERA=$(grep "Camera Model Name" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_MIME=$(grep "MIME Type" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_JFIF=$(grep "JFIF Version" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_ENCODING=$(grep "Encoding Process" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | tr "," "/" | xargs)
            csv_EXIFTOOL_BITSPERSAMPLE=$(grep "Bits Per Sample" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_COLORCOMPONENTS=$(grep "Color Components" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_RESOLUTION=$(grep "Image Size" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)
            csv_EXIFTOOL_MEGAPIXELS=$(grep "Megapixels" $OUT_BASEPATH.exiftool | cut -d ":" -f 2 | xargs)

            TMP_BINWALK=$(tail -n +4 $OUT_BASEPATH.binwalk | xargs | cut -d " " -f3-)
            csv_BINWALK_FORMAT=$(echo "$TMP_BINWALK" | cut -d "," -f1)
            csv_BINWALK_JFIF=$(echo "$TMP_BINWALK" | cut -d "," -f2 | xargs)

            csv_STRINGS_HEADER=$(sed 's/\t/ /g' $OUT_BASEPATH.strings | head -9 | tr "\n" " " | tr "," " " | tr ";" " " | xargs)

            csv_FOREMOST_LENGTH=$(grep "Length: " $OUT_BASEPATH.foremost/audit.txt | cut -d ":" -f2 | xargs)
            csv_FOREMOST_SHA1=$(sha1sum $OUT_BASEPATH.foremost/jpg/00000000.jpg | cut -d " " -f1)

            csv_IMAGICK_DIFF_MEAN=$(identify -verbose $(dirname $csv_STEGO)/$(basename $csv_STEGO .jpg).diff.jpg | grep -m1 "mean:" | cut -d ":" -f2 | xargs)
            csv_IMAGICK_FORMAT=$(grep "Format:" $OUT_BASEPATH.identify | cut -d ":" -f2 | xargs)
            csv_IMAGICK_RESOLUTION=$(grep "Geometry:" $OUT_BASEPATH.identify | cut -d ":" -f2 | xargs)
            csv_IMAGICK_DEPTH=$(grep "Depth:" $OUT_BASEPATH.identify | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_MIN=$(grep "min:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_MAX=$(grep "max:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_MEAN=$(grep "mean:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_SD=$(grep "standard deviation:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_KURTOSIS=$(grep "kurtosis:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_SKEWNESS=$(grep "skewness:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_OVERALL_ENTROPY=$(grep "entropy:" $OUT_BASEPATH.identify | tail -1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_RED_MIN=$(grep -m1 "min:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_RED_MAX=$(grep -m1 "max:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_RED_MEAN=$(grep -m1 "mean:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_RED_SD=$(grep -m1 "standard deviation:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_GREEN_MIN=$(grep -m2 "min:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_GREEN_MAX=$(grep -m2 "max:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_GREEN_MEAN=$(grep -m2 "mean:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_GREEN_SD=$(grep -m2 "standard deviation:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_BLUE_MIN=$(grep -m3 "min:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_BLUE_MAX=$(grep -m3 "max:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_BLUE_MEAN=$(grep -m3 "mean:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            csv_IMAGICK_BLUE_SD=$(grep -m3 "standard deviation:" $OUT_BASEPATH.identify | tail -n1 | cut -d ":" -f2 | xargs)
            
            #TODO stegoveritas imagemagick analysis...
        fi

        csv_OUT="$csv_COVER;$csv_COVER_SHA1;$csv_STEGO;$csv_STEGO_SHA1;$csv_STEGO_TOOL;$csv_STEGO_EMBED;$csv_STEGO_KEY;$csv_EMBED_HASH;$csv_EMBED_HASH_OUT;$csv_STEGO_CONTENT_VALID;$csv_EMBEDDED_DATA_CHECKSUMS"
        csv_OUT="$csv_OUT;$csv_STEGDETECT"
        csv_OUT="$csv_OUT;$csv_STEGBREAK"
        csv_OUT="$csv_OUT;$csv_FILE_FORMAT"
        csv_OUT="$csv_OUT;$csv_EXIFTOOL_SIZE;$csv_EXIFTOOL_CAMERA;$csv_EXIFTOOL_MIME;$csv_EXIFTOOL_JFIF;$csv_EXIFTOOL_ENCODING;$csv_EXIFTOOL_BITSPERSAMPLE;$csv_EXIFTOOL_COLORCOMPONENTS;$csv_EXIFTOOL_RESOLUTION;$csv_EXIFTOOL_MEGAPIXELS"
        csv_OUT="$csv_OUT;$csv_BINWALK_FORMAT;$csv_BINWALK_JFIF"
        csv_OUT="$csv_OUT;$csv_STRINGS_HEADER"
        csv_OUT="$csv_OUT;$csv_FOREMOST_LENGTH;$csv_FOREMOST_SHA1"
        csv_OUT="$csv_OUT;$csv_IMAGICK_DIFF_MEAN;$csv_IMAGICK_FORMAT;$csv_IMAGICK_RESOLUTION;$csv_IMAGICK_DEPTH;$csv_IMAGICK_OVERALL_MIN;$csv_IMAGICK_OVERALL_MAX;$csv_IMAGICK_OVERALL_MEAN;$csv_IMAGICK_OVERALL_SD;$csv_IMAGICK_OVERALL_KURTOSIS;$csv_IMAGICK_OVERALL_SKEWNESS;$csv_IMAGICK_OVERALL_ENTROPY;$csv_IMAGICK_RED_MIN;$csv_IMAGICK_RED_MAX;$csv_IMAGICK_RED_MEAN;$csv_IMAGICK_RED_SD;$csv_IMAGICK_GREEN_MIN;$csv_IMAGICK_GREEN_MAX;$csv_IMAGICK_GREEN_MEAN;$csv_IMAGICK_GREEN_SD;$csv_IMAGICK_BLUE_MIN;$csv_IMAGICK_BLUE_MAX;$csv_IMAGICK_BLUE_MEAN;$csv_IMAGICK_BLUE_SD"

        echo "$csv_OUT" >> $META_ANALYSIS
    done < <(tail -n +2 $META_EMBEDDING)
       
    printLine1 "analysis/done" "Screening done!"

    #   //////////////////
    #  //  EVALUATION  //
    # //////////////////

    printLine1 "evaluation/start" "Evaluating..."

    #TODO KW47: write final results to csv output and delete data

    printLine1 "evaluation/done" "Done!"
 
    formatPath $COVER
    printLine0 "cover/done" "${COL_2}$C${COL_OFF}/${COL_2}$PARAM_SIZE${COL_OFF}: Done with $RETURN_FPATH."

done
formatPath *.jpg
printLine0 "main/done" "Worked through ${COL_2}$PARAM_SIZE${COL_OFF} $RETURN_FPATH-covers."

exit 0

        #################################################################

#        D=0
#        find $TESTSET_OUTPUT_DIRECTORY -maxdepth 1 -type f -name "*.jpg" | sort -d | while read SAMPLE; do

#            DETECT_COUNT=0

            #stegdetect
#            RES_STEGDETECT=$(cat $SAMPLE_OUTPUT_DIRECTORY/stegdetect.out | cut -d ":" -f 2 | xargs)
#            if [ "$RES_STEGDETECT" != "negative" ]; then
#                DETECT_COUNT=$((DETECT_COUNT+1))
#                printLine3 "stegdetect" "${COL_NO}$RES_STEGDETECT${COL_OFF}"
#            else
#                printLine3 "stegdetect" "${COL_YES}$RES_STEGDETECT${COL_OFF}"
#            fi



            #found something?
#            if [ ! $DETECT_COUNT -eq 0 ]; then
#                printLine2 "${COL_NO}probably found something" "${COL_NO}$DETECT_COUNT detects${COL_OFF}!"
#            else
#                printLine2 "${COL_YES}all clear"
#            fi

#            DETECT_COUNT_TOTAL=$((DETECT_COUNT_TOTAL+DETECT_COUNT))

            #write evaluation result
#            if [ ! -f "$EVALUATION_OUTPUT_FILE" ]; then
#                echo "original image;sample name;file/format;file/jfif;file/segment length;file/precision;file/resolution;file/frames;exiftool/file size;exiftool/mime type;exiftool/jfif;exiftool/encoding;exiftool/bits per sample;exiftool/resolution;exiftool/megapixels;binwalk/format;binwalk/jfif;foremost/extract;identify/format;identify/resolution;identify/bit depth;identify/red min;identify/red max;identify/red mean;identify/red standard deviation;identify/green min;identify/green max;identify/green mean;identify/green standard deviation;identify/blue min;identify/blue max;identify/blue mean;identify/blue standard deviation" > $EVALUATION_OUTPUT_FILE
#            fi

#            echo "$COVER;$(basename $SAMPLE);$RES_FILE_FORMAT;$RES_FILE_JFIF;$RES_FILE_SEGLENGTH;$RES_FILE_PRECISION;$RES_FILE_RESOLUTION;$RES_FILE_FRAMES;$RES_EXIFTOOL_FILESIZE;$RES_EXIFTOOL_MIME;$RES_EXIFTOOL_JFIF;$RES_EXIFTOOL_ENCODING;$RES_EXIFTOOL_SAMPLEBITS;$RES_EXIFTOOL_RESOLUTION;$RES_EXIFTOOL_MEGAPIXELS;$RES_BINWALK_FORMAT;$RES_BINWALK_JFIF;$RES_FOREMOST;$RES_IDENTIFY_FORMAT;$RES_IDENTIFY_RESOLUTION;$RES_IDENTIFY_DEPTH;$RES_IDENTIFY_RED_MIN;$RES_IDENTIFY_RED_MAX;$RES_IDENTIFY_RED_MEAN;$RES_IDENTIFY_RED_SD;$RES_IDENTIFY_GREEN_MIN;$RES_IDENTIFY_GREEN_MAX;$RES_IDENTIFY_GREEN_MEAN;$RES_IDENTIFY_GREEN_SD;$RES_IDENTIFY_BLUE_MIN;$RES_IDENTIFY_BLUE_MAX;$RES_IDENTIFY_BLUE_MEAN;$RES_IDENTIFY_BLUE_SD" >> $EVALUATION_OUTPUT_FILE
#        done

#        formatPath *.jpg
        #TODO: display total detect count for this cover
        #printLine1 "analysis/done" "Analysed ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} $RETURN_FPATH-file-samples, got a total of ${COL_2}$DETECT_COUNT_TOTAL${COL_OFF} detects!"
#        printLine1 "analysis/done" "Analysed ${COL_2}$JPGS_FOUND_TESTSET${COL_OFF} $RETURN_FPATH-file-samples."
