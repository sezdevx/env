#!/usr/bin/env bash

# finds all duplicate files in a given directory

find "$*" -type f -exec md5sum {} +  > allDuplicateFiles.tmp
sort allDuplicateFiles.tmp | uniq -d -w 32 | awk '{$1=""; print $0}'
\rm allDuplicateFiles.tmp

# collect the output in duplicates.tmp and use the code below
# to remove all files
#for f in $(cat duplicates.tmp) ; do
#    rm "$f"
#done
