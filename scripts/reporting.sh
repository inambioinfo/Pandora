#!/bin/bash
#$ -V
#$ -cwd
#$ -o log.out
#$ -e log.err
#$ -l mem=1G,time=1::

# This script generates the report

# defaults
input="blast/top.concat.txt"
input2="discovery/blast/top.concat.txt"

while [[ $# > 0 ]]; do

	flag=${1}

	case $flag in
		-i|--input)	# the contig input blast file
		input="${2}"
		shift ;;

		-i2|--input2)	# the ORF input blast file
		input2="${2}"
		shift ;;

		-o|--outputdir)	# the output directory
		outputdir="${2}"
		shift ;;

		-l|--logsdir)	# the logs directory
		logsdir="${2}"
		shift ;;

		-d|--scripts)	# the git repository directory
		d="${2}"
		shift ;;

		--blacklist)	# text file of blacklist taxids
		blacklist="${2}"
		shift ;;

		--id)		# sample identifier
		id="${2}"
		shift ;;

		--noclean)	# noclean bool
		noclean="${2}"
		shift ;;

		-v|--verbose)	# verbose
		verbose=true ;;

		*)
				# unknown option
		;;
	esac
	shift
done

# exit if previous step produced zero output
if [ ! -s ${input} ]; then exit; fi

echo "------------------------------------------------------------------"
echo REPORTING START [[ `date` ]]

mkdir -p report

# flag for makereport
flag=""
# if ORF blast file exists
if [ -s ${input2} ]; then
	flag="--input2 ${input2} "
fi
# if blacklist variable set
if [ -n "${blacklist}" ]; then
	flag=${flag}"--blacklist ${blacklist}"
fi

echo filtering blast results
# filter PREDICTED; sort by taxids then query sequence length (careful: this line can scramble the header)
${d}/scripts/makereport.py --input ${input} --header blast/header --sample ${id} --id2reads assembly/reads2contigs.stats.txt ${flag} | grep -v PREDICTED | sort -k5,5n -k6,6nr > report/blast.topfilter.txt

echo REPORTING END [[ `date` ]]
echo "------------------------------------------------------------------"
