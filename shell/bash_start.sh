#!/usr/bin/env bash
# included from ~/.bashrc or ~/.profile or ~/.bash_profile

# this directory
SHELL_PARENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export ENV_HOME_DIR="$(dirname "$SHELL_PARENT_DIR")"
# PARENT_OF_ENV_DIR="$(dirname "$ENV_HOME_DIR")"
# export ENV_DATA_DIR=$PARENT_OF_ENV_DIR/.env
export ENV_DATA_DIR="$HOME/.env"

[[ ! -d $ENV_DATA_DIR ]] && mkdir $ENV_DATA_DIR
[[ ! -d $ENV_DATA_DIR/data ]] && mkdir $ENV_DATA_DIR/data
[[ ! -d $ENV_DATA_DIR/data/emacs ]] && mkdir $ENV_DATA_DIR/data/emacs
[[ ! -d $ENV_DATA_DIR/data/shell ]] && mkdir $ENV_DATA_DIR/data/shell
[[ ! -d $ENV_DATA_DIR/data/vim ]] && mkdir $ENV_DATA_DIR/data/vim
[[ ! -d $ENV_DATA_DIR/ext ]] && mkdir $ENV_DATA_DIR/ext
[[ ! -d $ENV_DATA_DIR/ext/emacs ]] && mkdir $ENV_DATA_DIR/ext/emacs

source $SHELL_PARENT_DIR/lib.sh
source $SHELL_PARENT_DIR/aliases.sh

# [Paths]
[[ -d $SHELL_PARENT_DIR/shell/bin ]] && prependPath PATH $SHELL_PARENT_DIR/shell/bin
[[ -d $ENV_HOME_DIR/bin/$ENV_PLATFORM/$ENV_ARCH ]] && prependPath PATH $ENV_HOME_DIR/bin/$ENV_PLATFORM/$ENV_ARCH
[[ -d $ENV_HOME_DIR/bin/$ENV_PLATFORM ]] && prependPath PATH $ENV_HOME_DIR/bin/$ENV_PLATFORM
[[ -d $ENV_HOME_DIR/bin ]] && prependPath PATH $ENV_HOME_DIR/bin

# setupDisplay;
setupColors;

case "$-" in
    *i*) # interactive
        # [Keyboard Bindings]
        bind -f $ENV_HOME_DIR/etc/inputrc
        if [ -x xrdb ] ; then
            xrdb -load $ENV_HOME_DIR/etc/XDefaults
        fi
        ;;
    *) # non-interactive
        ;;
esac
if hasCommand 'git' ; then
    PS1='\n'$"\[$Blue\][\$(localTime)]\[$NC\]\[$Red\]\$(git_prompt)\[$NC\]:\[$BlackBG\]\[$White\]\w \[$NC\]"$'\n\$ '
else
    PS1="\n\[$Blue\][\t]\[$NC\]:\[$BlackBG\]\[$White\]\w \[$NC\]\n\$ "
fi


# [Other Environment Variables]
export TZ=Etc/UTC # use UTC by default everywhere
export LOCAL_TIME_ZONE
export PAGER=less
export LESSCHARSET='utf-8'
export TMOUT=0 # never logout due to inactivity

# [History]
export HISTFILE=$ENV_DATA_DIR/data/shell/history
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
