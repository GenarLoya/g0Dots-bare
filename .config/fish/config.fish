set -gx SHELL /usr/bin/fish

# Disable default greeting
set -g fish_greeting ''

starship init fish | source

# Pi node PATH
set -gx PATH /home/genarold/.local/share/pi-node/node-v22.23.2-linux-x64/bin $PATH

# Dotfiles bare repo alias
alias dot '/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
