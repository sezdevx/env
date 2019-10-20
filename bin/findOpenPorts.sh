#!/usr/bin/env bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_PLATFORM="Linux"
source "$ROOT_DIR/../lib.sh"

if [[ "$ENV_PLATFORM" == "Mac" ]]; then
    if [ `command -v lsof` ]; then
        sudo lsof -i -P -n | grep LISTEN
    elif [ `command -v netstat` ]; then
        netstat -Watnlv | grep LISTEN
    fi
else
    if [ `command -v lsof` ]; then
        sudo ss -tulpn
    elif [ `command -v lsof` ]; then
        sudo lsof -i -P -n | grep LISTEN
    elif [ `command -v netstat` ]; then
        netstat -Watnlv | grep LISTEN
    fi
fi
