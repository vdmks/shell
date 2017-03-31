#!/bin/bash

sudo pacman -S chromium qbittorrent jwm lightdm lxappearance sakura gpicview leafpad nitrogen lxtask htop p7zip unrar ntfs-3g preload prelink --noconfirm

systemctl enable lightdm.service

echo "exec /usr/bin/jwm" >> ~/.xinitrc

cp -i /etc/system.jwmrc ~/.jwmrc

#
#yaourt
#

echo "[archlinuxfr]" >> /etc/pacman.conf
echo "SigLevel = Never" >> /etc/pacman.conf
echo "Server = http://repo.archlinux.fr/\$arch" >> /etc/pacman.conf

pacman -Sy yaourt
