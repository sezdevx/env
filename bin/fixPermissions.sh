#!/usr/bin/env bash

dir="$*"

find $dir -type f -exec chmod 0664 {} +
find $dir -type d -exec chmod 0775 {} +
find $dir -type f -name "*.sh" -exec chmod 0764 {} +



