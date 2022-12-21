#!/bin/bash

#Script Version
SCRIPT_VERSION=3.92

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
    echo "    -h, --help                       Display this help page"
    echo "    -v, --verbose                    Print command executions"
    echo ""
    echo "Information gathering:"
    echo "    -i, --input <directory>          Path to cover files-directory (default is './coverData')"
    echo "    -o, --output <directory>         Specify output location (default is './out-stego-attrib')"
    echo ""
    echo "    -n, --size <int>                 Number of cover files to analyse (default is 1)"
    echo "    -m, --offset <int>               Amount of files to skip in cover directory (default is 0)"
    echo "    -r, --randomize                  Use random subset of cover files"
    echo "    -c, --clean                      Clean output directory prior new analysis"
    echo "    -d, --delete                     Delete analysis data after evaluation"
    echo ""
    echo "    --skip-f5                        Skip f5 embedding"
    echo "    --skip-stegoveritas              Skip stegoveritas analysis"
    echo "    --skip-embedding                 DEBUG SWITCH: skip embedding"
    echo "    --skip-analysis                  DEBUG SWITCH: skip analysis"
    echo ""
    echo "Attribute single jpg file based on our research results:"
    echo "    -x, --examine <stego jpg> [original jpg]"
    echo ""
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

#   //////////////////////////
#  //  PRINT FANCY HEADER  //
# //////////////////////////

function printHeader {
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
}

#   ////////////////////////////
#  //  FIXED TOOL EXISTENCE  //
# ////////////////////////////

function fixedToolCheck {
    #JPHIDE: not implemented, its broken!
    #if [ ! -f "./jphide-auto" ]; then
    #    formatPath "./jphide-auto"
    #    printErrorAndExit "Could not find $RETURN_FPATH. Make sure the environment setup was successful!"
    #fi
    #if [ ! -f "./jpseek-auto" ]; then
    #    formatPath "./jpseek-auto"
    #    printErrorAndExit "Could not find $RETURN_FPATH. Make sure the environment setup was successful!"
    #fi
    if [ ! -f "./stegbreak-fix" ]; then
        RTN_FIXEDTOOLCHECK=1
        formatPath "./stegbreak-fix"
        printErrorAndExit "Could not find $RETURN_FPATH. Make sure the environment setup was successful!"
    fi
    if [ ! -f "./stegbreak-rules.ini" ]; then
        RTN_FIXEDTOOLCHECK=1
        formatPath "./stegbreak-rules.ini"
        printErrorAndExit "Could not find $RETURN_FPATH. Make sure the environment setup was successful!"
    fi
    if [ ! -f "/usr/local/share/stegbreak/rules.ini" ]; then
        mkdir "/usr/local/share/stegbreak"
        cp "./stegbreak-rules.ini" "/usr/local/share/stegbreak/rules.ini"
    fi
    RTN_FIXEDTOOLCHECK=0
}

#   ////////////////////////
#  //  JPEG EXAMINATION  //
# ////////////////////////

