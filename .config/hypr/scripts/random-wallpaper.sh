#!/bin/bash

WALLS_DIR="$HOME/.config/hypr/walls"

shopt -s nullglob
WALLPAPERS=($WALLS_DIR/*)
shopt -u nullglob

if [ ${#WALLPAPERS[@]} -eq 0 ]; then
    echo "No wallpapers found in $WALLS_DIR"
    exit 1
fi

RANDOM_WALL="${WALLPAPERS[$((RANDOM % ${#WALLPAPERS[@]}))]}"
echo "Setting random wallpaper: $RANDOM_WALL"
awww img --transition-type random "$RANDOM_WALL"
