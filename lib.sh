#!/usr/bin/env bash

# Mac, Linux, Cygwin, WSL
ENV_PLATFORM="Linux"
ENV_ARCH="32"

# 32 or 64
unameStr=`uname`
if [[ "$unameStr" = "Darwin" ]]; then
    ENV_PLATFORM="Mac";
elif [[ "$unameStr" =~ [Cc][Yy][Gg][Ww][Ii][Nn] ]]; then
    ENV_PLATFORM="Cygwin";
elif [[ $(uname -r) == *Microsoft ]]; then
    ENV_PLATFORM="WSL";
fi
if [ `uname -m` = "x86_64" ]; then
	ENV_ARCH="64"
fi

ISO_DATE_FMT='%Y-%m-%d %H:%M:%S %Z'

# it returns 0, if command exists, 1 otherwise
# it may appear to be illogical, but the idea is that if hasCommand 'command'
# would execute if the system has the command, in such cases, we have to return 0
# because in shell environment a 0 return means success, whereas any other value
# means failure
function hasCommand()
{
    if [[ `command -v $1` ]]; then
        return 0
    else
        return 1
    fi
}

# note that when used in if, in bash it checks if isAbsoluteDir successfully executed
# which means it returns 0, thus this function returns 0 when the path starts with /
function isAbsoluteDir()
{
    if [[ "$1" =~ ^\/ ]]; then
        return 0
    else
        return 1
    fi
}

# you can't assign the result of this function directly, so
# value=$(getRealPath /path/to/something)
function getRealPath()
{
    if isAbsoluteDir $1 ; then
        echo $1
    else
        echo `cd "$1"; pwd`
    fi
}

