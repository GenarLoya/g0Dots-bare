# g0Dots

My Hyprland dotfiles

## Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/GenarLoya/g0Dots-bare/refs/heads/master/.installs/install.sh | bash
```

## Manual Install

1. Clone the repo:
```bash
git clone --bare https://github.com/GenarLoya/g0Dots-bare.git ~/.dotfiles
```

2. Setup the dot command:
```bash
echo 'git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"' > ~/.local/bin/dot
chmod +x ~/.local/bin/dot
```

3. Checkout the files:
```bash
git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout
git --git-dir=$HOME/.dotfiles config --local status.showUntrackedFiles no
```

## Usage

```bash
dot status      # check changes
dot add <file>  # stage file
dot commit -m "msg"  # commit
dot push        # push to remote
```

## Dependencies

- hyprland
- waybar
- rofi
- fish
- ghostty
- awww
