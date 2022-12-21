#!/bin/bash

#specify input directory (containing csv files!)
INPUT_DIR=./out-stego-attrib
if [ $# -ne 0 ]; then
    INPUT_DIR=${1}
fi

INPUT_DIR=$(realpath $INPUT_DIR)

#check if directory exists
if [ ! -d $INPUT_DIR ]; then
    echo "'$INPUT_DIR' could not be found!"
    exit 2
fi

#loop all csvs
find $INPUT_DIR -maxdepth 1 -type f -name "_*.csv" | while read PATH_CSV_IN; directory
    echo $PATH_CSV_IN
done

exit 0