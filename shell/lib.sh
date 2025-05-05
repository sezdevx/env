# Mac, Linux, Cygwin, WSL
ENV_PLATFORM="Unknown"
ENV_ARCH="32"
LOCAL_TIME_ZONE="Etc/UTC"
ISO_DATE_FMT='%Y-%m-%d %H:%M:%S %Z'

# find the platform, architecture and time zones
unameStr=`uname`
if [[ "$unameStr" = "Darwin" ]]; then
    ENV_PLATFORM="Mac";
elif [[ "$unameStr" =~ [Cc][Yy][Gg][Ww][Ii][Nn] ]]; then
    ENV_PLATFORM="Cygwin";
elif [[ $(uname -r) =~ [Ll][iI][nN][uU][Xx] ]]; then
    ENV_PLATFORM="Linux";    
elif [[ $(uname -r) == *Microsoft ]]; then
    ENV_PLATFORM="WSL";
fi

unameMachine=`uname -m`
if [[ "$unameMachine" = "x86_64" ]]; then
    ENV_ARCH="64"
elif [[ "$unameMachine" = "arm64" ]]; then
    ENV_ARCH="64"
fi    
    

# Find the Time zone
if [[ -z "${TZ}" ]]; then
    LOCAL_TIME_ZONE="Etc/UTC"
elif [[ -z "${LOCAL_TIME_ZONE}" ]]; then
    LOCAL_TIME_ZONE=$TZ
fi
if [ -f /etc/timezone ]; then
  LOCAL_TIME_ZONE=`cat /etc/timezone`
elif [ -h /etc/localtime ]; then
    LOCAL_TIME_ZONE=`readlink /etc/localtime`
    if [[ $LOCAL_TIME_ZONE =~ ^\/var\/db ]]; then
        LOCAL_TIME_ZONE=`readlink /etc/localtime | sed "s/\/var\/db\/timezone\/zoneinfo\///"`
    else
        LOCAL_TIME_ZONE=`readlink /etc/localtime | sed "s/\/usr\/share\/zoneinfo\///"`
    fi
fi

