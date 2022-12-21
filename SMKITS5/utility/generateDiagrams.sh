#!/bin/bash

#tmp directory
WORKING_DIR=$(realpath ./.tmp-diagrams)

#print n characters
function printN {
    s=$(printf "%${2}s")
    echo -n "${s// /${1}}"
}

#arithmetic floating point operations
function add {
    OUT_ADD=$(echo $1 $2 | awk "{print $1 + $2}")
}
function sub {
    OUT_SUB=$(echo $1 $2 | awk "{print $1 - $2}")
}
function mul {
    OUT_MUL=$(echo $1 $2 | awk "{print $1 * $2}")
}
function div {
    OUT_DIV=$(echo $1 $2 | awk "{print $1 / $2}")
}

#progress bar
function printProgress {
    BAR_WIDTH=50

    CSV_TOTAL=${1}
    CSV_CURRENT=${2}
    ix=${3}

    div $CSV_CURRENT $CSV_TOTAL
    mul $OUT_DIV $BAR_WIDTH
    
    VAL_DONE=$(echo $OUT_MUL | cut -d "." -f1)

    mul $OUT_DIV 100
    PERCENTAGE=$(printf "%8.2f\n" "$OUT_MUL")

    sub $BAR_WIDTH $VAL_DONE
    VAL_DIFF=$OUT_SUB

    CSV_CURRENT=$(printf "%04d" $CSV_CURRENT)
    CSV_TOTAL=$(printf "%04d" $CSV_TOTAL)
    ix=$(printf "%02d" $ix)

    echo -ne "\r$CSV_CURRENT/$CSV_TOTAL: $ix ["
    printN "#" $VAL_DONE
    printN "." $VAL_DIFF
    echo -ne "] $PERCENTAGE%"
}

#store values on file system
function addToStore {
    TMPDIR=$1
    IDENTIFIER=$2
    TOOL=$3
    DATA=$4
    KEY=$5
    VALUE=$6

    mkdir -p $TMPDIR/$TOOL/$DATA/$KEY

    localFile=$TMPDIR/$TOOL/$DATA/$KEY/$IDENTIFIER.txt

    if [ -f $localFile ]; then
        #if value already exists, add values
        existingValue=$(cat $localFile)
        add $existingValue $VALUE
        
        echo $OUT_ADD>$localFile
    else
        #if value does not exist, write value
        echo $VALUE>$localFile
    fi
}

