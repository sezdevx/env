#!/usr/bin/env bash

if [[ -z $ENV_HOME_DIR ]]; then
    echo "env is not installed properly: Undefined ENV_HOME_DIR environment variable"
    echo "Make sure your bash includes start.sh in .profile or .bashrc files"
    exit 1
fi
ENV_EXT_DIR="$ENV_HOME_DIR/ext"

function showHelp ()
{
    echo "manageVars.sh [-a varName varValue][-h][-d varName]"
    echo "-a varName: add or update varName with the varValue"
    echo "-d varName: delete the varName"
    echo "-l: lists all the varNames and their values"
    echo "-s varName: show the value of the varName"
    exit 0
}

function addVar ()
{
    local name=$1
    local value=$2
    if [[ -e $ENV_EXT_DIR/bash/bashVars.sh && -n "$(grep ${name}= $ENV_EXT_DIR/bash/bashVars.sh)" ]]; then
        #echo "Found $name in $ENV_EXT_DIR/bash/bashVars.sh, updating its value"
        sed -i".bak" "/export $name=/d" $ENV_EXT_DIR/bash/bashVars.sh
    fi
    echo "export $name='$value'" >> $ENV_EXT_DIR/bash/bashVars.sh
    #source $ENV_EXT_DIR/bash/bashVars.sh
}

function removeVar ()
{
    local name=$1
    if [[ -e $ENV_EXT_DIR/bash/bashVars.sh && -n "$(grep ${name}= $ENV_EXT_DIR/bash/bashVars.sh)" ]]; then
        #echo "Removed $name in $ENV_EXT_DIR/bash/bashVars.sh"
        sed -i".bak" "/export $name=/d" $ENV_EXT_DIR/bash/bashVars.sh
#        export $name=
#        unset $name
    else
        echo "No such var: $name"
    fi
}

function listVars ()
{
    if [[ ! -z $1 ]]; then
        if [ -e $ENV_EXT_DIR/bash/bashVars.sh ]; then
            grep "^export $1="  $ENV_EXT_DIR/bash/bashVars.sh | cut -d= -f 2
        fi
    else
        if [ -e $ENV_EXT_DIR/bash/bashVars.sh ]; then
            cat $ENV_EXT_DIR/bash/bashVars.sh
#        else
#            echo "Empty List"
        fi
    fi
}

if [[ $# == 0 ]]; then
    showHelp
fi

varName=""
add=0
while getopts "h?a:d:ls:" opt; do
    case "$opt" in
    h|\?)
        showHelp
        ;;
    a)
        varName=$OPTARG
        add=1
        ;;
    d)
        varName=$OPTARG
        add=0
        ;;
    l)
        listVars
        exit 0
        ;;
    s)
        listVars $OPTARG
        exit 0
        ;;
    esac
done
shift $(expr $OPTIND - 1 )

if [[ $add == 1 ]]; then
    if [[ $# == 0 ]]; then
        echo "Missing varValue"
        exit 1
    fi
    addVar $varName "$*"
else
    removeVar $varName
fi


