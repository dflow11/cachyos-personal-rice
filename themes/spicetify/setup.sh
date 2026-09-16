#!/bin/sh
# One-time Spotify theming. Needs spicetify-cli (AUR):  paru -S spicetify-cli
# Rerun after a Spotify update (spotify-launcher) with:  spicetify backup apply
set -e
here=$(dirname "$(readlink -f "$0")")
mkdir -p ~/.config/spicetify/Themes
ln -sfn "$here/nullgrid" ~/.config/spicetify/Themes/nullgrid
spicetify config spotify_path ~/.local/share/spotify-launcher/install/usr/share/spotify \
                 prefs_path   ~/.config/spotify/prefs \
                 current_theme nullgrid color_scheme nullgrid inject_css 1 replace_colors 1 overwrite_assets 1
spicetify backup apply
