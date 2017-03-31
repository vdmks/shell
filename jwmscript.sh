#!/bin/bash

sudo pacman -S lightdm jwm --noconfirm

sudo systemctl enable lightdm.service

echo "exec /usr/bin/jwm" >> ~/.xinitrc

cp -i /etc/system.jwmrc ~/.jwmrc

#
#yaourt
#

echo "[archlinuxfr]" >> /etc/pacman.conf
echo "SigLevel = Never" >> /etc/pacman.conf
echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

sudo pacman -Sy yaourt --noconfirm

sudo pacman -S chromium qbittorrent lxappearance sakura gpicview leafpad nitrogen lxtask wget youtube-dl gvfs p7zip unrar ntfs-3g --noconfirm
