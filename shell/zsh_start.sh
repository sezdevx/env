#!/usr/bin/env zsh
# included from ~/.zshrc 

# this directory
SCRIPT_PARENT_DIR="$( cd "$( dirname "${(%):-%x}}" )" && pwd )"
export ENV_HOME_DIR="$(dirname "$SCRIPT_PARENT_DIR")"
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

source $SCRIPT_PARENT_DIR/lib.sh
source $SCRIPT_PARENT_DIR/aliases.sh

# [Paths]
[[ -d $SCRIPT_PARENT_DIR/bin ]] && prependPath PATH $SCRIPT_PARENT_DIR/bin
[[ -d $ENV_HOME_DIR/bin/$ENV_PLATFORM/$ENV_ARCH ]] && prependPath PATH $ENV_HOME_DIR/bin/$ENV_PLATFORM/$ENV_ARCH
[[ -d $ENV_HOME_DIR/bin/$ENV_PLATFORM ]] && prependPath PATH $ENV_HOME_DIR/bin/$ENV_PLATFORM
[[ -d $ENV_HOME_DIR/bin ]] && prependPath PATH $ENV_HOME_DIR/bin


setupColors;

precmd() { print -rP "%B%F{blue}[%*]: %K{black}%F{white}%~%b" }
PS1="$ "

# [History]
export HISTFILE=$ENV_DATA_DIR/data/shell/history
export HISTSIZE=10000
export SAVEHIST=$HISTSIZE
# export HISTIGNORE="&:bg:fg:lsl:lsll:lsa:ls:history:exit"
# export HISTCONTROL="ignoreboth"
setopt HIST_IGNORE_SPACE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_IGNORE_ALL_DUPS
# setopt inc_append_history
# setopt SHARE_HISTORY

bindkey -e 
# disable core
ulimit -S -c 0

# disable messaging, turn off talk and write (not installed on cygwin by default)
[[ `command -v mesg` ]] &&  tty -s && mesg n
