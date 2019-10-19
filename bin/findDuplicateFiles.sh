#!/usr/bin/env bash

# finds all duplicate files in a given directory

find "$*" -type f -exec md5sum {} +  > allDuplicateFiles.tmp
sort allDuplicateFiles.tmp | uniq -d -w 32 | awk '{$1=""; print $0}' > duplicateFiles.tmp
\rm allDuplicateFiles.tmp
cat duplicateFiles.tmp
\rm duplicateFiles.tmp

