#!/bin/sh
# Installs the nullgrid Plymouth theme and rebuilds the initramfs. Run with sudo.
# Rollback: sudo plymouth-set-default-theme -R cachyos-bootanimation
set -e
here=$(dirname "$(readlink -f "$0")")
rm -rf /usr/share/plymouth/themes/nullgrid
cp -r "$here/nullgrid" /usr/share/plymouth/themes/nullgrid
plymouth-set-default-theme -R nullgrid
echo "nullgrid plymouth theme set; takes effect on next boot"
