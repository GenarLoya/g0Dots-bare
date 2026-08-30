set -gx SHELL /usr/bin/fish

# Disable default greeting
set -g fish_greeting ''

starship init fish | source

# Dotfiles bare repo alias
alias dot '/usr/bin/git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
