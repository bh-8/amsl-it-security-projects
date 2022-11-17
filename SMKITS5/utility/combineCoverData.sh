#!/bin/bash

outdir=./coverData
maxsize=1024
blackwhite=192

loc_private=./private
loc_bows2=./bows2
loc_alaska=./kaggle-alaska2

if [ ! -d $loc_private ]; then
	echo "Error: '$loc_private' not found!"
	exit 2
fi
if [ ! -d $loc_bows2 ]; then
	echo "Error: '$loc_bows2' not found!"
	exit 2
fi
if [ ! -d $loc_alaska ]; then
	echo "Error: '$loc_alaska' not found!"
	exit 2
fi

if [ -d $outdir ]; then
	rm -dr $outdir
fi
mkdir $outdir

find $loc_private -maxdepth 1 -type f -name *.jpg | while read COVER; do
	cp $COVER $outdir/$(basename $COVER)
	echo "copied $(basename $COVER)"
done

find $loc_bows2 -maxdepth 1 -type f -name *.jpg | sort -R | tail -$blackwhite | while read COVER; do
	cp $COVER $outdir/$(basename $COVER)
	echo "copied $(basename $COVER)"
done

jpgsdone=$(find $outdir -maxdepth 1 -type f -name *.jpg | wc -l)
alaska=$((maxsize-jpgsdone))

find $loc_alaska -maxdepth 1 -type f -name *.jpg | sort -R | tail -$alaska | while read COVER; do
	cp $COVER $outdir/$(basename $COVER)
	echo "copied $(basename $COVER)"
done

exit