# tries to open a given path with the OS's default app
# openResource home opens the github page for the env
# openResource [bash|awk|git|emacs|vim] opens the documentation for the corresponding program
function openResource()
{
    # yes, I know if [[ $# == 1 ]]; then is more efficient
    if [[ $# == 1 && "$1" == "home" ]]; then
        shift # remove the first argument
        set -- "$@" "https://github.com/sezdevx/env"
    elif [[ $# == 1 && "$1" == "bash" ]]; then
        shift
        set -- "$@" "https://github.com/sezdevx/learn/blob/master/bash/readme.md"
    elif [[ $# == 1 && "$1" == "vim" ]]; then
        shift
        set -- "$@" "https://github.com/sezdevx/learn/blob/master/vim/readme.md"
    elif [[ $# == 1 && "$1" == "git" ]]; then
        shift
        set -- "$@" "https://github.com/sezdevx/learn/blob/master/git/readme.md"
    elif [[ $# == 1 && "$1" == "emacs" ]]; then
        shift
        set -- "$@" "https://github.com/sezdevx/learn/blob/master/emacs/readme.md"
    elif [[ $# == 1 && "$1" == "awk" ]]; then
        shift # remove the first argument
        set -- "$@" "https://github.com/sezdevx/learn/blob/master/awk/readme.md"
    fi

    if [[ "$ENV_PLATFORM" == "Mac" ]]; then
        open $*
    elif [[ "$ENV_PLATFORM" == "Cygwin" ]]; then
        cygstart $*
    elif [[ "$ENV_PLATFORM" == "Linux" ]]; then
        if [[ "`command -v xdg-open`" ]]; then
            xdg-open $*
        else
            (>&2 echo "Try installing xdg-open (e.g. sudo apt-get install xdg-utils)")
            echo "Visit: " $*
        fi
    elif [[ "$ENV_PLATFORM" == "WSL" ]]; then
        if [[ "`command -v powershell.exe`" ]]; then
            powershell.exe start $*
        else
            (>&2 echo "No powershell.exe found, install it and/or add it to path")
            echo "Visit: " $*
        fi
    else
        echo "Visit: " $*
    fi
}

# prependPath VARNAME /path/to/existing/dir
# prepends the second argument to the ENVVAR and exports ENVVAR
# it prepends the path if VARNAME does not have it already
# the path should exist in the system
function prependPath()
{
    # check if $1 already has this path
    local envVar=""
    eval envVar=\"\$$1\"
    # the one below handles white space better
    local hasThisPath=$(echo $envVar | tr ":" "\n" | while read i
    do
        if [ "$i" = "$2" ]; then
            echo "t"
            break;
        fi
    done
    echo "f"
    )
    # if $2 path exists and $1 does not have this path
    if [ -d "$2" -a "$hasThisPath" = "f" ]; then
	    eval $1=\"$2\$\{$1:+':'\$$1\}\" && export $1 ;
    fi
}

# find files/directories with a pattern in name:
# ex: findFiles "*~"
function findFiles()
{
    if [[ $# == 0 ]]; then
        echo "Usage: findFiles '*~'"
    else
        eval find ./ -name \"$1\"
        #eval find . -name \"$1\" -ls | awk "{\$1 = \"\"; \$2 = \"\"; \$3 = \"\"; \$4 = \"\"; \$6 = \"\"; print \$0;}" | tr -s " " ;
    fi
}

# find a file with pattern $1 in name and Execute $2 on it:
# ex: findExecute "*.cc" 'ls -l'
# to remove all Emacs backup files: findExecute "*~" 'rm -f'
function findExecute()
{
    eval find ./ -type f -name \"${1:-}\" -exec ${2:-ls} '{}' \\\; ;
}

function findGrepExecute()
{
    eval find ./ \\\( -name .git -o -name .idea -o -name .svn -o -name .DS_Store \\\) -prune -o -type f -name \"$1\" -exec ${2:-ls} '{}' \\\+ ;
}

# find a file with pattern $2 in name and grep files that contain $1
# ex: findGrep "envvar"
# ex: findGrep "envvar" "*.sh"
function findGrep()
{
    if [ $# -eq 0 ]
      then
        echo 'Usage: findGrep "envvar" or findGrep "envvar "*.sh"'
        echo 'Find a file with pattern $2 (defaults to all files) in name and grep files that contain $1'
    else
        findGrepExecute "${2:-*}" "grep -H '${1:-}'"
    fi
}

# case insensitive version of findGrep
# ex: findGrepi "envvar"
# ex: findGrepi "envvar" "*.sh"
function findGrepi()
{
    findGrepExecute "${2:-*}" "grep -H -i \"${1:-}\""
}

# returns the md5 of a given file
function getMd5()
{
    if [ $ENV_PLATFORM == "Mac" ]; then
        echo $(md5 $1) | cut -f4 -d ' '
    else
        echo $(md5sum $1) | cut -f1 -d ' '
    fi
}

# recursively delete all files specified with $1 pattern
function removeFiles()
{
    if [ $# -eq 0 ]; then
        echo "Usage: removeFiles '*.class'"
        echo 'Remove all files that match the given criteria'
    else
        findExecute "$1" 'rm -f'
    fi
}

#For Regular Consoles
function setupConsoleColors()
{
    NC='\033[0m'

    Blue='\e[1;34m'
    Purple='\e[1;35m'
    Red="\e[1;31m"
    White='\e[1;37m'
    Green='\e[1;32m'

    BlackBG='\e[40m'
}

#For Xterm Consoles
function setupXtermColors()
{

    NC="$(tput sgr0)"       # No Color

    Blue="$(tput bold ; tput setaf 4)"
    Purple="$(tput bold ; tput setaf 5)"
    Red="$(tput bold ; tput setaf 1)"
    White="$(tput bold ; tput setaf 7)"
    Green="$(tput bold ; tput setaf 2)"

    BlackBG="$(tput setab 0)"
}

#For Any console
function setupColors()
{
    case "$TERM" in
        *term | rxvt)
            setupXtermColors;
            ;;
        *)
            setupConsoleColors;
            ;;
    esac
}

# to list files in tar or zip archives
# Usage: peek compressed.tar.gz
function peek() {
    local file=$1
    shift
    case $file in
        *.tar)
            tar tvf $file ;;
        *.tbz2 | *.tar.bz2)
            tar tvfj $file ;;
        *.tgz | *.tar.gz)
            tar tvfz $file ;;
        *.zip)
            unzip -l $file ;;
        *) echo "Unrecognized file type $file" ;;
    esac
}

# Usage:
# pack final.tar.gz File1 File2 File3
# pack final.tar.gz Directory1 Directory2 File1 ...
function pack () {
   local file=$1
   shift
   if [[ $# == 1 && -f $1 ]]; then
       case $file in
          *.tar)     tar chf $file $*  ;;
          *.tar.bz2) tar chjf $file $*  ;;
          *.tbz2) tar chjf $file $*  ;;
          *.tar.gz)  tar chzf $file $*  ;;
          *.tgz)     tar chzf $file $*  ;;
          *.zip)     zip $file $*      ;;
          *.bz2)     bzip2 -c $1 > $file ;;
          *.gz)      gzip -c $1 > $file  ;;
          *)         echo "File type not recognized" ;;
       esac
   else
       case $file in
          *.tar)     tar chf $file $*  ;;
          *.tar.bz2) tar chjf $file $*  ;;
          *.tbz2) tar chjf $file $*  ;;
          *.tar.gz)  tar chzf $file $*  ;;
          *.tgz)     tar chzf $file $*  ;;
          *.zip)     zip -r $file $*      ;;
          *)         echo "File type not recognized" ;;
       esac
   fi
}

