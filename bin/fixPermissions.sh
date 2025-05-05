#!/usr/bin/env bash

# when working on windows, permissions got all mixed up
# this is a quick way to fix them

dir="$*"

find $dir -type f -exec chmod 0664 {} +
find $dir -type d -exec chmod 0775 {} +
find $dir -type f -name "*.sh" -exec chmod 0764 {} +