#this routine is to attribute single files!
function jpg_examination {
    X_TMP_PATH=$(realpath "./.tmp-examination")

    printLine0 "--examine" "Entered image examination mode."

    #is original given
    if [ -z $2 ]; then
        X_ORIGINAL=0
    else
        if [[ $2 == "-"* ]]; then
            X_ORIGINAL=0
        else
            X_ORIGINAL=1
        fi
    fi

    #check if stego file exists
    X_PATH_STEGO_ORIGIN=$(realpath $1)
    formatPath $X_PATH_STEGO_ORIGIN
    if [ ! -f $X_PATH_STEGO_ORIGIN ]; then
        printErrorAndExit "Could not find $RETURN_FPATH. Please specify a '*.jpg'-file!"
    fi
    if [[ $X_PATH_STEGO_ORIGIN != *".jpg" ]]; then
        printErrorAndExit "$RETURN_FPATH is not a '*.jpg'-file!"
    fi

    #check original file if given
    if [ $X_ORIGINAL -eq 1 ]; then
        X_PATH_ORIGINAL_ORIGIN=$(realpath $2)
        formatPath $X_PATH_ORIGINAL_ORIGIN
        if [ ! -f $X_PATH_ORIGINAL_ORIGIN ]; then
            printErrorAndExit "Could not find $RETURN_FPATH. Please specify a '*.jpg'-file!"
        fi
        if [[ $X_PATH_ORIGINAL_ORIGIN != *".jpg" ]]; then
            printErrorAndExit "$RETURN_FPATH is not a '*.jpg'-file!"
        fi
    fi

    #prepare working directory
    if [ -d $X_TMP_PATH ]; then
        rm -dr $X_TMP_PATH
    fi
    mkdir $X_TMP_PATH

    #copy stego file to examine
    cp $X_PATH_STEGO_ORIGIN $X_TMP_PATH/stego.jpg
    X_PATH_STEGO=$X_TMP_PATH/stego.jpg

    #copy original file if given
    if [ $X_ORIGINAL -eq 1 ]; then
        cp $X_PATH_ORIGINAL_ORIGIN $X_TMP_PATH/original.jpg
        X_PATH_ORIGINAL=$X_TMP_PATH/original.jpg
    fi

    printLine1 "screening"

    #stego screening
    formatPath $X_PATH_STEGO_ORIGIN
    printLine2 "stego-jpg" "Going to examine $RETURN_FPATH."

    #check image size
    RESO_CHECK=$(exiftool $X_PATH_STEGO | grep "Image Size" | cut -d ":" -f2 | xargs)
    RESO_CHECK_W=$(echo $RESO_CHECK | cut -d "x" -f1)
    RESO_CHECK_H=$(echo $RESO_CHECK | cut -d "x" -f2)

    fixedToolCheck
    if [ $RTN_FIXEDTOOLCHECK -eq 1 ]; then
        exit 2
    fi

    X_OUT_STEGO=$X_TMP_PATH/stego
    mkdir $X_OUT_STEGO

    printLine3 "exec" "exiftool $X_PATH_STEGO"
    exiftool $X_PATH_STEGO &> $X_OUT_STEGO/exiftool.out

    printLine3 "exec" "binwalk $X_PATH_STEGO"
    binwalk $X_PATH_STEGO &> $X_OUT_STEGO/binwalk.out

    printLine3 "exec" "strings $X_PATH_STEGO"
    strings $X_PATH_STEGO &> $X_OUT_STEGO/strings.out

    printLine3 "exec" "foremost -o $X_OUT_STEGO/foremost -i $X_PATH_STEGO"
    foremost -o $X_OUT_STEGO/foremost -i $X_PATH_STEGO &> /dev/null
    
    if [ $((RESO_CHECK_W)) -gt 1024 ] || [ $((RESO_CHECK_H)) -gt 1024 ]; then
        printLine2 "stegoveritas" "skipped, $RESO_CHECK is larger than 1024x1024!"
    else
        VERITAS_STEGO=$X_OUT_STEGO/stegoveritas

        printLine3 "exec" "stegoveritas $X_PATH_STEGO -out $VERITAS_STEGO -meta -imageTransform -colorMap -trailing -steghide -xmp -carve"
        stegoveritas $X_PATH_STEGO -out $VERITAS_STEGO -meta -imageTransform -colorMap -trailing -steghide -xmp -carve &> /dev/null
    fi

    printLine3 "exec" "stegdetect -t jopfa $X_PATH_STEGO"
    stegdetect -t jopfa $X_PATH_STEGO &> $X_OUT_STEGO/stegdetect.out

    printLine3 "exec" "./stegbreak-fix -t j $X_PATH_STEGO"
    ./stegbreak-fix -t j $X_PATH_STEGO &> $X_OUT_STEGO/stegbreak-tj.out

    printLine3 "exec" "./stegbreak-fix -t j -f $PASSPHRASE_WORDLIST $X_OUT_STEGO"
    ./stegbreak-fix -t j -f $PASSPHRASE_WORDLIST $X_OUT_STEGO &> $X_TMP_PATH/stegbreak-tj-pass.out
    
    printLine3 "exec" "./stegbreak-fix -t o $X_PATH_STEGO"
    ./stegbreak-fix -t o $X_PATH_STEGO &> $X_OUT_STEGO/stegbreak-to.out

    printLine3 "exec" "./stegbreak-fix -t o -f $PASSPHRASE_WORDLIST $X_OUT_STEGO"
    ./stegbreak-fix -t o -f $PASSPHRASE_WORDLIST $X_OUT_STEGO &> $X_TMP_PATH/stegbreak-to-pass.out

    #original screening
    if [ $X_ORIGINAL -eq 1 ]; then
        formatPath $X_PATH_ORIGINAL_ORIGIN
        printLine2 "original-jpg" "Comparison with $RETURN_FPATH."

        #check image size
        RESO_CHECK=$(exiftool $X_PATH_ORIGINAL | grep "Image Size" | cut -d ":" -f2 | xargs)
        RESO_CHECK_W=$(echo $RESO_CHECK | cut -d "x" -f1)
        RESO_CHECK_H=$(echo $RESO_CHECK | cut -d "x" -f2)

        X_OUT_ORIGINAL=$X_TMP_PATH/original
        mkdir $X_OUT_ORIGINAL

        printLine3 "exec" "exiftool $X_PATH_ORIGINAL"
        exiftool $X_PATH_ORIGINAL &> $X_OUT_ORIGINAL/exiftool.out

        printLine3 "exec" "strings $X_PATH_ORIGINAL"
        strings $X_PATH_ORIGINAL &> $X_OUT_ORIGINAL/strings.out

        #create diff images
        printLine3 "exec" "compare $X_PATH_STEGO $X_PATH_ORIGINAL -compose src -highlight-color black $X_TMP_PATH/diff.jpg"
        compare $X_PATH_STEGO $X_PATH_ORIGINAL -compose src -highlight-color black $X_TMP_PATH/diff.jpg &> /dev/null

        if [ $((RESO_CHECK_W)) -gt 1024 ] || [ $((RESO_CHECK_H)) -gt 1024 ]; then
            printLine2 "stegoveritas" "skipped, $RESO_CHECK is larger than 1024x1024!"
        else
            VERITAS_STEGO=$X_OUT_ORIGINAL/stegoveritas

            printLine3 "exec" "stegoveritas $X_PATH_ORIGINAL -out $VERITAS_STEGO -meta -imageTransform -colorMap -trailing -steghide -xmp -carve"
            stegoveritas $X_PATH_ORIGINAL -out $VERITAS_STEGO -meta -imageTransform -colorMap -trailing -steghide -xmp -carve &> /dev/null

            printLine2 "imagemagick" "creating difference images..."

            #if both stegoveritas directories exist
            if [ -d $VERITAS_STEGO ] && [ -d $X_OUT_STEGO/stegoveritas ]; then
                VERITAS_COVER=$X_OUT_STEGO/stegoveritas
                VERITAS_DIFF_OUT=$X_TMP_PATH/diff
                mkdir $VERITAS_DIFF_OUT

                #loop all veritas files
                find "$VERITAS_STEGO" -maxdepth 1 -type f -name "*.png" | while read VERITAS_DIFF_IN; do
                    VERITAS_DIFF_COVER=$VERITAS_COVER/$(basename $X_OUT_STEGO).jpg_$(basename $VERITAS_DIFF_IN | cut -d "_" -f2-)
                    VERITAS_DIFF=$VERITAS_DIFF_OUT/$(basename $VERITAS_DIFF_IN | cut -d "_" -f2-)
                    
                    #create diff images
                    printLine3 "exec" "compare $VERITAS_DIFF_IN $VERITAS_DIFF_COVER -compose src -highlight-color black $VERITAS_DIFF"
                    compare $VERITAS_DIFF_IN $VERITAS_DIFF_COVER -compose src -highlight-color black $VERITAS_DIFF &> /dev/null
                done
            fi
        fi
    fi

    #parsing & counting
    printHeader
    printLine0 "--examine"

    shopt -s lastpipe #need this to count results correctly

    #counting variables
    X_SCORE_JPHIDE=0
    X_SCORE_JSTEG=0
    X_SCORE_OUTGUESS=0
    X_SCORE_OUTGUESS013=0
    X_SCORE_STEGHIDE=0
    X_SCORE_F5=0

    #implemented/maximum possible detects per tool
    X_SCORE_JPHIDE_MAX=1
    X_SCORE_JSTEG_MAX=6
    X_SCORE_OUTGUESS_MAX=3
    X_SCORE_OUTGUESS013_MAX=3
    X_SCORE_STEGHIDE_MAX=6
    X_SCORE_F5_MAX=1

    #exiftool
    X_P_JFIF=$(grep "JFIF Version" $X_OUT_STEGO/exiftool.out | cut -d ":" -f2 | xargs)
    
    #attribute (jsteg): exiftool jfif version is empty
    if [ "$X_P_JFIF" == "" ]; then
        X_SCORE_JSTEG=$((X_SCORE_JSTEG+1))
        printLine1 "sus" "exiftool: ${COL_2}jfif version is broken${COL_OFF} --> jsteg ${COL_NO}+1${COL_OFF}"
    fi

    #binwalk
    TMP_BINWALK=$(tail -n +4 $X_OUT_STEGO/binwalk.out | xargs | cut -d " " -f3-)
    X_P_BINW_FORMAT=$(echo "$TMP_BINWALK" | cut -d "," -f1 | xargs)
    X_P_BINW_JFIF=$(echo "$TMP_BINWALK" | cut -d "," -f2 | xargs)

    #attribute (jsteg): binwalk data type and jfif version is empty
    if [ "$X_P_BINW_FORMAT" == "" ] && [ "$X_P_BINW_JFIF" == "" ]; then
        X_SCORE_JSTEG=$((X_SCORE_JSTEG+1))
        printLine1 "sus" "binwalk: ${COL_2}data type and jfif version is broken${COL_OFF} --> jsteg ${COL_NO}+1${COL_OFF}"
    fi

    #strings
    TMP_STRINGS=$(sed 's/\t/ /g' $X_OUT_STEGO/strings.out | head -9 | tr "\n" " " | tr "," " " | tr ";" " " | xargs -0)
    
    #attribute (jsteg, outguess): header contains bunch of 2s
    if [[ $TMP_STRINGS == *"22222222222222222222222222222222222222222222222222"* ]]; then
        if [[ $TMP_STRINGS == "JFIF"* ]]; then
            #header starts with JFIF
            X_SCORE_OUTGUESS=$((X_SCORE_OUTGUESS+1))
            printLine1 "sus" "strings: ${COL_2}header contains bunch of '2's and starts with 'JFIF'${COL_OFF} --> outguess ${COL_NO}+1${COL_OFF}"
            X_SCORE_OUTGUESS013=$((X_SCORE_OUTGUESS013+1))
            printLine1 "sus" "strings: ${COL_2}header contains bunch of '2's and starts with 'JFIF'${COL_OFF} --> outguess-0.13 ${COL_NO}+1${COL_OFF}"
        else
            #header does not starts with JFIF
            X_SCORE_JSTEG=$((X_SCORE_JSTEG+1))
            printLine1 "sus" "strings: ${COL_2}header contains bunch of '2's and does not starts with 'JFIF'${COL_OFF} --> jsteg ${COL_NO}+1${COL_OFF}"
        fi
    fi

    #attribute (f5): header starts with JFIF written by fengji and contains (s
    if [[ $TMP_STRINGS == *"(((((((((((((((((((((((((((((((((((((((((((((((((("* ]] && [[ $TMP_STRINGS == "JFIF written by fengji"* ]]; then
        X_SCORE_F5=$((X_SCORE_F5+1))
        printLine1 "sus" "strings: ${COL_2}header contains bunch of '('s and starts with 'JFIF written by fengji'${COL_OFF} --> f5 ${COL_NO}+1${COL_OFF}"
    fi

    #foremost
    #attribute (jsteg): no data extraction
    if [ ! -d $X_OUT_STEGO/foremost/jpg ]; then
        X_SCORE_JSTEG=$((X_SCORE_JSTEG+1))
        printLine1 "sus" "foremost: ${COL_2}data extraction failed${COL_OFF} --> jsteg ${COL_NO}+1${COL_OFF}"
    fi

    #stegdetect
    TMP_STEGDETECT=($(cut -d ":" -f2 "$X_OUT_STEGO/stegdetect.out" | xargs))
    for tmp_DETECT in "${TMP_STEGDETECT[@]}"; do
        tmp_DETECT_NUM=$(tr -dc '*' <<<"$tmp_DETECT" | wc -c)
        case $tmp_DETECT in
            "jphide"*)
                X_SCORE_JPHIDE=$((X_SCORE_JPHIDE+tmp_DETECT_NUM))
                printLine1 "sus" "stegdetect: ${COL_2}detected $tmp_DETECT${COL_OFF} --> jphide ${COL_NO}+$tmp_DETECT_NUM${COL_OFF}"
                ;;
            "jsteg"*)
                X_SCORE_JSTEG=$((X_SCORE_JSTEG+tmp_DETECT_NUM))
                printLine1 "sus" "stegdetect: ${COL_2}detected $tmp_DETECT${COL_OFF} --> jsteg ${COL_NO}+$tmp_DETECT_NUM${COL_OFF}"
                ;;
            "outguess(old)"*)
                X_SCORE_OUTGUESS013=$((X_SCORE_OUTGUESS013+tmp_DETECT_NUM))
                printLine1 "sus" "stegdetect: ${COL_2}detected $tmp_DETECT${COL_OFF} --> outguess-0.13 ${COL_NO}+$tmp_DETECT_NUM${COL_OFF}"
                ;;
            *) ;;
        esac
    done

    #stegbreak
    if [ -f $X_OUT_STEGO/stegbreak-tj-pass.out ]; then
        X_P_STEGBREAK_TJ_PASS=$(cat $X_OUT_STEGO/stegbreak-tj-pass.out | tr "\n" " " | tr ";" " " | tr "," " " | xargs)
    fi
    if [ -f $X_OUT_STEGO/stegbreak-to-pass.out ]; then
        X_P_STEGBREAK_TO_PASS=$(cat $X_OUT_STEGO/stegbreak-to-pass.out | tr "\n" " " | tr ";" " " | tr "," " " | xargs)
    fi
    if [ -f $X_OUT_STEGO/stegbreak-tj.out ]; then
        X_P_STEGBREAK_TJ=$(cat $X_OUT_STEGO/stegbreak-tj.out | tr "\n" " " | tr ";" " " | tr "," " " | xargs)
    fi
    if [ -f $X_OUT_STEGO/stegbreak-to.out ]; then
        X_P_STEGBREAK_TO=$(cat $X_OUT_STEGO/stegbreak-to.out | tr "\n" " " | tr ";" " " | tr "," " " | xargs)
    fi

    #attribute (jsteg): stegbreak 'Premature end of JPEG file'
    if [[ $X_P_STEGBREAK_TJ_PASS == "Premature end of JPEG file"* ]] || [[ $X_P_STEGBREAK_TO_PASS == "Premature end of JPEG file"* ]] || [[ $X_P_STEGBREAK_TJ == "Premature end of JPEG file"* ]] || [[ $X_P_STEGBREAK_TO == "Premature end of JPEG file"* ]]; then
        X_SCORE_JSTEG=$((X_SCORE_JSTEG+1))
        printLine1 "sus" "stegbreak: ${COL_2}terminated with 'Premature end of JPEG file'${COL_OFF} --> jsteg ${COL_NO}+1${COL_OFF}"
    fi
    X_P_STEGBREAK_TJ_PASS=$(echo $X_P_STEGBREAK_TJ_PASS | cut -d ":" -f2 | xargs)
    X_P_STEGBREAK_TO_PASS=$(echo $X_P_STEGBREAK_TO_PASS | cut -d ":" -f2 | xargs)
    X_P_STEGBREAK_TJ=$(echo $X_P_STEGBREAK_TJ | cut -d ":" -f2 | xargs)
    X_P_STEGBREAK_TO=$(echo $X_P_STEGBREAK_TO | cut -d ":" -f2 | xargs)
    
    #attribute (jsteg): stegbreak 'jsteg' detect
    if [[ $X_P_STEGBREAK_TJ_PASS == "jsteg"* ]] || [[ $X_P_STEGBREAK_TO_PASS == "jsteg"* ]] || [[ $X_P_STEGBREAK_TJ == "jsteg"* ]] || [[ $X_P_STEGBREAK_TO == "jsteg"* ]]; then
        X_SCORE_JSTEG=$((X_SCORE_JSTEG+1))
        printLine1 "sus" "stegbreak: ${COL_2}detected jsteg${COL_OFF} --> jsteg ${COL_NO}+1${COL_OFF}"
    fi

    #attribute (outguess): stegbreak 'outguess' detect
    if [[ $X_P_STEGBREAK_TJ_PASS == "outguess[v0.13b]"* ]] || [[ $X_P_STEGBREAK_TO_PASS == "outguess[v0.13b]"* ]] || [[ $X_P_STEGBREAK_TJ == "outguess[v0.13b]"* ]] || [[ $X_P_STEGBREAK_TO == "outguess[v0.13b]"* ]]; then
        X_SCORE_OUTGUESS013=$((X_SCORE_OUTGUESS013+1))
        printLine1 "sus" "stegbreak: ${COL_2}detected outguess-0.13${COL_OFF} --> outguess-0.13 ${COL_NO}+1${COL_OFF}"
    else
        if [[ $X_P_STEGBREAK_TJ_PASS == "outguess"* ]] || [[ $X_P_STEGBREAK_TO_PASS == "outguess"* ]] || [[ $X_P_STEGBREAK_TJ == "outguess"* ]] || [[ $X_P_STEGBREAK_TO == "outguess"* ]]; then
            X_SCORE_OUTGUESS=$((X_SCORE_OUTGUESS+1))
            printLine1 "sus" "stegbreak: ${COL_2}detected outguess${COL_OFF} --> outguess ${COL_NO}+1${COL_OFF}"
        fi
    fi

    #compare with original
    if [ $X_ORIGINAL -eq 1 ]; then
        #exiftool
        tmp_EXIFTOOL_FILESIZE_STEGO=$(grep "File Size" $X_OUT_STEGO/exiftool.out | cut -d ":" -f 2 | xargs)
        tmp_EXIFTOOL_FILESIZE_STEGO_NUM=$(echo $tmp_EXIFTOOL_FILESIZE_STEGO | cut -d " " -f1)
        tmp_EXIFTOOL_FILESIZE_ORIGINAL=$(grep "File Size" $X_OUT_ORIGINAL/exiftool.out | cut -d ":" -f 2 | xargs)
        tmp_EXIFTOOL_FILESIZE_ORIGINAL_NUM=$(echo $tmp_EXIFTOOL_FILESIZE_ORIGINAL | cut -d " " -f1)
        #convert MB to kB
        if [[ $tmp_EXIFTOOL_FILESIZE_ORIGINAL == *"MB" ]]; then
            tmp_EXIFTOOL_FILESIZE_ORIGINAL_NUM=$(echo "$tmp_EXIFTOOL_FILESIZE_ORIGINAL_NUM 1024" | awk '{print $1 * $2}' | cut -d "." -f1)
        fi
        if [[ $tmp_EXIFTOOL_FILESIZE_STEGO == *"MB" ]]; then
            tmp_EXIFTOOL_FILESIZE_STEGO_NUM=$(echo "$tmp_EXIFTOOL_FILESIZE_STEGO_NUM 1024" | awk '{print $1 * $2}' | cut -d "." -f1)
        fi

        #attribute (steghide): file size if nearly the same, all other tools will half/third the size
        tmp_EXIFTOOL_FILESIZE_ORIGINAL_NUM_HALF=$(echo "$tmp_EXIFTOOL_FILESIZE_ORIGINAL_NUM 2" | awk '{print $1 / $2}' | cut -d "." -f1)
        if [ $tmp_EXIFTOOL_FILESIZE_STEGO_NUM -gt $tmp_EXIFTOOL_FILESIZE_ORIGINAL_NUM_HALF ]; then
            X_SCORE_STEGHIDE=$((X_SCORE_STEGHIDE+1))
            printLine1 "sus" "exiftool: ${COL_2}Stego size $tmp_EXIFTOOL_FILESIZE_STEGO_NUM kB is greater than half the original size $tmp_EXIFTOOL_FILESIZE_ORIGINAL_NUM_HALF kB${COL_OFF} --> steghide ${COL_NO}+1${COL_OFF}"
        fi

        #difference image
        TMP_BASIC_DIFF_MEAN=$(identify -verbose $X_TMP_PATH/diff.jpg | grep -m1 "mean:" | cut -d ":" -f2 | xargs | cut -d " " -f1 | cut -d "." -f1)
        if [ $TMP_BASIC_DIFF_MEAN -gt 75 ]; then
            X_SCORE_STEGHIDE=$((X_SCORE_STEGHIDE+1))
            printLine1 "sus" "imagemagick: ${COL_2}difference image mean is $TMP_BASIC_DIFF_MEAN, which is greater than 75${COL_OFF} --> steghide ${COL_NO}+1${COL_OFF}"
        fi

        #if diff images available --> stegoveritas
        if [ -d $X_TMP_PATH/diff ]; then
            find $X_TMP_PATH/diff -maxdepth 1 -type f -name "*.png" | while read DIFF_IMG; do
                DIFF_IMG_MEAN=$(identify -verbose $DIFF_IMG | grep -m1 "mean:" | cut -d ":" -f2 | xargs | cut -d " " -f1 | cut -d "." -f1)
                case $DIFF_IMG in
                    *"red_plane.png"|*"green_plane.png"|*"blue_plane.png")
                        #attribute (steghide): value is greater than 110, other tools are about 10-15
                        if [ $DIFF_IMG_MEAN -gt 110 ]; then
                            X_SCORE_STEGHIDE=$((X_SCORE_STEGHIDE+1))
                            printLine1 "sus" "stegoveritas: ${COL_2}mean value for '$(basename $DIFF_IMG)' is $DIFF_IMG_MEAN, which is greater than 110 ${COL_OFF} --> steghide ${COL_NO}+1${COL_OFF}"
                        fi
                        ;;
                    *"Median.png")
                        #attribute (steghide): value is greater than 40, other tools are about 1
                        if [ $DIFF_IMG_MEAN -gt 40 ]; then
                            X_SCORE_STEGHIDE=$((X_SCORE_STEGHIDE+1))
                            printLine1 "sus" "stegoveritas: ${COL_2}mean value for '$(basename $DIFF_IMG)' is $DIFF_IMG_MEAN, which is greater than 40 ${COL_OFF} --> steghide ${COL_NO}+1${COL_OFF}"
                        fi
                        ;;
                    *) ;;
                esac
            done
        fi
    fi

    #remove analysis data
    rm -dr $X_TMP_PATH

    #print Result
    X_TOTAL=$((X_SCORE_JPHIDE+X_SCORE_JSTEG+X_SCORE_OUTGUESS+X_SCORE_OUTGUESS013+X_SCORE_STEGHIDE+X_SCORE_F5))

    printLine0 "examination result"
    if [ $X_TOTAL -eq 0 ]; then
        #detect count is zero
        echo -e "  ${COL_YES}Image does not seem to have anything embedded${COL_OFF}!"
    else
        if [ $X_TOTAL -gt 3 ]; then
            #most likely
            echo -e "  ${COL_NO}Image most likely has something embedded${COL_OFF} (${COL_2}$X_TOTAL${COL_OFF} detects)!"
        else
            #possible
            echo -e "  ${COL_NO}Image could have something embedded${COL_OFF} (${COL_2}$X_TOTAL${COL_OFF} detects)!"
        fi
        
        #calculate percentage
        X_PERC_JPHIDE=$(echo "$X_SCORE_JPHIDE $X_SCORE_JPHIDE_MAX" | awk '{print $1 / $2}')
        X_PERC_JSTEG=$(echo "$X_SCORE_JSTEG $X_SCORE_JSTEG_MAX" | awk '{print $1 / $2}')
        X_PERC_OUTGUESS=$(echo "$X_SCORE_OUTGUESS $X_SCORE_OUTGUESS_MAX" | awk '{print $1 / $2}')
        X_PERC_OUTGUESS013=$(echo "$X_SCORE_OUTGUESS013 $X_SCORE_OUTGUESS013_MAX" | awk '{print $1 / $2}')
        X_PERC_STEGHIDE=$(echo "$X_SCORE_STEGHIDE $X_SCORE_STEGHIDE_MAX" | awk '{print $1 / $2}')
        X_PERC_F5=$(echo "$X_SCORE_F5 $X_SCORE_F5_MAX" | awk '{print $1 / $2}')

        X_PERC_JPHIDE=$(echo "$X_PERC_JPHIDE 100" | awk '{print $1 * $2}')%
        X_PERC_JSTEG=$(echo "$X_PERC_JSTEG 100" | awk '{print $1 * $2}')%
        X_PERC_OUTGUESS=$(echo "$X_PERC_OUTGUESS 100" | awk '{print $1 * $2}')%
        X_PERC_OUTGUESS013=$(echo "$X_PERC_OUTGUESS013 100" | awk '{print $1 * $2}')%
        X_PERC_STEGHIDE=$(echo "$X_PERC_STEGHIDE 100" | awk '{print $1 * $2}')%
        X_PERC_F5=$(echo "$X_PERC_F5 100" | awk '{print $1 * $2}')%

        #print results
        if [ $X_SCORE_JPHIDE -eq 0 ]; then
            printLine1 "jphide" "  ${COL_YES}$X_SCORE_JPHIDE${COL_OFF} detects (${COL_3}$X_PERC_JPHIDE${COL_OFF})"
        else
            printLine1 "jphide" "  ${COL_NO}$X_SCORE_JPHIDE${COL_OFF} detects (${COL_2}$X_PERC_JPHIDE${COL_OFF})"
        fi
        if [ $X_SCORE_JSTEG -eq 0 ]; then
            printLine1 "jsteg" "   ${COL_YES}$X_SCORE_JSTEG${COL_OFF} detects (${COL_3}$X_PERC_JSTEG${COL_OFF})"
        else
            printLine1 "jsteg" "   ${COL_NO}$X_SCORE_JSTEG${COL_OFF} detects (${COL_2}$X_PERC_JSTEG${COL_OFF})"
        fi
        if [ $X_SCORE_OUTGUESS -eq 0 ]; then
            printLine1 "outguess" "${COL_YES}$X_SCORE_OUTGUESS${COL_OFF} detects (${COL_3}$X_PERC_OUTGUESS${COL_OFF})"
        else
            printLine1 "outguess" "${COL_NO}$X_SCORE_OUTGUESS${COL_OFF} detects (${COL_2}$X_PERC_OUTGUESS${COL_OFF})"
        fi
        if [ $X_SCORE_OUTGUESS -eq 0 ]; then
            printLine1 "outguess-0.13" "${COL_YES}$X_SCORE_OUTGUESS013${COL_OFF} detects (${COL_3}$X_PERC_OUTGUESS013${COL_OFF})"
        else
            printLine1 "outguess-0.13" "${COL_NO}$X_SCORE_OUTGUESS013${COL_OFF} detects (${COL_2}$X_PERC_OUTGUESS013${COL_OFF})"
        fi
        if [ $X_SCORE_STEGHIDE -eq 0 ]; then
            printLine1 "steghide" "${COL_YES}$X_SCORE_STEGHIDE${COL_OFF} detects (${COL_3}$X_PERC_STEGHIDE${COL_OFF})"
        else
            printLine1 "steghide" "${COL_NO}$X_SCORE_STEGHIDE${COL_OFF} detects (${COL_2}$X_PERC_STEGHIDE${COL_OFF})"
        fi
        if [ $X_SCORE_F5 -eq 0 ]; then
            printLine1 "f5" "      ${COL_YES}$X_SCORE_F5${COL_OFF} detects (${COL_3}$X_PERC_F5${COL_OFF})"
        else
            printLine1 "f5" "      ${COL_NO}$X_SCORE_F5${COL_OFF} detects (${COL_2}$X_PERC_F5${COL_OFF})"
        fi
    fi

    exit 0
}

