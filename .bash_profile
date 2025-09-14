# .bash_profile

# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc
# XDG_RUNTIME_DIR for sway
if [ -z "$XDG_RUNTIME_DIR" ]; then
  export XDG_RUNTIME_DIR="/run/user/$(id -u)"
  mkdir -p "$XDG_RUNTIME_DIR"
  chmod 700 "$XDG_RUNTIME_DIR"
fi

# dbusqq

eval "$(dbus-launch --sh-syntax)"

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  export XDG_SESSION_TYPE=wayland
  export XDG_CURRENT_DESKTOP=swayfx
  # export QT_QPA_PLATFORM=wayland
  exec /usr/bin/sway "$@"
fi
