#!/bin/bash
##################################################
# Script: stego-utils-testAttrib.sh
# Syntax: ./stego-utils-testAttrib.sh [inDir=./coverData]
# Ausführungsumgebung: virtueller Docker-Container
# Beschreibung: Testet die automatische Attributierung dieser Projektarbeit
##################################################
# Konstanten:

# Zwischenspeicher
WORKING_DIR=$(realpath ./.tmp-test-attrib)

# Sample Count
SAMPLE_COUNT=1

# Output
CSV_OUT=$(realpath ./generated-attrib-test.csv)

##################################################

if [ $# -eq 0 ]; then
    SET_IN=./coverData
else
    SET_IN=${1}
fi

if [ ! -d $SET_IN ]; then
    echo "Error: '$SET_IN' not found!"
    exit 1
fi

if [ -d $WORKING_DIR ]; then
    rm -dr $WORKING_DIR
fi
mkdir $WORKING_DIR
echo "file;tool;data;key;jphide;jsteg;outguess;outguess-0.13;steghide;f5" > $CSV_OUT
for i in {1..$SAMPLE_COUNT}; do
    echo "creating embeds: './stego-attrib.sh -i $SET_IN -o $WORKING_DIR -n 1 -r -c --skip-analysis'..."
    ./stego-attrib.sh -i $SET_IN -o $WORKING_DIR -n 1 -r -c --skip-analysis &> /dev/null

    SAMPLE_DIR=$(find $WORKING_DIR -mindepth 1 -maxdepth 1 -type d | head -1)
    SAMPLE_NAME=$(basename $SAMPLE_DIR)
    ORIGINAL=$WORKING_DIR/$SAMPLE_NAME.original.jpg

    echo "setting up..."
    mv $SAMPLE_DIR/original.jpg $ORIGINAL
    find $SAMPLE_DIR -mindepth 2 -maxdepth 2 -type f -name "*.jpg" | sort -d | while read SAMPLE; do
        mv $SAMPLE $WORKING_DIR/$SAMPLE_NAME.$(basename $(dirname $SAMPLE) | tr "." "_").$(basename $SAMPLE)
    done

    find $WORKING_DIR -type f -empty -delete

    echo "attributing..."
    find $WORKING_DIR -mindepth 1 -maxdepth 1 -type f -name "*.jpg" | sort -d | while read SAMPLE; do
        OUTF="$WORKING_DIR/$(basename $SAMPLE .jpg).attr"
        echo "'./stego-attrib.sh -x $SAMPLE $ORIGINAL'"

        FILE=$(basename $SAMPLE | cut -d "." -f1)
        TOOL=$(basename $SAMPLE | cut -d "." -f2)
        DATA=$(basename $SAMPLE | cut -d "." -f3 | cut -d "-" -f1)
        KEY=$(basename $SAMPLE | cut -d "." -f3 | cut -d "-" -f2)

        #https://stackoverflow.com/questions/17998978/removing-colors-from-output
        ./stego-attrib.sh -x $SAMPLE $ORIGINAL | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' &> $OUTF

        ATTR_JPHIDE=$(cat $OUTF | tail -6 | head -1 | xargs | cut -d " " -f4)
        ATTR_JSTEG=$(cat $OUTF | tail -5 | head -1 | xargs | cut -d " " -f4)
        ATTR_OG=$(cat $OUTF | tail -4 | head -1 | xargs | cut -d " " -f4)
        ATTR_OGO=$(cat $OUTF | tail -3 | head -1 | xargs | cut -d " " -f4)
        ATTR_SHIDE=$(cat $OUTF | tail -2 | head -1 | xargs | cut -d " " -f4)
        ATTR_FF=$(cat $OUTF | tail -1 | head -1 | xargs | cut -d " " -f4)

        echo "$FILE;$TOOL;$DATA;$KEY;$ATTR_JPHIDE;$ATTR_JSTEG;$ATTR_OG;$ATTR_OGO;$ATTR_SHIDE;$ATTR_FF" >> $CSV_OUT
    done
done

clear
cat $WORKING_DIR/out.csv

rm -dr $WORKING_DIR

exit 0