#print Header
printHeader

#   /////////////////////////
#  //  QUALITY ASSURANCE  //
# /////////////////////////

#write passphrases
echo "" > $PASSPHRASE_WORDLIST
echo $PASSPHRASE_SHORT >> $PASSPHRASE_WORDLIST
echo $PASSPHRASE_LONG >> $PASSPHRASE_WORDLIST

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
PARAM_OFFSET=0
PARAM_RANDOMIZE=0
PARAM_CLEAN=0
PARAM_DELETE=0
PARAM_SKIP_F5=0
PARAM_SKIP_STEGOVERITAS=0
PARAM_SKIP_EMBEDDING=0
PARAM_SKIP_ANALYSIS=0
PARAM_VERBOSE=0
PARAM_EXAMINE=0
EXAMINE_ARGS=""

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
        --offset|-m)
            #check if number is given
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires an integer!"
            fi
            PARAM_OFFSET=$next_param ;;
        --randomize|-r)
            PARAM_RANDOMIZE=1 ;;
        --clean|-c)
            PARAM_CLEAN=1 ;;
        --delete|-d)
            PARAM_DELETE=1 ;;
        --skip-f5)
            PARAM_SKIP_F5=1 ;;
        --skip-stegoveritas)
            PARAM_SKIP_STEGOVERITAS=1 ;;
        --skip-embedding)
            PARAM_SKIP_EMBEDDING=1 ;;
        --skip-analysis)
            PARAM_SKIP_ANALYSIS=1 ;;
        --verbose|-v)
            PARAM_VERBOSE=1 ;;
        --examine|-x)
            #check if path is given
            k=$((j+1))
            next_next_param=${!k}
            if [ -z $next_param ]; then
                printErrorAndExit "Parameter '$param' requires a path to a jpg file!"
            fi
            PARAM_EXAMINE=1
            EXAMINE_ARGS="$next_param $next_next_param" ;;
        *) ;;
    esac

    i=$j
