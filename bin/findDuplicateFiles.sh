#!/usr/bin/env bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_PLATFORM="Linux"
source "$ROOT_DIR/../lib.sh"

# finds all duplicate files in a given directory

tmpFile=$(mktemp /tmp/dedup.XXXXXXXXX)
function finish()
{
    \rm -rf "$tmpFile"
}
trap finish EXIT

if [[ "$ENV_PLATFORM" == "Mac" ]]; then
    find "$*" -type f -exec md5 -r {} +  > "$tmpFile"
else
    find "$*" -type f -exec md5sum {} +  > "$tmpFile"
fi
sort "$tmpFile" | uniq -d -w 32 | awk '{$1=""; print $0}'


# collect the output in duplicates.tmp and use the code below
# to remove all files
# for f in $(cat duplicates.tmp) ; do
#     rm "$f"
# done
