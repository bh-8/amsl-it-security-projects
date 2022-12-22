#!/bin/bash

#paths
SET_IN=./coverData
SET_OUT=./.tmp-recompress

CSV_OUT=./generated-recompressedRgb.csv

if [ $# -ne 0 ]; then
    SET_IN=${1}
fi

SET_IN=$(realpath $SET_IN)
SET_OUT=$(realpath $SET_OUT)

#prepare
if [ -d $SET_OUT ]; then
    rm -dr $SET_OUT
fi

#check if stegoveritas is installed
if ! command -v stegoveritas &> /dev/null; then
    echo "Could not find stegoveritas!"
    exit 2
fi

#check if imagemagick is installed
if ! command -v compare &> /dev/null; then
    apt update
    apt install imagemagick imagemagick-doc -y
fi


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
    PERCENTAGE=$(printf "%.3f\n" "$OUT_MUL")

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

#start process
JPG_COUNT=$(find $SET_IN -maxdepth 1 -type f -name "*.jpg" | wc -l)

#step 1: recompress
echo "recompressing files..."

C=0
find $SET_IN -maxdepth 1 -type f -name "*.jpg" | sort -d | while read JPG_FILE_IN; do
    BASENAME=$(basename $JPG_FILE_IN .jpg)
    JPG_OUT=$SET_OUT/$BASENAME

    mkdir -p $JPG_OUT

    printProgress $JPG_COUNT $C 0
    cp $JPG_FILE_IN $JPG_OUT/img.jpg

    printProgress $JPG_COUNT $C 1
    convert -strip -interlace Plane -quality 75 $JPG_OUT/img.jpg $JPG_OUT/recom.jpg &>/dev/null

    C=$((C+1))
done

printProgress $JPG_COUNT $JPG_COUNT

#step 2: stegoveritas
echo -e "\nsplitting color channels..."

C=0
find $SET_OUT -mindepth 1 -maxdepth 1 -type d | sort -d | while read JPG_DIR; do
    JPG_ORIG=$JPG_DIR/img.jpg
    JPG_RECOM=$JPG_DIR/recom.jpg

    printProgress $JPG_COUNT $C 0
    stegoveritas $JPG_ORIG -out $JPG_DIR/img -meta -imageTransform -colorMap -trailing -xmp -carve &> /dev/null

    printProgress $JPG_COUNT $C 1
    stegoveritas $JPG_RECOM -out $JPG_DIR/recom -meta -imageTransform -colorMap -trailing -xmp -carve &> /dev/null

    C=$((C+1))
done

printProgress $JPG_COUNT $JPG_COUNT

#step 3: diff images
echo -e "\ncreating difference images..."

echo "file;red;green;blue">$CSV_OUT

C=0
find $SET_OUT -mindepth 1 -maxdepth 1 -type d | sort -d | while read JPG_DIR; do
    JPG_BN_ORIG=$JPG_DIR/img/img
    JPG_BN_RECOM=$JPG_DIR/recom/recom

    printProgress $JPG_COUNT $C 0
    compare $JPG_BN_RECOM.jpg_red_plane.png $JPG_BN_ORIG.jpg_red_plane.png -compose src -highlight-color black $JPG_DIR/diff_red.png
    RED=$(identify -verbose $JPG_DIR/diff_red.png | grep -m1 "mean:" | cut -d ":" -f2 | xargs | cut -d " " -f2 | cut -d "(" -f2 | cut -d ")" -f1)

    printProgress $JPG_COUNT $C 1
    compare $JPG_BN_RECOM.jpg_green_plane.png $JPG_BN_ORIG.jpg_green_plane.png -compose src -highlight-color black $JPG_DIR/diff_green.png
    GREEN=$(identify -verbose $JPG_DIR/diff_green.png | grep -m1 "mean:" | cut -d ":" -f2 | xargs | cut -d " " -f2 | cut -d "(" -f2 | cut -d ")" -f1)

    printProgress $JPG_COUNT $C 2
    compare $JPG_BN_RECOM.jpg_blue_plane.png $JPG_BN_ORIG.jpg_blue_plane.png -compose src -highlight-color black $JPG_DIR/diff_blue.png
    BLUE=$(identify -verbose $JPG_DIR/diff_blue.png | grep -m1 "mean:" | cut -d ":" -f2 | xargs | cut -d " " -f2 | cut -d "(" -f2 | cut -d ")" -f1)

    echo "$(basename $JPG_DIR.jpg);$RED;$GREEN;$BLUE">>$CSV_OUT

    C=$((C+1))
done

printProgress $JPG_COUNT $JPG_COUNT
echo -e "\nDone!"

#cleanup
rm -dr $SET_OUT

echo "Output: '$(realpath $CSV_OUT)'"

exit 0