# Usage:
# unpack test.tar.gz
# unpack test.bz2
function unpack()
{
     if [ -f $1 ] ; then
         case $1 in
             *.tar.bz2)   tar xjf $1     ;;
             *.tar.gz)    tar xzf $1     ;;
             *.bz2)       bunzip2 $1      ;;
             *.gz)        gunzip $1       ;;
             *.tar)       tar xf $1      ;;
             *.tbz2)      tar xjf $1     ;;
             *.tgz)       tar xzf $1     ;;
             *.zip)       unzip $1        ;;
             *.Z)         uncompress $1   ;;
             *)           echo "'$1' cannot be extracted via >extract<" ;;
         esac
     else
         echo "'$1' is not a valid file"
     fi
}

# returns the epoch number from the given date, according to the given format
function toEpochF()
{
    if [ $# -eq 0 ]; then
        echo "Usage: toEpochF '%Y-%m-%d %H:%M:%S %Z' '2018-07-25 14:36:02 UTC'"
        echo 'Convert the given date to epoch seconds since 1970'
    else
        local format=$1
        shift
        if [ "$ENV_PLATFORM" = "Mac" ]; then
            date -j -f "$format" "$*" +"%s"
        elif [[ "$ENV_PLATFORM" = "Linux" || "$ENV_PLATFORM" = "Cygwin" || "$ENV_PLATFORM" = "WSL" ]]; then
            date -d "$*" '+%s'
        else
            echo "Not Supported"
        fi
    fi
}

# returns the date from the given epoch number, but you can specify the format
function fromEpochF()
{
    if [ $# -eq 0 ]; then
        echo "Usage: fromEpochF '%Y-%m-%d %H:%M:%S %Z' 1533823979"
        echo "Convert epoch seconds since 1970 to date with the given format, always in UTC"
    else
        local format=$1
        shift
        if [ "$ENV_PLATFORM" = "Mac" ]; then
            TZ=Etc/UTC date -r $1 "+$format"
        elif [[ "$ENV_PLATFORM" = "Linux" || "$ENV_PLATFORM" = "Cygwin" || "$ENV_PLATFORM" = "WSL" ]]; then
            TZ=Etc/UTC date -d "@$1" "+$format"
        else
            echo "Not Supported"
        fi
    fi
}

# returns the epoch number for the given time
# make sure the date is not quoted, otherwise it will throw an error
function toEpoch()
{
    local lastArg="${@: -1}"
    if [[ $lastArg =~ [a-zA-z]+ && $lastArg != 'UTC' && "$ENV_PLATFORM" == "Mac" ]]; then
        if [[ -z $LOCAL_TIME_ZONE ]]; then
            ROOT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
            source "$ROOT_DIR/etc/settings.sh"
        fi
        TZ=$LOCAL_TIME_ZONE date -j -f "$ISO_DATE_FMT" "$*" +"%s"
    else
        toEpochF "$ISO_DATE_FMT" $*
    fi
}

# returns the date from the given epoch number
function fromEpoch()
{
    fromEpochF "$ISO_DATE_FMT" $*
}

# Given a number it converts it to a more pleasant to read display format
# e.g. Kilobyte, Megabyte or Gigabytes
function bytesToDisplay
{
    local number=$1
    if (( number < 1024 )); then
        echo $number
    elif (( number < (1024*1024) )); then
        number=$((number/1024))
        echo "$number KBs"
    elif (( number < (1024*1024*1024) )); then
        number=$((number/(1024*1024)))
        echo "$number MBs"
    else
        number=$((number/(1024*1024*1024)))
        echo "$number GBs"
    fi
}

# prints a horizontal line depending on the size of the screen
function printhr() {
    local line="---------------------------------------------------------------------------------------------------\
-------------------------------------------------------------------------------------------------------------------\
-------------------------------------------------------------------------------------------------------------------\
-------------------------------------------------------------------------------------------------------------------"

    printf "%s\n" "${line:0:${COLUMNS:-$(tput cols)}}"
}

