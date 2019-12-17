#!/usr/bin/env bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_PLATFORM="Linux"
source "$ROOT_DIR/../lib.sh"

# finds all duplicate files in a given directory
dirName="$*"
if [[ $# == 0 ]]; then
    dirName="."
fi

tmpFile=$(mktemp /tmp/dedup.XXXXXXXXX)
function finish()
{
    \rm -rf "$tmpFile"
}
trap finish EXIT

if [[ "$ENV_PLATFORM" == "Mac" ]]; then
    find $dirName -type f -exec md5 -r {} +  > "$tmpFile"
    sort "$tmpFile"  | cut -c -32 | uniq -d | grep -f /dev/fd/0 "$tmpFile"
    #| awk '{$1=""; print $0}'
else
    find $dirName -type f -exec md5sum {} +  > "$tmpFile"
    sort "$tmpFile" | uniq -d -w 32
    #| awk '{$1=""; print $0}'
fi


# collect the output in duplicates.tmp and use the code below
# to remove all files
# for f in $(cat duplicates.tmp) ; do
#     rm "$f"
# done
