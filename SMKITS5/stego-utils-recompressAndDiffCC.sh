#!/bin/bash

#paths
SET_IN=./coverData
SET_OUT=./out-stego-recompress


SET_IN=$(realpath $SET_IN)
SET_OUT=$(realpath $SET_OUT)

#prepare
if [ -d $SET_OUT ]; then
    rm -dr $SET_OUT
fi

#start process
COUNT=$(find $SET_IN -maxdepth 1 -type f -name "*.jpg" | wc -l)

#step 1: recompress
find $SET_IN -maxdepth 1 -type f -name "*.jpg" | sort -d | while read JPG_FILE_IN; do
    BASENAME=$(basename $JPG_FILE_IN .jpg)
    JPG_FILE_OUT=$(realpath $SET_OUT)/$BASENAME
    echo $JPG_FILE_OUT
done

#step 2: stegoveritas

#step 3: diff images