done

if [ $PARAM_EXAMINE -eq 1 ]; then
    jpg_examination $EXAMINE_ARGS
    exit 0
fi

#get absolute paths
PARAM_INPUT=$(realpath $PARAM_INPUT)
PARAM_OUTPUT=$(realpath $PARAM_OUTPUT)

#final output file location
EVALUATION_OUTPUT_FILE=$PARAM_OUTPUT/out.csv

#check if size is an integer
if ! [[ $PARAM_SIZE =~ $RE_NUMERIC ]] || [ $PARAM_SIZE -le 0 ]; then
    printErrorAndExit "'$PARAM_SIZE' is not a numeric expression or too small!"
fi

#check, if imagemagick is installed
if ! command -v compare &> /dev/null; then
    printLine0 "apt" "ImageMagick/compare not found. Installing now..."
    apt update
    apt install imagemagick imagemagick-doc -y
fi

#check if fixed modules available
fixedToolCheck
if [ $RTN_FIXEDTOOLCHECK -eq 1 ]; then
    #exit on error
    exit 2
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

#verbose
if [ $PARAM_VERBOSE -eq 1 ]; then
    printLine0 "--verbose" "advanced log output enabled!"
fi

#skips
if [ $PARAM_SKIP_F5 -eq 1 ]; then
    printLine0 "--skip-f5" "f5 will be skipped!"
