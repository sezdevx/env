#!/usr/bin/env bash
# included from ~/.bashrc or ~/.profile or ~/.bash_profile

# unfortunately because of a bug I had to disable
# set -u

export ENV_BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export ENV_HOME_DIR=$HOME/.env # the env home directory

[[ -d $ENV_HOME_DIR/ext/bash ]] || mkdir -p $ENV_HOME_DIR/ext/bash
[[ -d $ENV_HOME_DIR/ext/emacs ]] || mkdir -p $ENV_HOME_DIR/ext/emacs
[[ -d $ENV_HOME_DIR/data/bash ]] || mkdir -p $ENV_HOME_DIR/data/bash
[[ -d $ENV_HOME_DIR/data/emacs ]] || mkdir -p $ENV_HOME_DIR/data/emacs
[[ -d $ENV_HOME_DIR/data/vim ]] || mkdir -p $ENV_HOME_DIR/data/vim

# [Custom Settings]
[[ -f $ENV_HOME_DIR/ext/bash/bashVars.sh ]] && source $ENV_HOME_DIR/ext/bash/bashVars.sh
source $ENV_BASE_DIR/etc/settings.sh
source $ENV_BASE_DIR/lib.sh
source $ENV_BASE_DIR/etc/aliases.sh

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

# [Display]
setupDisplay;
setupColors;
resetTitle;

# [bc]
if hasCommand 'bc' ; then
    export BC_ENV_ARGS="$ENV_BASE_DIR/etc/bc_init.txt"
    alias c='set -f; c'
    function c()
    {
        bc <<< "$@"
        set +f
    }
fi

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
    PS1='\n'$"\[$Blue\]\u\[$NC\][\$(localTime)]\[$Red\]\$(git_prompt)\[$NC\]:\[$BlackBG\]\[$White\]\w \[$NC\]"$'\n% '
else
    PS1="\n\[$Blue\]\u\[$NC\][\t]:\[$BlackBG\]\[$White\]\w \[$NC\]\n% "
fi


#    case $TERM in
#        xterm*)
#        # all these weird syntax just to satisfy the git bash
#        PS1='\n'$"\[$Blue\]\u\[$NC\][\$(localTime)]\[$Red\]\$(git_prompt)\[$NC\]:\[$BlackBG\]\[$White\]\w \[$NC\]"$'\n% '
#            ;;
#        *)
#            PS1="\n\[$Blue\]\u\[$NC\][\$(localTime)]\[$Red\]\$(git_prompt)\[$NC\]:\[$BlackBG\]\[$White\]\w \[$NC\]\n% "
#            ;;
#    esac


#    case $TERM in
#        xterm*)
#        PS1="\n\[$Blue\]\u\[$NC\][\t]:\[$BlackBG\]\[$White\]\w \[$NC\]\n% "
#            ;;
#        *)
#            PS1="\n\[$Blue\]\u\[$NC\][\t]:\[$BlackBG\]\[$White\]\w \[$NC\]\n% "
#            ;;
#    esac