#specify input directory (containing csv files!)
INPUT_DIR=./documentation/auswertung/csv
if [ $# -ne 0 ]; then
    INPUT_DIR=${1}
fi

INPUT_DIR=$(realpath $INPUT_DIR)

#check if directory exists
if [ ! -d $INPUT_DIR ]; then
    echo "'$INPUT_DIR' could not be found!"
    exit 2
fi

echo "summing up csv data..."

CSV_COUNT=$(find $INPUT_DIR -maxdepth 1 -type f -name "_*.csv" | wc -l)
C=0

#loop all csvs
find $INPUT_DIR -maxdepth 1 -type f -name "_*.csv" | sort -d | while read PATH_CSV_IN; do
    D=0
    #loop csv lines
    while read CSV_LINE; do
        IFS=';' read -r -a CSV_LINE_ARRAY <<< "$CSV_LINE"

        #tool
        VAL_TOOL=${CSV_LINE_ARRAY[4]}

        #data
        VAL_DATA=${CSV_LINE_ARRAY[5]}

        #key
        VAL_KEY=${CSV_LINE_ARRAY[6]}

        #diff field
        VAL_DIFF_BW=$(echo "${CSV_LINE_ARRAY[41]}" | cut -d " " -f2)
        if [[ $VAL_DIFF_BW == "("*")" ]]; then
            #sum up values
            if [[ $VAL_TOOL != "-" ]]; then
                VAL_DIFF_BW=$(echo $VAL_DIFF_BW | cut -d "(" -f2 | cut -d ")" -f1)

                addToStore $WORKING_DIR "diff_bw_v" $VAL_TOOL $VAL_DATA $VAL_KEY $VAL_DIFF_BW
                addToStore $WORKING_DIR "diff_bw_c" $VAL_TOOL $VAL_DATA $VAL_KEY 1
            fi
        fi
        
        #entropy
        VAL_ENTROPY=${CSV_LINE_ARRAY[49]}
        if [[ $VAL_ENTROPY != "-" ]] && [[ $VAL_ENTROPY != "" ]]; then
            #sum up values
            if [[ $VAL_TOOL == "-" ]]; then
                addToStore $WORKING_DIR "diff_entropy_v" "original" "original" "noKey" $VAL_ENTROPY
                addToStore $WORKING_DIR "diff_entropy_c" "original" "original" "noKey" 1
            else
                addToStore $WORKING_DIR "diff_entropy_v" $VAL_TOOL $VAL_DATA $VAL_KEY $VAL_ENTROPY
                addToStore $WORKING_DIR "diff_entropy_c" $VAL_TOOL $VAL_DATA $VAL_KEY 1
            fi
        fi
        
        #file size
        VAL_FILESIZE=$(echo "${CSV_LINE_ARRAY[39]}" | cut -d " " -f3 | cut -d "(" -f2)
        if [[ $VAL_FILESIZE != "-" ]]; then
            #sum up values
            if [[ $VAL_TOOL == "-" ]]; then
                addToStore $WORKING_DIR "filesize_v" "original" "original" "noKey" $VAL_FILESIZE
                addToStore $WORKING_DIR "filesize_c" "original" "original" "noKey" 1
            else
                addToStore $WORKING_DIR "filesize_v" $VAL_TOOL $VAL_DATA $VAL_KEY $VAL_FILESIZE
                addToStore $WORKING_DIR "filesize_c" $VAL_TOOL $VAL_DATA $VAL_KEY 1
            fi
        fi

        #rgb embeds
        VAL_DIFF_R=$(echo "${CSV_LINE_ARRAY[13]}" | cut -d " " -f2)
        VAL_DIFF_G=$(echo "${CSV_LINE_ARRAY[14]}" | cut -d " " -f2)
        VAL_DIFF_B=$(echo "${CSV_LINE_ARRAY[15]}" | cut -d " " -f2)

        if [[ $VAL_DIFF_R == "("*")" ]] && [[ $VAL_DIFF_G == "("*")" ]] && [[ $VAL_DIFF_B == "("*")" ]]; then
            if [[ $VAL_TOOL != "-" ]]; then
                VAL_DIFF_R=$(echo $VAL_DIFF_R | cut -d "(" -f2 | cut -d ")" -f1)
                VAL_DIFF_G=$(echo $VAL_DIFF_G | cut -d "(" -f2 | cut -d ")" -f1)
                VAL_DIFF_B=$(echo $VAL_DIFF_B | cut -d "(" -f2 | cut -d ")" -f1)
                
                #sum up values
                addToStore $WORKING_DIR-cc "diff_v" $VAL_TOOL $VAL_DATA "r" $VAL_DIFF_R
                addToStore $WORKING_DIR-cc "diff_c" $VAL_TOOL $VAL_DATA "r" 1
                addToStore $WORKING_DIR-cc "diff_v" $VAL_TOOL $VAL_DATA "g" $VAL_DIFF_G
                addToStore $WORKING_DIR-cc "diff_c" $VAL_TOOL $VAL_DATA "g" 1
                addToStore $WORKING_DIR-cc "diff_v" $VAL_TOOL $VAL_DATA "b" $VAL_DIFF_B
                addToStore $WORKING_DIR-cc "diff_c" $VAL_TOOL $VAL_DATA "b" 1
            fi
        fi

        printProgress $CSV_COUNT $C $D

        D=$((D+1))
    done < <(tail -n +2 $PATH_CSV_IN)

    C=$((C+1))
done

printProgress $CSV_COUNT $CSV_COUNT
echo -e "\ngenerating csv..."

shopt -s lastpipe

CSV_DIFF_BW="Tool;Data;noKey;shortKey;longKey\n"
CSV_ENTROPY="Tool;Data;noKey;shortKey;longKey\n"
CSV_FILESIZE="Tool;Data;noKey;shortKey;longKey\n"

#loop extracted data
find $WORKING_DIR -mindepth 1 -maxdepth 1 -type d | sort -d | while read PATH_TOOL; do
    TOOL=$(basename $PATH_TOOL)
    find $PATH_TOOL -mindepth 1 -maxdepth 1 -type d | sort -d | while read PATH_DATA; do
        DATA=$(basename $PATH_DATA)

        CSV_DIFF_BW="$CSV_DIFF_BW$TOOL;$DATA"
        CSV_ENTROPY="$CSV_ENTROPY$TOOL;$DATA"
        CSV_FILESIZE="$CSV_FILESIZE$TOOL;$DATA"

        if [ $TOOL == "steghide" ]; then
            CSV_DIFF_BW="$CSV_DIFF_BW;"
            CSV_ENTROPY="$CSV_ENTROPY;"
            CSV_FILESIZE="$CSV_FILESIZE;"
        fi

        find $PATH_DATA -mindepth 1 -maxdepth 1 -type d | sort -d | while read PATH_KEY; do
            KEY=$(basename $PATH_KEY)

            if [ -f "$PATH_KEY/diff_bw_v.txt" ] && [ -f "$PATH_KEY/diff_bw_c.txt" ]; then
                VALUE=$(cat "$PATH_KEY/diff_bw_v.txt")
                COUNT=$(cat "$PATH_KEY/diff_bw_c.txt")

                #calculate arithmetic mean
                div $VALUE $COUNT

                CSV_DIFF_BW="$CSV_DIFF_BW;$OUT_DIV"
            fi

            if [ -f "$PATH_KEY/diff_entropy_v.txt" ] && [ -f "$PATH_KEY/diff_entropy_c.txt" ]; then
                VALUE=$(cat "$PATH_KEY/diff_entropy_v.txt")
                COUNT=$(cat "$PATH_KEY/diff_entropy_c.txt")

                #calculate arithmetic mean
                div $VALUE $COUNT

                CSV_ENTROPY="$CSV_ENTROPY;$OUT_DIV"
            fi

            if [ -f "$PATH_KEY/filesize_v.txt" ] && [ -f "$PATH_KEY/filesize_c.txt" ]; then
                VALUE=$(cat "$PATH_KEY/filesize_v.txt")
                COUNT=$(cat "$PATH_KEY/filesize_c.txt")

                #calculate arithmetic mean
                div $VALUE $COUNT

                CSV_FILESIZE="$CSV_FILESIZE;$OUT_DIV"
            fi
        done

        if [ $TOOL == "jsteg" ]; then
            CSV_DIFF_BW="$CSV_DIFF_BW;;"
            CSV_ENTROPY="$CSV_ENTROPY;;"
            CSV_FILESIZE="$CSV_FILESIZE;;"
        fi

        CSV_DIFF_BW="$CSV_DIFF_BW\n"
        CSV_ENTROPY="$CSV_ENTROPY\n"
        CSV_FILESIZE="$CSV_FILESIZE\n"
    done
done

#build rgb channel csv
CSV_RGB="Tool;Data;b;g;r\n"

find $WORKING_DIR-cc -mindepth 1 -maxdepth 1 -type d | sort -d | while read PATH_TOOL; do
    TOOL=$(basename $PATH_TOOL)
    find $PATH_TOOL -mindepth 1 -maxdepth 1 -type d | sort -d | while read PATH_DATA; do
        DATA=$(basename $PATH_DATA)

        CSV_RGB="$CSV_RGB$TOOL;$DATA"

        find $PATH_DATA -mindepth 1 -maxdepth 1 -type d | sort -d | while read PATH_COL; do
            COLOR=$(basename $PATH_COL)

            if [ -f "$PATH_COL/diff_v.txt" ] && [ -f "$PATH_COL/diff_c.txt" ]; then
                VALUE=$(cat "$PATH_COL/diff_v.txt")
                COUNT=$(cat "$PATH_COL/diff_c.txt")

                #calculate arithmetic mean
                div $VALUE $COUNT

                CSV_RGB="$CSV_RGB;$OUT_DIV"
            fi
        done

        CSV_RGB="$CSV_RGB\n"
    done
done

#cleanup
rm -dr $WORKING_DIR
rm -dr $WORKING_DIR-cc

#write csv
echo -e "$CSV_DIFF_BW">./generated-diff_bw.csv
echo -e "$CSV_ENTROPY">./generated-entropy.csv
echo -e "$CSV_FILESIZE">./generated-filesize.csv
echo -e "$CSV_RGB">./generated-diff_cc.csv

echo "Done!"

exit 0