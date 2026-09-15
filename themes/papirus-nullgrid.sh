#!/bin/sh
# Builds ~/.local/share/icons/Papirus-Dark-Nullgrid: inherits Papirus-Dark, folders recolored.
# Same trick as papirus-folders (AUR), without touching /usr/share. Re-run after a Papirus update.
set -e
COLOR=${1:-grey}
SRC=/usr/share/icons/Papirus-Dark
DST=$HOME/.local/share/icons/Papirus-Dark-Nullgrid
rm -rf "$DST"; mkdir -p "$DST"
sed -e 's/^Name=.*/Name=Papirus-Dark-Nullgrid/' -e 's/^Inherits=.*/Inherits=Papirus-Dark,breeze-dark,hicolor/' "$SRC/index.theme" > "$DST/index.theme"
for places in "$SRC"/*/places; do
    size=$(basename "$(dirname "$places")")
    mkdir -p "$DST/$size/places"
    # every link that ultimately lands on a *-blue* file (folder, inode-directory, user-desktop, ...)
    for link in "$places"/*.svg; do
        [ -L "$link" ] || continue
        final=$(readlink -f "$link")
        case $final in *-blue*) recolored=$(printf %s "$final" | sed "s/-blue/-$COLOR/")
            [ -e "$recolored" ] && ln -s "$recolored" "$DST/$size/places/$(basename "$link")";; esac
    done
done
gtk-update-icon-cache -q "$DST" 2>/dev/null || true
echo "built $DST ($COLOR)"
