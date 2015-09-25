# System-wide .bashrc file for interactive bash(1) shells.

[[ $- != *i* ]] && return
export EDITOR="nano"
PS1='\[\e[1m\]\u\[\e[m\]@\h:\[\e[4m\]${PWD}\[\e[m\]>'
shopt -s cdspell
alias ls='ls --color -F'
alias dir='ls --color -halF'
chmod a+rw `tty`
alias network='sudo iftop'
alias startup='sudo rcconf'
alias backport='sudo apt-get -t jessie-backports'
export LANG=en_GB.UTF-8
export LANGUAGE=en_GB.UTF-8
