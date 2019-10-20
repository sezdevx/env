#!/usr/bin/env bash

ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ENV_PLATFORM="Linux"
source "$ROOT_DIR/../lib.sh"

if [[ "$ENV_PLATFORM" == "Mac" ]]; then
    if [ `command -v lsof` ]; then
        sudo lsof -i -P -n | grep LISTEN
    elif [ `command -v netstat` ]; then
        netstat -Watnlv | grep LISTEN | awk '{"ps -o comm= -p " $9 | getline procname;colred="\033[01;31m";colclr="\033[0m"; print colred "proto: " colclr $1 colred " | addr.port: " colclr $4 colred " | pid: " colclr $9 colred " | name: " colclr procname;  }' | column -t -s "|"
    fi
else
    if [ `command -v lsof` ]; then
        sudo ss -tulpn
    elif [ `command -v lsof` ]; then
        sudo lsof -i -P -n | grep LISTEN
    elif [ `command -v netstat` ]; then
        netstat -Watnlv | grep LISTEN | awk '{"ps -o comm= -p " $9 | getline procname;colred="\033[01;31m";colclr="\033[0m"; print colred "proto: " colclr $1 colred " | addr.port: " colclr $4 colred " | pid: " colclr $9 colred " | name: " colclr procname;  }' | column -t -s "|"
    fi
fi
