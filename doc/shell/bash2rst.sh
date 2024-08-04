#!/usr/bin/env bash
#############################################################################
#"""
#bash2rst.sh
#===========
#Script to parse BASH comments that contain Sphinx-type comment block
#start and stop indicator """. This commment block is an example of that.
#
#Example
#-------
#Running this script on itself will output this comment block.
#
#Created by Marko Kosunen on 18.07.2014
#
#"""
# This part should not be parsed
# as it is not enclosed by #""" ... #"""
#"""
#Example2
#--------
#Here we parse again
#and continue doing it.
#"""
#############################################################################
#Function to display help with -h argument and to control
#The configuration from the command line
help_f()
{
SCRIPTNAME="bash2rst.sh"
cat << EOF
${SCRIPTNAME} Release 1.0 (03.08.2024)
 Utility script to parse BASH comments that contain Sphinx-type comment block
 start and stop indicator """.

 Written by Marko Pikkis Kosunen

 SYNOPSIS
   ${SCRIPTNAME} [OPTIONS] [SOURCE_FILE]
 DESCRIPTION
   Parses the source file and outputs the lines that are between lines
   starting with #""". Revoves the first # in the beginning of the line.
   It is assumed that everything following the first '#' is written proper
   RST syntax. Output is produced to stdout.

 SOURCE_FILE
     The file you wish to operate on.

 OPTIONS
   -h
       Show this help.

EOF
}
ARGCOUNT=0
while getopts h opt
do
  ARGCOUNT=$((ARGCOUNT+1))
  case "$opt" in
    h) help_f; exit 0;;
  esac
done
# We shift after looping in order not to miss parameters
shift $ARGCOUNT

SOURCE="$(readlink -f $1)"

if [ ! -f "${SOURCE}" ]; then
    echo "Source file ${SOURCE} does not exist. Aborting."
    exit 1
fi

cat ${SOURCE} > ./bash2rst_workfile_$$.txt
sed -i -e '/^#"""/,/^#"""/!d' \
    -e '/^#"""\s*$/d' \
    -e 's/#"""//g' \
    -e 's/^#//g' \
    ./bash2rst_workfile_$$.txt || exit 1

cat ./bash2rst_workfile_$$.txt \
    && rm -f ./bash2rst_workfile_$$.txt || exit 1

exit 0

