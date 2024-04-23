#!/bin/bash

verbose=false
dir="./"

while getopts vn:d: opt
do
	case $opt in
		v) verbose=true;;
		n) number=$OPTARG;;
		d) dir=$OPTARG;;
	esac
done

shift $[ $OPTIND - 1 ]
problems=( "$@" )


for problem in $problems
do 
	pushd "$dir/$problem" >> /dev/null
	echo "[${problem##*/}]"
	
	
	executable="$(find . -type f ! -name '*.*' | head -n 1)"
	cases="$(find . -type f -regextype posix-extended -regex ".*\.case[[:digit:]]")"
	
	correct=0
	wrong=0
	total=0
	
	for case in $cases
	do
		cat "./$case" | "./$executable" > "./${case}.result"
		answer="$(find . -type f -name "${case##*/}.answer" | head -n 1)"
		if [[ -f "./${case}.answer" ]]; then
			diff --ignore-trailing-space "./${case}.answer" "./${case}.result" > /dev/null
			if [[ ! $? -eq "0" ]]; then
				echo "in ${problem}, ${case##*.}..."
				echo -e "<answer>\t\t\t\t\t\t\t<result>"
				if [ $verbose ]; then
					diff --ignore-trailing-space -y "./${case}.answer" "./${case}.result"
				fi
				wrong=$(($wrong+1))	
			else
				correct=$(($correct+1))	
			fi
		fi
		total=$(($total+1))
	done
	
	if [[ $total -gt 0 ]]; then
		echo "${correct} correct ${wrong} wrong in ${total} cases"
	fi
	
	popd >> /dev/null
done

