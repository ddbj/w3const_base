#!/bin/bash
# Separate a flatfile into small-sized flat files.
# Usage
# splitff.sh -f <flatfile> -s <number of lines>

# Approx default line numbers; Flat file is splitted if line number exceeds this value
DEFAULTLINES=20000000
# 
MESS="The script separates a huge-sized flat file into smaller-sized files.\n\
# Usage  1\n\
splitff.sh -f <flatfile> [-s <number of approx. line numbers, will be splited with this value>]\n\
# Usage 2\n\
You can omit -s option. In the case, the file will be separated with $DEFAULTLINES lines. Each file will be ~1.5-2GB in size\n\
splitff.sh -f <flatfile>\n\
"
FLG="none"
while getopts "f:s:" OPT; do
    case "$OPT" in
    "f" ) FLG="TRUE"; VALUE_F="$OPTARG" ;;
    "s" ) FLG="TRUE"; VALUE_S="$OPTARG" ;;
    * ) echo -e ${MESS} 1>&2
    exit 1 ;;
    esac
done
if [ "$FLG" = "none" ]
then
  echo -e ${MESS}
  exit 1
fi
if [ "$VALUE_S" = "" ]; then
LINES=$DEFAULTLINES
else
LINES=$VALUE_S
fi
# 
cat ${VALUE_F} | awk -v "SPLITSIZE=$LINES" '
BEGIN {
    NUM = 1
    LCOUNT = 0
    TEMPFF = ""
}
$1 == "LOCUS" {
    if (LCOUNT > SPLITSIZE)  {
        printf "Wrote to file %s.partff, and splitted at line %u.\n",NUM,NR-1
        FILENM = NUM ".partff"
        printf "%s",TEMPFF > FILENM
        TEMPFF = ""
        NUM = NUM + 1
        LCOUNT = 0
    }
}
{
    TEMPFF = TEMPFF $0 "\n"
    LCOUNT = LCOUNT + 1
}
END {
    printf "Wrote to file %s.partff.\n",NUM
    FILENM = NUM ".partff"
    printf "%s",TEMPFF > FILENM
    print "The input file has "NR" lines."
}
'