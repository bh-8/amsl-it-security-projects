#!/bin/bash
##################################################
# Script: stego-utils-buildTestset.sh
# Syntax: ./stego-utils-buildTestset.sh [outDir=./coverData]
# Ausfuehrungsumgebung: physischer Projektordner
# Beschreibung: kopiert das Coverbild-Testset aus verschiedenen Datenquellen zusammen
##################################################
# Konstanten:

# Groesse des zu erstellenden Testsets
maxsize=1024

# Bilder mit verschiedenen Aufloesungen und von verschiedenen Kameras (priorisierte Bilder)
loc_private=./private

# Pfad zur BOWS2-Datenbank
loc_bows2=./bows2
# Anzahl d. aus BOWS2 genutzten Daten
blackwhite=192

# Pfad zur kaggle/alaska2-Datenbank
loc_alaska=./kaggle-alaska2

##################################################

#check arguments
if [ $# -eq 0 ]; then
	outdir=./coverData
else
	outdir=${1}
fi

#set output directory name
outdir=$(realpath $outdir)

if [ -d $outdir ]; then
	echo "Error: '$outdir' does already exist!"
	exit 1
fi

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

#create output directory
mkdir $outdir

#loop and copy all private files
find $loc_private -maxdepth 1 -type f -name *.jpg | while read COVER; do
	cp $COVER $outdir/$(basename $COVER)
	echo "copied $(basename $COVER)"
done

#loop and copy n random bows2-images
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

echo "Done!"

exit 0