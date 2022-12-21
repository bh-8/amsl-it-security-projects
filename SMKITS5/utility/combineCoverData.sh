#!/bin/bash

#set output directory name
outdir=./coverData

#set final testset size
maxsize=1024

#set amount of bows2-images
blackwhite=192

#use all images from there
loc_private=./private
#use fixed amount of images from there
loc_bows2=./bows2
#use images from there to fill up to given testset size
loc_alaska=./kaggle-alaska2

#check if data sources are available
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

#overwrite output directory
if [ -d $outdir ]; then
	rm -dr $outdir
fi
mkdir $outdir

#loop and copy all private files
find $loc_private -maxdepth 1 -type f -name *.jpg | while read COVER; do
	cp $COVER $outdir/$(basename $COVER)
	echo "copied $(basename $COVER)"
done

#loop and copy random bows2-images
find $loc_bows2 -maxdepth 1 -type f -name *.jpg | sort -R | tail -$blackwhite | while read COVER; do
	cp $COVER $outdir/$(basename $COVER)
	echo "copied $(basename $COVER)"
done

#count images currently in testset
jpgsdone=$(find $outdir -maxdepth 1 -type f -name *.jpg | wc -l)

#calculate missing sample count
alaska=$((maxsize-jpgsdone))

#fill up testset to maximum size with alaska images
find $loc_alaska -maxdepth 1 -type f -name *.jpg | sort -R | tail -$alaska | while read COVER; do
	cp $COVER $outdir/$(basename $COVER)
	echo "copied $(basename $COVER)"
done

exit 0