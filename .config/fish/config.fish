set -gx SHELL /usr/bin/fish

# Disable default greeting
set -g fish_greeting ''

starship init fish | source

# Add .local/bin to PATH
fish_add_path -g $HOME/.local/bin

# Pi
fish_add_path "/home/genarold/.local/share/pi-node/node-v22.23.2-linux-x64/bin"
