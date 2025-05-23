if [[ -z "$ENV_PLATFORM" ]]; then
    echo "No ENV_PLATFORM defined. Should be only sourced from start.sh"
    exit 1
fi

# should be only sourced from start.sh
case "$ENV_PLATFORM" in
    Mac)
        alias ls='ls -FG'
        alias lsa='ls -AFGr'
        alias lsl='ls -AslhGr'

        alias duh='du -h -d 1'
        alias df='df -h'
        # more Linux-like stat
        alias stat='stat -x -t "%Y-%m-%d %T.000000000 %z"'
        ;;
    *)
        alias ls='ls -F --color'
        alias lsa='ls -AF --color'
        alias lsl='ls -Aslh --color'

        alias duh='du -h --max-depth=1'
        alias df='df -hT'
        ;;
esac

alias disableCore='ulimit -S -c 0'
# on macs they are written to /cores
alias enableCore='ulimit -S -c unlimited'

# [Aliases]
# to sanitize the terminal
alias sane="stty sane; trap INT"

# to remove emacs files
alias edel="\rm *~; \rm .*~"

# easier navigation
alias cd..="cd .."
alias ..="cd .."

# how large current directory is
alias dus='du -sh'

#displays top 15 largest files
alias largeFiles='find . \( -path .\/.git -o -path .\/.idea -o -path .\/.svn -o -path .\/.DS_Store \) -prune -o -type f -ls | awk "{printf \$7; \$1 = \"\"; \$2 = \"\"; \$3 = \"\"; \$4 = \"\"; \$6 = \"\"; \$7 = \"\"; print \$0;}" | sort -nr | tr -s " " | head -15 | awk "function toDisplay(x) { split( \"b K M G T\", v ); s = 1; while( x >= 1024 ){ x /= 1024; s++; } return sprintf(\"%d%s\", int(x), v[s]); } {printf toDisplay(\$1); \$1 = \"\"; print \$0;}" '

# make sure we don't mess things up
alias cp='cp -i'
alias rm='rm -i'
alias mv='mv -i'

# process management
#alias ps='ps aux'

#paths
alias paths='echo -e ${PATH//:/\\n}'
# programs
# somehow we need this export thing because under tmux both
# emacs and vim do not show the colors properly
alias emacs="export TERM=screen-256color && emacs -Q --load ${ENV_HOME_DIR}/emacs/config.el"
alias vim="export TERM=screen-256color && vim -u ${ENV_HOME_DIR}/etc/vim/vimrc"
alias tmux="tmux -f ${ENV_HOME_DIR}/etc/tmux.conf"
alias tm="tmux attach"
alias tmls="tmux list-sessions"
alias tmkill="tmux kill-server"
alias gobuild="go build $1 -o ./build"

# alias localDate="TZ=$LOCAL_TIME_ZONE date  '+$ISO_DATE_FMT'"
# alias utcDate="TZ=Etc/UTC date -u '+$ISO_DATE_FMT'"
alias localTime="TZ=$LOCAL_TIME_ZONE date  '+%H:%M:%S'"

if [[ `command -v python3` ]]; then
    alias py=python3
else
    alias py=python
fi


# display pid too
alias jobs='jobs -l'
# display idle time and the associated pid
alias who='who -u'

if [ `command -v curl` ]; then
    alias download='curl -L -C - -O --retry 5'
    alias httpHeaders='curl -v -so /dev/nul'
elif [ `command -v wget` ]; then
    alias download='wget -c'
    alias httpHeaders='echo "No curl found"'
else
    alias download='echo "No wget or curl found"'
    alias httpHeaders='echo "No curl found"'
fi