fi
if [ $PARAM_SKIP_STEGOVERITAS -eq 1 ]; then
    printLine0 "--skip-stegoveritas" "stegoveritas will be skipped!"
fi
if [ $PARAM_SKIP_EMBEDDING -eq 1 ]; then
    printLine0 "--skip-embedding" "embedding phase will be skipped!"
fi
if [ $PARAM_SKIP_ANALYSIS -eq 1 ]; then
    printLine0 "--skip-analysis" "analysis will be skipped!"
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
if [ $((PARAM_SIZE+PARAM_OFFSET)) -gt $JPGS_FOUND_COVER ]; then
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
printLine0 "main/start" "Going to embed, analyse and evaluate ${COL_2}$PARAM_SIZE${COL_OFF} of a total of ${COL_2}$JPGS_FOUND_COVER${COL_OFF} available $RETURN_FPATH-covers, skipping first ${COL_2}$PARAM_OFFSET${COL_OFF} matches."

#capture timestamp
formatCurrentTimestamp
printLine0 "main" "Started at $RETURN_TIMESTAMP, running on host '${COL_2}$(hostname --short)${COL_OFF}'."
TIMESTAMP_MAIN_START=$(date +%s)

#retrieve example embedding data if not available
if [ ! -f $EMBEDDING_SHORT ]; then
    formatPath $EMBEDDING_SHORT
    printLine1 "download" "Downloading example data $RETURN_FPATH to embed..."
    wget -N "$LINK_EMBEDDING_SHORT" -O "$EMBEDDING_SHORT"
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

#   ////////////////////////
#  //  COVER INSPECTION  //
# ////////////////////////

