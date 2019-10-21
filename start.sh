#!/usr/bin/env bash
# included from ~/.bashrc or ~/.profile or ~/.bash_profile

# unfortunately because of a bug I had to disable
# set -u

export ENV_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export ENV_HOME_DIR=$HOME/.env # the env home directory

[[ -d $ENV_HOME_DIR/ext/bash ]] || mkdir -p $ENV_HOME_DIR/ext/bash
[[ -d $ENV_HOME_DIR/ext/emacs/modules ]] || mkdir -p $ENV_HOME_DIR/ext/emacs/modules
[[ -d $ENV_HOME_DIR/data/bash ]] || mkdir -p $ENV_HOME_DIR/data/bash
[[ -d $ENV_HOME_DIR/data/vim ]] || mkdir -p $ENV_HOME_DIR/data/vim

# [Custom Settings]
[[ -f $ENV_HOME_DIR/ext/bash/bashVars.sh ]] && source $ENV_HOME_DIR/ext/bash/bashVars.sh
source $ENV_BASE_DIR/etc/settings.sh
source $ENV_BASE_DIR/lib.sh
#export ENV_PLATFORM
#export ENV_ARCH
source $ENV_BASE_DIR/etc/aliases.sh
[[ "$ENV_PLATFORM" == "Cygwin" ]] && export TERM=xterm-256color

# [Paths]
prependPath PATH $ENV_BASE_DIR/bin
[[ -d $ENV_BASE_DIR/bin/$ENV_PLATFORM/$ENV_ARCH ]] && prependPath PATH $ENV_BASE_DIR/bin/$ENV_PLATFORM/$ENV_ARCH

# [Other Environment Variables]
export TZ=Etc/UTC # use UTC by default everywhere
export PAGER=less
export LESSCHARSET='utf-8'
export TMOUT=0 # never logout due to inactivity

# [History]
export HISTFILE=$ENV_HOME_DIR/data/bash/history
export HISTSIZE=10000
export HISTIGNORE="&:bg:fg:lsl:lsll:lsa:ls:history:exit"
export HISTCONTROL="ignoreboth"
shopt -s histappend # append to the history file, rather than overwrite it
shopt -s histreedit
shopt -s histverify # allow me to edit the old command

# [Security]
umask 022

# [Bash Other]
# don't allow output redirection overwritte the existing files
set -o noclobber

# don't allow use of CTRl-D to log off
set -o ignoreeof

# report the status of terminated bg jobs immediately
set -o notify

# show the list at first TAB, instead of beeping and and waiting for a second TAB
set show-all-if-ambiguous On

# disable messaging, turn off talk and write (not installed on cygwin by default)
[[ `command -v mesg` ]] &&  tty -s && mesg n

# don't attempt to search PATH for completions when on an empty line
shopt -s no_empty_cmd_completion

# check window size after each command, update the values of LINES and COLUMNS
shopt -s checkwinsize

# disable core
ulimit -S -c 0

# [bc]
if hasCommand 'bc' ; then
    export BC_ENV_ARGS="$ENV_BASE_DIR/etc/bc_init.txt"
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

# [Display, Colors, Title]
setupDisplay;
setupColors;
# resetTitle;

case "$-" in
    *i*) # interactive
        # [Keyboard Bindings]
        bind -f $ENV_BASE_DIR/etc/inputrc
        if [ -x xrdb ] ; then
            xrdb -load $ENV_BASE_DIR/etc/XDefaults
        fi
        ;;
    *) # non-interactive
        ;;
esac

# [Prompt]
if hasCommand 'git' ; then
    PS1='\n'$"\[$Blue\][\$(localTime)]\[$NC\]\[$Red\]\$(git_prompt)\[$NC\]:\[$BlackBG\]\[$White\]\w \[$NC\]"$'\n\$ '
else
    PS1="\n\[$Blue\][\t]\[$NC\]:\[$BlackBG\]\[$White\]\w \[$NC\]\n\$ "
fi
