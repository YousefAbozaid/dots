# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='\[\e[38;5;35;48;5;235;1;3m\]\w\[\e[23;91m\]>\[\e[0m\] '
alias i='doas xbps-install -S'

alias r='doas xbps-remove -R'
alias ll='ls -l'
alias q='xbps-query -Rs'
alias c='clear -x'
alias u='doas xbps-install -S; doas xbps-install -u xbps; doas xbps-install -u'
alias f='flatpak install flathub org.'
alias uf='sudo xbps-install -S; sudo xbps-install -u xbps; sudo xbps-install -u'
alias sf='flatpak search'
alias vi='nvim'
alias whisper="~/whisper-env/bin/whisper"
alias startweb='doas ln -s /etc/sv/httpd /var/service/'
alias stopweb='doas rm /var/service/httpd'
alias Sq='sudo ln -s /etc/sv/mariadb /var/service/'
alias cl='system clear;'
export ZEIT_DB="$HOME/.config/zeit.db"
MOZ_ENABLE_WAYLAND=1
alias foot='FOOT_BIDI=1 FOOT_COMBINE=1 foot'
alias ..='cd ..'
set -o vi
export TERMINAL=foot
