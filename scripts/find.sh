#!/bin/bash

path=""
term=""

if [ $# -eq 2 ]
then
	path="${1}"
	term="${2}"
elif [ $# -eq 1 ]
then
	path="."
	term="${1}"
else
	echo "try: bash find.sh <path> <term>"
	exit -1
fi

files=$(find "${path}"|awk 'BEGIN{suffix="^(.*)\.((h)|(cc)|(cu)|(cpp)|(hpp)|(sh))$";}{if (tolower($0) ~ suffix) print $0;}')

for file in ${files}
do
	grep -inH "${term}" "${file}"
done
