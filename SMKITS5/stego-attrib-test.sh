#!/bin/bash

_STEGO_TESTSET_LOCATION="./.tmp-stego-testset"
_TESTPROTOCOL_PATH="./stego-attrib-test-protocol.txt"
_SET="./coverData"
_SUBSET_MASK="*_alaska2-*.jpg"
_COVERS=3
_EMBEDS_PER_COVER=57 #maximum is 57
_INCLUDE_ORIGINAL=1
_INCLUDE_RECOMPRESSED=1
_RECOMPRESSION_QUALITY_FACTOR=80

# verwendete Einbettungsschlüssel
PASSPHRASE_SHORT="TEST"
PASSPHRASE_LONG="THIS_IS_A_PRETTY_LONG_PASSPHRASE_TRUST_ME_ITS_HUGE"

# Orte der Einbettungsdaten
EMBEDDING_SHORT=$(realpath ./embeddingShort.txt)
EMBEDDING_MIDDLE=$(realpath ./embeddingMiddle.txt)
EMBEDDING_LONG=$(realpath ./embeddingLong.txt)
EMBEDDING_LOWENTROPY=$(realpath ./embeddingLowEntropy.txt)
EMBEDDING_BINARY=$(realpath ./embeddingBinary)

##################################################

if [ ! -f "$_TESTPROTOCOL_PATH" ]; then
	echo "Error: Could not find testprotocol file at '$SET'!"
	exit 1
fi

. ./common.sh &> /dev/null

if [ ! -d "$_SET" ]; then
	echo "Error: Could not find '$SET'!"
	exit 2
fi
_SET=$(realpath $_SET)

#count available cover files
TOTAL_FILES=$(find $_SET -mindepth 1 -maxdepth 1 -type f -name $_SUBSET_MASK | wc -l)

if [ $TOTAL_FILES -eq 0 ]; then
	echo "Error: No files matching '$_SUBSET_MASK' found in '$_SET'!"
	exit 3
fi
if [ $_COVERS -gt $TOTAL_FILES ]; then
	echo "Error: Could only find $TOTAL_FILES of required $_COVERS!"
	exit 4
fi

#check if imagemagick is installed
if ! command -v compare &> /dev/null; then
    apt update
    apt install imagemagick imagemagick-doc -y
fi
if ! command -v compare &> /dev/null; then
	echo "Error: imagemagick not installed!"
	exit 5
fi

RANDOM=$$$(date +%s)

if [ -d $_STEGO_TESTSET_LOCATION ]; then
	rm -dr $_STEGO_TESTSET_LOCATION
fi
mkdir $_STEGO_TESTSET_LOCATION

i=0
find $_SET -mindepth 1 -maxdepth 1 -type f -name $_SUBSET_MASK | sort -R | head -$_COVERS | while read cover; do
	echo -e "Cover $((i+1))/$_COVERS: $cover"
	
	original="$_STEGO_TESTSET_LOCATION/$(basename $cover .jpg).original.jpg"
	recompressed="$_STEGO_TESTSET_LOCATION/$(basename $cover .jpg).recompressed.jpg"
	
	printProgress $_EMBEDS_PER_COVER 0 0
	
	#copy original
	if [ $_INCLUDE_ORIGINAL -eq 1 ]; then
		cp $cover $original
	fi
	
	#recompress
	if [ $_INCLUDE_RECOMPRESSED -eq 1 ]; then
		convert -quality $_RECOMPRESSION_QUALITY_FACTOR $original -colorspace sRGB -type truecolor $recompressed &>/dev/null
	fi
	
	#loop $_EMBEDS_PER_COVER times
	c=0
	cat $_TESTPROTOCOL_PATH | sort -R | head -$_EMBEDS_PER_COVER | while read testprotocol; do
		c=$((c+1))
		
		printProgress $_EMBEDS_PER_COVER $c 0
		
		tool=$(echo $testprotocol | cut -d " " -f1)
		key=$(echo $testprotocol | cut -d " " -f2)
		data=$(echo $testprotocol | cut -d " " -f3)
		
		stego_file="$_STEGO_TESTSET_LOCATION/$(basename $cover .jpg).$tool-$key-$data.jpg"
		
		case $key in
			noKey) used_passphrase=null;;
			shortKey) used_passphrase=$PASSPHRASE_SHORT;;
			longKey) used_passphrase=$PASSPHRASE_LONG;;
			*) used_passphrase=null;;
		esac
		
		case $data in
			shortEbd) embed_file=$EMBEDDING_SHORT;;
			middleEbd) embed_file=$EMBEDDING_MIDDLE;;
			longEbd) embed_file=$EMBEDDING_LONG;;
			lowEntropyEbd) embed_file=$EMBEDDING_LOWENTROPY;;
			binaryEbd) embed_file=$EMBEDDING_BINARY;;
			*) embed_file=null;;
		esac
		
		#create embeds...
		printProgress $_EMBEDS_PER_COVER $c 1
		case $tool in
			jsteg)
				jsteg hide $original $embed_file $stego_file &> /dev/null
				;;
			outguess)
				if [ "$used_passphrase" == "null" ]; then
					outguess -d $embed_file $original $stego_file &> /dev/null
				else
					outguess -k $used_passphrase -d $embed_file $original $stego_file &> /dev/null
				fi
				;;
			outguess-0.13)
				if [ "$used_passphrase" == "null" ]; then
					outguess-0.13 -d $embed_file $original $stego_file &> /dev/null
				else
					outguess-0.13 -k $used_passphrase -d $embed_file $original $stego_file &> /dev/null
				fi
				;;
			steghide)
				steghide embed -f -ef $embed_file -cf $original -p $used_passphrase -sf $stego_file &> /dev/null
				;;
			f5)
				if [ "$used_passphrase" == "null" ]; then
					f5 -t e -i $original -o $stego_file -d "$(cat $embed_file)" &> /dev/null
				else
					f5 -t e -i $original -o $stego_file -p $used_passphrase -d "$(cat $embed_file)" &> /dev/null
				fi
				;;
			*) ;;
		esac
		
		#delete empty embeds
		find $_STEGO_TESTSET_LOCATION -mindepth 1 -maxdepth 1 -type f -size 0 -delete
		
		printProgress $_EMBEDS_PER_COVER $c 2
		
		#attribute
		#if [ -f $stego_file ]; then
			#call attrib script (TODO: attrib.sh zuerst umschreiben! csv als ausgabe!)
			#abgleichen von tool-detektion, evtl. aussage über datenlänge..
			#schreiben in ausgabe csv
		#fi
	done
	
	printProgress $_EMBEDS_PER_COVER $_EMBEDS_PER_COVER 0
	
	echo ""
	i=$((i+1))
done

#rm -dr $_STEGO_TESTSET_LOCATION

exit 0