[[ "$ENV_PLATFORM" == "Cygwin" ]] && export TERM=xterm-256color

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
    if [[ $# == 0 ]]; then
        echo "Built-in options: env, bash, vim, tmux, git, emacs, awk"
        return
    fi
    # yes, I know if [[ $# == 1 ]]; then is more efficient
    if [[ $# == 1 && "$1" == "env" ]]; then
        shift # remove the first argument
        set -- "$@" "https://github.com/sezdevx/env"
    elif [[ $# == 1 && "$1" == "bash" ]]; then
        shift
        set -- "$@" "https://github.com/sezdevx/learn/blob/master/bash/readme.md"
    elif [[ $# == 1 && "$1" == "vim" ]]; then
        shift
        set -- "$@" "https://github.com/sezdevx/learn/blob/master/vim/readme.md"
    elif [[ $# == 1 && "$1" == "tmux" ]]; then
        shift
        set -- "$@" "https://github.com/sezdevx/learn/blob/master/linux/tmux.md"
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
        if [[ -z "$LOCAL_TIME_ZONE" ]]; then
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
# if the first parameter is true, then a new line is printed before new line
# if the second paramter is true, then an extra new line is printed after new line
function printhr() {
    local line="---------------------------------------------------------------------------------------------------\
-------------------------------------------------------------------------------------------------------------------\
-------------------------------------------------------------------------------------------------------------------\
-------------------------------------------------------------------------------------------------------------------"

    if [[ $1 == "true" ]]; then
        printf "\n"
    fi
    printf "%s\n" "${line:0:${COLUMNS:-$(tput cols)}}"
    if [[ $2 == "true" ]]; then
        printf "\n"
    fi
}

# gitCommit comment goes here
function gitCommit() {
    local BRANCH="$(git rev-parse --abbrev-ref HEAD)"
    git add . && git commit -m "$*" && git push origin "$BRANCH"
}


function setupDisplay ()
{
   if [ -z ${DISPLAY:=""} ]; then
       getXServer;
       if [[ -z ${XSERVER:=""}  || ${XSERVER} == $(hostname) || ${XSERVER} == "unix" ]]; then
          DISPLAY=":0.0"          # Localhost
       else
          DISPLAY=${XSERVER}:0.0  # Remote
       fi
   fi
   export DISPLAY
}

# resetting X Title
function resetTitle()
{
    export PROMPT_COMMAND='echo -ne "\033]0;${HOSTNAME}\007"'
}

# You can use this function from shell to custom set the title
function setTitle()
{
    case "$TERM" in
        *term | rxvt | xterm-256color)
            echo -n -e "\033]0;$*\007" ;;
        *)
            ;;
    esac
    export PROMPT_COMMAND=
}

# X Window Related
function getXServer()
{
    case $TERM in
       xterm )
            XSERVER=$(who am i | awk '{print $NF}' | tr -d ')''(' )
            XSERVER=${XSERVER%%:*}
            ;;
    esac
}

function git_prompt()
{
    local repo=$(git rev-parse --show-toplevel 2> /dev/null)
    if [[ -e $repo ]]; then
        #local response=`git branch 2>/dev/null | grep '^*' | colrm 1 2`
        local response=`git branch 2>/dev/null | grep '^*' | cut -d ' ' -f2`
        local git_status=$(LC_ALL=C git status --untracked-files=normal --porcelain)
        if [[ "$?" -ne 0 ]]; then
            echo "(error)";
            return
        fi
        # below code is from (modified from original version)
        # https://github.com/magicmonty/bash-git-prompt/blob/master/LICENSE.txt
        local staged_count=0
        local modified_count=0
        local conflict_count=0
        local untracked_count=0
        local status=''
        local line=''
        while IFS='' read -r line || [[ -n "$line" ]]; do
            status=${line:0:2}
            while [[ -n $status ]]; do
                case "$status" in
                    \?\?)
                            ((untracked_count++));
                            local file=${line:3}
                            if [[ $file =~ ^\..* ]]; then
                                ((untracked_count--));
                            fi
                            break ;;
                    U?) ((conflict_count++)); break;;
                    ?U) ((conflict_count++)); break;;
                    DD) ((conflict_count++)); break;;
                    AA) ((conflict_count++)); break;;
                    #two character matches, first loop
                    ?M) ((modified_count++)) ;;
                    ?D) ((modified_count++)) ;;
                    ?\ ) ;;
                    #single character matches, second loop
                    U) ((conflict_count++)) ;;
                    \ ) ;;
                    *) ((staged_count++)) ;;
                esac
                status=${status:0:(${#status}-1)}
            done
        done <<< "$git_status"
        if [[ $modified_count > 0 || $conflict_count > 0 || $staged_count > 0 || $untracked_count > 0 ]]; then
            response="$response|"
            local putSpace=0
            [[ $conflict_count > 0 ]] && response="${response}x$conflict_count" && putSpace=1
            if [[ $modified_count > 0 ]]; then
                if [[ $putSpace == 1 ]]; then
                    response="$response "
                fi
                response="${response}+$modified_count"
                putSpace=1
            fi
            if [[ $staged_count > 0 ]]; then
                if [[ $putSpace == 1 ]]; then
                    response="$response "
                fi
                response="${response}*$staged_count"
                putSpace=1
            fi
            if [[ $untracked_count > 0 ]]; then
                if [[ $putSpace == 1 ]]; then
                    response="$response "
                fi
                response="${response}?$untracked_count"
            fi
        fi
        echo "($response)"
    else
        echo ''
    fi
}

# [bc]
if hasCommand 'bc' ; then
    export BC_ENV_ARGS="$ENV_HOME_DIR/etc/bc_init.txt"
    # you can do simple math as "c 2 + 5" or
    # don't give any arguments and instead type the expression
    alias c='set -f; c'
    function c()
    {
        local line
        if [[ $# == 0 ]]; then
            read line
        else
            line="$@"
        fi
        bc <<< $line
        set +f
    }
fi

