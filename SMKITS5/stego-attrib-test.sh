#!/bin/bash
##################################################
# Script: stego-attrib-test.sh
# Syntax: ./stego-attrib-test.sh
# Ausfuehrungsumgebung: virtueller Docker-Container
# Beschreibung: Testen der Attributierungsimplementierung
##################################################
# Konstanten:

_STEGO_TESTSET_LOCATION="./.tmp-stego-testset"
_TESTPROTOCOL_PATH="./stego-attrib-test-protocol.txt"
_SET="./coverData"
_SUBSET_MASK="*_alaska2-*.jpg"
_COVERS=3
_EMBEDS_PER_COVER=8 #maximum is 57
_INCLUDE_RECOMPRESSED=1
_RECOMPRESSION_QUALITY_FACTOR=80

_RESULT_CSV="./generated-attrib-test.csv"

# verwendete Einbettungsschluessel
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

if [ -f $_RESULT_CSV ]; then
	rm -f $_RESULT_CSV
fi

function examine {
	local_sample=${1}
	local_original=${2}

    #https://stackoverflow.com/questions/17998978/removing-colors-from-output
	sh -c "./stego-attrib.sh --examine $local_sample $local_original | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g' 2>&1 | tee $local_sample.txt" &> /dev/null

	if [ -f $local_sample.txt ]; then
		result=$(tail -1 $local_sample.txt)
		if [[ $result == "result:"* ]]; then
			toolstr=$(echo $result | cut -d ":" -f2)

			jphide=$(echo $toolstr | cut -d ";" -f1 | cut -d "=" -f2)
			jsteg=$(echo $toolstr | cut -d ";" -f2 | cut -d "=" -f2)
			outguess=$(echo $toolstr | cut -d ";" -f3 | cut -d "=" -f2)
			outguessold=$(echo $toolstr | cut -d ";" -f4 | cut -d "=" -f2)
			steghide=$(echo $toolstr | cut -d ";" -f5 | cut -d "=" -f2)
			f5=$(echo $toolstr | cut -d ";" -f6 | cut -d "=" -f2)

			#create ranking
			declare -A result_values
			declare -A result_quotes
			result_values=( [jphide]=$(echo $jphide | cut -d "/" -f1) [jsteg]=$(echo $jsteg | cut -d "/" -f1) [outguess]=$(echo $outguess | cut -d "/" -f1) [outguess-0.13]=$(echo $outguessold | cut -d "/" -f1) [steghide]=$(echo $steghide | cut -d "/" -f1) [f5]=$(echo $f5 | cut -d "/" -f1) )
			result_quotes=( [jphide]=$(echo $jphide | cut -d "/" -f3) [jsteg]=$(echo $jsteg | cut -d "/" -f3) [outguess]=$(echo $outguess | cut -d "/" -f3) [outguess-0.13]=$(echo $outguessold | cut -d "/" -f3) [steghide]=$(echo $steghide | cut -d "/" -f3) [f5]=$(echo $f5 | cut -d "/" -f3) )

			ordered_values=$(for k in "${!result_values[@]}"; do echo $k "=" ${result_values["$k"]}; done | sort -rn -k3 | tr "\n" ";")
			ordered_quotes=$(for k in "${!result_quotes[@]}"; do echo $k "=" ${result_quotes["$k"]}; done | sort -rn -k3 | tr "\n" ";")

			first_quote=$(echo $ordered_quotes | cut -d ";" -f1 | cut -d "=" -f2 | xargs | cut -d "." -f1)
			second_quote=$(echo $ordered_quotes | cut -d ";" -f2 | cut -d "=" -f2 | xargs | cut -d "." -f1)

			#need at least 50% certainty
			if [ $first_quote -ge 50 ]; then
				if [ $first_quote -gt $second_quote ]; then
					#let quotes decide
					guess_tool=$(echo $ordered_quotes | cut -d ";" -f1 | cut -d "=" -f1 | xargs)
				else
					#let values decide
					guess_tool=$(echo $ordered_values | cut -d ";" -f1 | cut -d "=" -f1 | xargs)
				fi
			else
				guess_tool="clear"
			fi

			sample_basename=$(basename $local_sample .jpg)
			variation=$(echo $sample_basename | cut -d "." -f2)
			if [[ $variation == *"-"*"-"* ]]; then
				used_tool=$(echo $variation | cut -d "-" -f1)
				used_key=$(echo $variation | cut -d "-" -f2)
				used_data=$(echo $variation | cut -d "-" -f3)
			else
				used_tool=clear
				used_key=-
				used_data=-
			fi

			if [ ! -f $_RESULT_CSV ]; then
				echo "sample;embed data;embed key;embed tool;tool guess;jphide detects;jphide quote;jsteg detects;jsteg quote;outguess detects;outguess quote;outguess-0.13 detects;outguess-0.13 quote;steghide detects;steghide quote;f5 detects;f5 quote" > $_RESULT_CSV
			fi
			echo "$sample_basename.jpg;$used_data;$used_key;$used_tool;$guess_tool;${result_values[jphide]};${result_quotes[jphide]};${result_values[jsteg]};${result_quotes[jsteg]};${result_values[outguess]};${result_quotes[outguess]};${result_values[outguess-0.13]};${result_quotes[outguess-0.13]};${result_values[steghide]};${result_quotes[steghide]};${result_values[f5]};${result_quotes[f5]}" >> $_RESULT_CSV
		fi
	fi
}

i=0
find $_SET -mindepth 1 -maxdepth 1 -type f -name $_SUBSET_MASK | sort -R | head -$_COVERS | while read cover; do
	echo -e "Cover $((i+1))/$_COVERS: $cover"
	
	timestamp_start=$(date +%s)

	original="$_STEGO_TESTSET_LOCATION/$(basename $cover .jpg).original.jpg"
	recompressed="$_STEGO_TESTSET_LOCATION/$(basename $cover .jpg).recompressed.jpg"
	
	printProgress $_EMBEDS_PER_COVER 0 1
	
	#examine original original
	cp $cover $original
	examine $original

	printProgress $_EMBEDS_PER_COVER 0 2
	
	#recompress
	if [ $_INCLUDE_RECOMPRESSED -eq 1 ]; then
		convert -quality $_RECOMPRESSION_QUALITY_FACTOR $original -colorspace sRGB -type truecolor $recompressed &>/dev/null

		examine $recompressed $original
	fi
	
	#loop $_EMBEDS_PER_COVER times
	c=0
	cat $_TESTPROTOCOL_PATH | sort -R | head -$_EMBEDS_PER_COVER | while read testprotocol; do
		c=$((c+1))
		
		printProgress $_EMBEDS_PER_COVER $c 0
		
		tool=$(echo $testprotocol | cut -d " " -f1 | tr "." "-")
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
		if [ -f $stego_file ]; then
			examine $stego_file $original
		fi
	done
	
	printProgress $_EMBEDS_PER_COVER $_EMBEDS_PER_COVER 0
	
	timestamp_end=$(date +%s)
	time_diff=$((timestamp_end-timestamp_start))
	time_diff_min=$((time_diff/60))
	time_diff_sec=$((time_diff%60))

	echo -e "\ntook $time_diff_min mins and $time_diff_sec secs."
	i=$((i+1))
done

#rm -dr $_STEGO_TESTSET_LOCATION

exit 0