#Loop cover directory
C=0
find $PARAM_INPUT -maxdepth 1 -type f -name "*.jpg" | sort $SORTING_PARAM | head -n -$PARAM_OFFSET | tail -$PARAM_SIZE | while read COVER; do
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
        
    #temporary meta file
    META_EMBEDDING=$JPEG_OUTDIR/embeddings.csv

    #capture timestamp
    TIMESTAMP_EBD_START=$(date +%s)
    printLine1 "embedding/start" "Embedding data to samples..."

    #   //////////////////
    #  //  EMBEDDINGS  //
    # //////////////////

    if [ $PARAM_SKIP_EMBEDDING -eq 0 ]; then
        #make sure output directory exists
        if [ -d "$JPEG_OUTDIR" ]; then
            rm -dr $JPEG_OUTDIR
        fi
        mkdir $JPEG_OUTDIR

        #cover for embeddings
        JPEG_COVER=$JPEG_OUTDIR/original.jpg

        #copy original cover to testset
        cp $COVER $JPEG_COVER
        COVER_SHA1=$(sha1sum $JPEG_COVER | cut -d " " -f1)

        formatPath $JPEG_COVER
        printLine1 "copy" "Original cover copied to $RETURN_FPATH."

        echo "cover;cover sha1;stego;stego sha1;stego tool;stego embed;stego key;embed hash;embed hash out" > $META_EMBEDDING
        echo "$COVER;$COVER_SHA1;$JPEG_COVER;$COVER_SHA1;-;-;-;-;-" >> $META_EMBEDDING

        #check image size
        RESO_CHECK=$(exiftool $JPEG_COVER | grep "Image Size" | cut -d ":" -f2 | xargs)
        RESO_CHECK_W=$(echo $RESO_CHECK | cut -d "x" -f1)
        RESO_CHECK_H=$(echo $RESO_CHECK | cut -d "x" -f2)

        #JPHIDE: not implemented, its broken!
        #jphide/jpseek does not support no keys!
        #KEY_ARR=(shortKey longKey)
        #EMBEDDING_DATA=($EMBEDDING_SHORT $EMBEDDING_MIDDLE $EMBEDDING_LONG $EMBEDDING_LOWENTROPY $EMBEDDING_BINARY)
        #STEGO_TOOL=jphide
        #if [ $PARAM_SKIP_JPHIDE -eq 0 ]; then
        #    printLine2 $STEGO_TOOL
        #    mkdir $JPEG_OUTDIR/$STEGO_TOOL
        #    for KEY_TYPE in "${KEY_ARR[@]}"; do
        #        for EMBEDDING_FILE in "${EMBEDDING_DATA[@]}"; do
        #            getEmbeddingTypeText $(basename $EMBEDDING_FILE})
        #            getEmbeddingTypeHash $(basename $EMBEDDING_FILE)
        #            JPEG_STEGO_NO_EXT=$JPEG_OUTDIR/$STEGO_TOOL/$RETURN_EBDTEXT-$KEY_TYPE
        #            JPEG_STEGO=$JPEG_STEGO_NO_EXT.jpg

        #            getKeyByType $KEY_TYPE
        #            #embedding
        #            printLine3 "exec" "./jphide-auto $JPEG_COVER $JPEG_STEGO $EMBEDDING_FILE $RETURN_KEY"
        #            ./jphide-auto $JPEG_COVER $JPEG_STEGO $EMBEDDING_FILE $RETURN_KEY &> /dev/null

        #            #extracting
        #            printLine3 "exec" "./jpseek-auto $JPEG_STEGO $JPEG_STEGO_NO_EXT.out $RETURN_KEY"
        #            ./jpseek-auto $JPEG_STEGO $JPEG_STEGO_NO_EXT.out $RETURN_KEY &> /dev/null

        #            #stegbreak
        #            printLine3 "exec" "./stegbreak-fix -t p -f $PASSPHRASE_WORDLIST $JPEG_STEGO"
        #            ./stegbreak-fix -t p -f $PASSPHRASE_WORDLIST $JPEG_STEGO &> $JPEG_STEGO.stegbreak

        #            #writing
        #            JPEG_STEGO_SHA1=$(sha1sum $JPEG_STEGO | cut -d " " -f1)
        #            OUT_SHA1=$(sha1sum $JPEG_STEGO_NO_EXT.out | cut -d " " -f1)
        #            echo "$COVER;$COVER_SHA1;$JPEG_STEGO;$JPEG_STEGO_SHA1;$STEGO_TOOL;$RETURN_EBDTEXT;$KEY_TYPE;$RETURN_EBDHASH;$OUT_SHA1" >> $META_EMBEDDING
        #        done
        #    done
        #else
        #    printLine2 $STEGO_TOOL "skipped due to --skip-jphide switch!"
        #fi
        
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
        
        STEGO_TOOL=f5
        if [ $PARAM_SKIP_F5 -eq 0 ]; then
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
            printLine2 $STEGO_TOOL "skipped due to --skip-f5 switch!"
        fi
    else
        printLine1 "embedding" "skipped due to --skip-embedding switch!"
    fi

    #print timestamp and diff time
    TIMESTAMP_EBD_END=$(date +%s)
    TIMESTAMP_EBD_DIFF=$((TIMESTAMP_EBD_END-TIMESTAMP_EBD_START))
    TIMESTAMP_EBD_DIFF_M=$((TIMESTAMP_EBD_DIFF/60))
    TIMESTAMP_EBD_DIFF_S=$((TIMESTAMP_EBD_DIFF%60))
    printLine1 "embedding/done" "Embedded data to samples, took $TIMESTAMP_EBD_DIFF_M mins and $TIMESTAMP_EBD_DIFF_S secs."

    #capture timestamp
    TIMESTAMP_STEG_START=$(date +%s)
    META_ANALYSIS=$PARAM_OUTPUT/$COVER_BASENAME_NO_EXT.csv

    #count stego samples
    JPGS_FOUND_STEGO=$(find $JPEG_OUTDIR -maxdepth 2 -type f -name "*.jpg" | wc -l)

    if [ $JPGS_FOUND_STEGO -eq 0 ]; then
        printErrorAndExit "No stego files found!"
    fi

    printLine1 "analysis/start" "Analysing ${COL_2}$JPGS_FOUND_STEGO${COL_OFF} samples..."
    DETECT_COUNT_TOTAL=0

    #   ////////////////////
    #  //  STEGANALYSIS  //
    # ////////////////////

    if [ $PARAM_SKIP_ANALYSIS -eq 0 ]; then
        #diff images of stegoveritas to analyse
        VERITAS_TARGETS=(red_plane green_plane blue_plane Edge-enhance Edge-enhance_More Find_Edges GaussianBlur inverted Max Median Min Mode Sharpen Smooth)

        #construct csv header
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

        #trivial screening tools
        SCREENING_TOOLS=("file" "exiftool" "binwalk" "strings")

        #loop csv
        D=0
        while IFS=";" read -r csv_COVER csv_COVER_SHA1 csv_STEGO csv_STEGO_SHA1 csv_STEGO_TOOL csv_STEGO_EMBED csv_STEGO_KEY csv_EMBED_HASH csv_EMBED_HASH_OUT; do
            D=$((D+1))
            formatPath $csv_STEGO
            FORMATTED_SAMPLE=$RETURN_FPATH
            OUT_BASEPATH=$(dirname $csv_STEGO)/$(basename $csv_STEGO)

            #reset csv fields for next sample
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
                #sample is empty -> no analysis required
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

                #imagemagick
                printLine3 "exec" "compare $csv_STEGO $COVER -highlight-color black -compose src $(dirname $csv_STEGO)/$(basename $csv_STEGO .jpg).diff.jpg"
                compare $csv_STEGO $COVER -compose src -highlight-color black $(dirname $csv_STEGO)/$(basename $csv_STEGO .jpg).diff.jpg &> /dev/null
                printLine3 "exec" "identify -verbose $csv_STEGO"
                identify -verbose $csv_STEGO &> $OUT_BASEPATH.identify

                #stegoveritas
                if [ $PARAM_SKIP_STEGOVERITAS -eq 0 ]; then
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
                    printLine2 "stegoveritas" "skipped due to --skip-stegoveritas switch!"
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
                    #data extracted successfully
                    csv_EMBEDDED_DATA_CHECKSUMS="ok"
                else
                    if [ $csv_EMBED_HASH_OUT == $EMPTY_SHA1 ]; then
                        #data extraction failed because data is empty -> 100% lost
                        csv_EMBEDDED_DATA_CHECKSUMS="empty"
                    else
                        #data extraction failed ecause data is corrupted
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
                
                #parsing attributes with grep, cut and xargs
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

            #construct csv line
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

            #write to csv
            echo "$csv_OUT" >> $META_ANALYSIS
        done < <(tail -n +2 $META_EMBEDDING)
    else
        printLine1 "analysis" "skipped due to --skip-analysis switch!"
    fi
    
    #print timestamp and diff time (analysis)
    TIMESTAMP_STEG_END=$(date +%s)
    TIMESTAMP_STEG_DIFF=$((TIMESTAMP_STEG_END-TIMESTAMP_STEG_START))
    TIMESTAMP_STEG_DIFF_M=$((TIMESTAMP_STEG_DIFF/60))
    TIMESTAMP_STEG_DIFF_S=$((TIMESTAMP_STEG_DIFF%60))
    printLine1 "analysis/done" "Screening done, took $TIMESTAMP_STEG_DIFF_M mins and $TIMESTAMP_STEG_DIFF_S secs."

    #   //////////////////
    #  //  EVALUATION  //
    # //////////////////

    printLine1 "evaluation/start" "Evaluating..."

    META_EVALUATION=$PARAM_OUTPUT/evaluation-$(hostname --short).csv

    #JPHIDE: not implemented, its broken!
    eval_TOOLS=(jsteg outguess outguess-0.13 steghide f5)

    #inter-tool comparison
    declare -A evalmap_SAMPLES
    declare -A evalmap_WORKING_SAMPLES
    declare -A evalmap_NOT_WORKING_SAMPLES
    declare -A evalmap_STEGDETECT_COUNT
    declare -A evalmap_STEGDETECT
    declare -A evalmap_STEGBREAK_COUNT
    declare -A evalmap_STEGBREAK
    declare -A evalmap_VERITAS_DIFF_MEAN
    declare -A evalmap_FILE_DATATYPE
    declare -A evalmap_EXIFTOOL_FILESIZE
    declare -A evalmap_EXIFTOOL_CAMERA
    declare -A evalmap_BINWALK_DATATYPE
    declare -A evalmap_BINWALK_JFIF
    declare -A evalmap_STRINGS
    declare -A evalmap_FOREMOST
    declare -A evalmap_IMAGICK_DIFF

    #init maps for each tool
    for eval_TOOL in "${eval_TOOLS[@]}"; do
        evalmap_SAMPLES[$eval_TOOL]=0
        evalmap_WORKING_SAMPLES[$eval_TOOL]=0
        evalmap_NOT_WORKING_SAMPLES[$eval_TOOL]=""
        evalmap_STEGDETECT_COUNT[$eval_TOOL]=0
        evalmap_STEGDETECT[$eval_TOOL]=""
        evalmap_STEGBREAK_COUNT[$eval_TOOL]=0
        evalmap_STEGBREAK[$eval_TOOL]=""
        evalmap_VERITAS_DIFF_MEAN[$eval_TOOL]=0
        evalmap_FILE_DATATYPE[$eval_TOOL]="original"
        evalmap_EXIFTOOL_FILESIZE[$eval_TOOL]=0
        evalmap_EXIFTOOL_CAMERA[$eval_TOOL]="original"
        evalmap_FILE_DATATYPE[$eval_TOOL]="original"
        evalmap_BINWALK_DATATYPE[$eval_TOOL]="original"
        evalmap_BINWALK_JFIF[$eval_TOOL]="original"
        evalmap_STRINGS[$eval_TOOL]=""
        evalmap_FOREMOST[$eval_TOOL]=""
        evalmap_IMAGICK_DIFF[$eval_TOOL]=0
    done

    #loop analysis csv for cover
    Z=0
    while read evalcsv_LINE; do
        echo -n -e "    > $Z/$JPGS_FOUND_STEGO\r"
        IFS=';' read -r -a evalcsv_LINE_ARR <<< "$evalcsv_LINE"
        if [ $Z -eq 1 ]; then
            orig_COVER_FILE=${evalcsv_LINE_ARR[0]}
            orig_FILE_DATATYPE=${evalcsv_LINE_ARR[27]}
            orig_EXIFTOOL_FILESIZE=${evalcsv_LINE_ARR[28]}
            orig_EXIFTOOL_CAMERA=${evalcsv_LINE_ARR[29]}
            orig_BINWALK_DATATYPE=${evalcsv_LINE_ARR[36]}
            orig_BINWALK_JFIF=${evalcsv_LINE_ARR[37]}
            orig_STRINGS=${evalcsv_LINE_ARR[38]}
            orig_FOREMOST_LENGTH=${evalcsv_LINE_ARR[39]}
            orig_IMAGICK_DIFF=$(echo ${evalcsv_LINE_ARR[41]} | cut -d " " -f1 | xargs)
        fi

        eval_TOOL=${evalcsv_LINE_ARR[4]}
        eval_SAMPLEID=${evalcsv_LINE_ARR[5]}${evalcsv_LINE_ARR[6]}

        #count stego images created for each tool
        evalmap_SAMPLES[$eval_TOOL]=$((evalmap_SAMPLES[$eval_TOOL]+1))

        #if embedding successful
        if [ "${evalcsv_LINE_ARR[10]}" == "ok" ]; then
            #count successful embeds for each tool
            evalmap_WORKING_SAMPLES[$eval_TOOL]=$((evalmap_WORKING_SAMPLES[$eval_TOOL]+1))

            #count stegdetect detects
            if [ "${evalcsv_LINE_ARR[11]}" != "negative" ] && [ "${evalcsv_LINE_ARR[11]}" != "-" ]; then
                evalmap_STEGDETECT_COUNT[$eval_TOOL]=$((evalmap_STEGDETECT_COUNT[$eval_TOOL]+1))
                evalmap_STEGDETECT[$eval_TOOL]="${evalmap_STEGDETECT[$eval_TOOL]} [$eval_SAMPLEID as ${evalcsv_LINE_ARR[11]}]"
            fi

            #count stegbreak "detects"
            tmp_STEGBREAK=$(echo ${evalcsv_LINE_ARR[12]} | cut -d ":" -f2 | xargs | cut -d " " -f1)
            if [ "$tmp_STEGBREAK" != "negative" ] && [ "$tmp_STEGBREAK" != "-" ] && [ "$tmp_STEGBREAK" != "Loaded" ] && [ "$tmp_STEGBREAK" != "" ]; then
                evalmap_STEGBREAK_COUNT[$eval_TOOL]=$((evalmap_STEGBREAK_COUNT[$eval_TOOL]+1))
                evalmap_STEGBREAK[$eval_TOOL]="${evalmap_STEGBREAK[$eval_TOOL]} [$eval_SAMPLEID as $tmp_STEGBREAK]"
            fi
            
            #stegoveritas: diff mean
            if [ "${evalcsv_LINE_ARR[22]}" != "-" ]; then
                tmp_VERITAS_DIFF_MEAN=$(echo ${evalcsv_LINE_ARR[22]} | cut -d " " -f1 | xargs)
                evalmap_VERITAS_DIFF_MEAN[$eval_TOOL]=$(echo "${evalmap_VERITAS_DIFF_MEAN[$eval_TOOL]} $tmp_VERITAS_DIFF_MEAN" | awk '{print $1 + $2}')
            fi

            #file
            if [ "$orig_FILE_DATATYPE" != "${evalcsv_LINE_ARR[27]}" ]; then
                evalmap_FILE_DATATYPE[$eval_TOOL]="altered"
            fi

            #exiftool
            tmp_EXIFTOOL_FILESIZE=$(echo ${evalcsv_LINE_ARR[28]} | cut -d " " -f1 | xargs)
            evalmap_EXIFTOOL_FILESIZE[$eval_TOOL]=$(echo "${evalmap_EXIFTOOL_FILESIZE[$eval_TOOL]} $tmp_EXIFTOOL_FILESIZE" | awk '{print $1 + $2}')
            if [ "$orig_EXIFTOOL_CAMERA" != "${evalcsv_LINE_ARR[29]}" ]; then
                evalmap_EXIFTOOL_CAMERA[$eval_TOOL]="altered"
            fi

            #binwalk
            if [ "$orig_BINWALK_DATATYPE" != "${evalcsv_LINE_ARR[36]}" ]; then
                evalmap_BINWALK_DATATYPE[$eval_TOOL]="altered"
            fi
            if [ "$orig_BINWALK_JFIF" != "${evalcsv_LINE_ARR[37]}" ]; then
                evalmap_BINWALK_JFIF[$eval_TOOL]="altered"
            fi

            #strings
            tmp_STRINGS=$(diff <(echo "$orig_STRINGS" ) <(echo "${evalcsv_LINE_ARR[38]}") | tr "\n" " " | tr ";" " " | tr "," " " | xargs -0)
            evalmap_STRINGS[$eval_TOOL]="${evalmap_STRINGS[$eval_TOOL]} $tmp_STRINGS"

            #foremost
            if [ "${evalcsv_LINE_ARR[3]}" != "${evalcsv_LINE_ARR[40]}" ]; then
                evalmap_FOREMOST[$eval_TOOL]="${evalmap_FOREMOST[$eval_TOOL]} [${evalcsv_LINE_ARR[39]}/$orig_FOREMOST_LENGTH]"
            fi
            
            #imagemagick
            if [ "${evalcsv_LINE_ARR[41]}" != "-" ]; then
                tmp_IMAGICK_DIFF=$(echo ${evalcsv_LINE_ARR[41]} | cut -d " " -f1 | xargs)
                evalmap_IMAGICK_DIFF[$eval_TOOL]=$(echo "${evalmap_IMAGICK_DIFF[$eval_TOOL]} $tmp_IMAGICK_DIFF" | awk '{print $1 + $2}')
            fi
        else
            evalmap_NOT_WORKING_SAMPLES[$eval_TOOL]="${evalmap_NOT_WORKING_SAMPLES[$eval_TOOL]}[$eval_SAMPLEID] "
        fi

        Z=$((Z+1))
    done < $META_ANALYSIS

    echo -n -e "\r"

    #evaluation csv header
    csv_HEADER="analysed image;embedding duration;analysis duration;total duration"
    evalcsv_TOOLS=""
    for eval_TOOL in "${eval_TOOLS[@]}"; do
        if [ ${evalmap_WORKING_SAMPLES[$eval_TOOL]} -eq 0 ]; then
            eval_VERITAS_DIFF_MEAN_AVG="-"
            eval_EXIFTOOL_FILESIZE_AVG="-"
            eval_IMAGICK_DIFF_AVG="-"
        else
            eval_VERITAS_DIFF_MEAN_AVG=$(echo "${evalmap_VERITAS_DIFF_MEAN[$eval_TOOL]} ${evalmap_WORKING_SAMPLES[$eval_TOOL]}" | awk '{print $1 / $2}')
            eval_EXIFTOOL_FILESIZE_AVG=$(echo "${evalmap_EXIFTOOL_FILESIZE[$eval_TOOL]} ${evalmap_WORKING_SAMPLES[$eval_TOOL]}" | awk '{print $1 / $2}')
            eval_IMAGICK_DIFF_AVG=$(echo "${evalmap_IMAGICK_DIFF[$eval_TOOL]} ${evalmap_WORKING_SAMPLES[$eval_TOOL]}" | awk '{print $1 / $2}')
        fi
        if [ ${evalmap_SAMPLES[$eval_TOOL]} -eq 0 ]; then
            csv_HEADER="$csv_HEADER;$eval_TOOL/working samples"
            evalcsv_TOOLS="$evalcsv_TOOLS;${evalmap_SAMPLES[$eval_TOOL]}"
        else
            csv_HEADER="$csv_HEADER;$eval_TOOL/working stego;$eval_TOOL/failed stego;$eval_TOOL/stegdetect;$eval_TOOL/stegbreak;$eval_TOOL/stegoveritas (difference);$eval_TOOL/file (data type);$eval_TOOL/exiftool (file size);$eval_TOOL/exiftool (camera);$eval_TOOL/binwalk (data type);$eval_TOOL/binwalk (jfif format);$eval_TOOL/strings;$eval_TOOL/foremost;$eval_TOOL/imagemagick (diff mean)"
            evalcsv_TOOLS="$evalcsv_TOOLS;${evalmap_WORKING_SAMPLES[$eval_TOOL]}/${evalmap_SAMPLES[$eval_TOOL]};${evalmap_NOT_WORKING_SAMPLES[$eval_TOOL]};${evalmap_STEGDETECT_COUNT[$eval_TOOL]}${evalmap_STEGDETECT[$eval_TOOL]};${evalmap_STEGBREAK_COUNT[$eval_TOOL]}${evalmap_STEGBREAK[$eval_TOOL]};$eval_VERITAS_DIFF_MEAN_AVG;${evalmap_FILE_DATATYPE[$eval_TOOL]};$eval_EXIFTOOL_FILESIZE_AVG/$orig_EXIFTOOL_FILESIZE;${evalmap_EXIFTOOL_CAMERA[$eval_TOOL]};${evalmap_BINWALK_DATATYPE[$eval_TOOL]};${evalmap_BINWALK_JFIF[$eval_TOOL]};${evalmap_STRINGS[$eval_TOOL]};${evalmap_FOREMOST[$eval_TOOL]};$eval_IMAGICK_DIFF_AVG/$orig_IMAGICK_DIFF"
        fi
    done

    #print timestamp and diff time (cover)
    formatCurrentTimestamp
    TIMESTAMP_COVER_END=$(date +%s)
    TIMESTAMP_COVER_DIFF=$((TIMESTAMP_COVER_END-TIMESTAMP_COVER_START))
    TIMESTAMP_COVER_DIFF_M=$((TIMESTAMP_COVER_DIFF/60))
    TIMESTAMP_COVER_DIFF_S=$((TIMESTAMP_COVER_DIFF%60))

    #runtimes
    evalcsv_TIME_EBD="$TIMESTAMP_EBD_DIFF_M mins $TIMESTAMP_EBD_DIFF_S secs"
    evalcsv_TIME_STEG="$TIMESTAMP_STEG_DIFF_M mins $TIMESTAMP_STEG_DIFF_S secs"
    evalcsv_TIME_COVER="$TIMESTAMP_COVER_DIFF_M mins $TIMESTAMP_COVER_DIFF_S secs"

    #write header if file does not exist
    if [ ! -f $META_EVALUATION ]; then
        echo "$csv_HEADER" > $META_EVALUATION
    fi

    #append line
    echo "$orig_COVER_FILE;$evalcsv_TIME_EBD;$evalcsv_TIME_STEG;$evalcsv_TIME_COVER$evalcsv_TOOLS" >> $META_EVALUATION

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

#done, finally
exit 0