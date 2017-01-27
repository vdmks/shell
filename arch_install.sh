#!/bin/bash

ischroot=0

if [ $ischroot -eq 0 ]
then

	loadkeys ru

	cfdisk

	_EOF_

	mkfs.ext2 -L boot /dev/sda1
	mkfs.ext4 -L root /dev/sda3
	mkfs.ext4 -L home /dev/sda4
	mkswap -L swap /dev/sda2

	mount /dev/sda3 /mnt
	mkdir /mnt/boot
	mkdir /mnt/home

	mount /dev/sda1 /mnt/boot
	mount /dev/sda4 /mnt/home
	swapon /dev/sda2

	pacstrap /mnt base base-devel --noconfirm

	genfstab -U -p /mnt >> /mnt/etc/fstab

	sed -i 's/ischroot=0/ischroot=1/' ./arch_install.sh
	cp ./arch_install.sh /mnt/arch_install.sh

	arch-chroot /mnt /bin/bash -x << _EOF_
	sh /install_blackarch.sh
	_EOF_

	echo "Done"

fi

if [ $ischroot -eq 1 ]
then

	echo arch > /etc/hostname
	
	ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

	#замена строк в файле
	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
	sed -i 's/#ru_RU.UTF-8 UTF-8/ru_RU.UTF-8 UTF-8/' /etc/locale.gen

	echo LANG=en_US.UTF-8 > /etc/locale.conf
	
	locale-gen

	mkinitcpio -p linux

	pacman -S grub --noconfirm

	grub-install /dev/sda

	grub-mkconfig -o /boot/grub/grub.cfg

	#работа с учетной записью

	sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
	sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

	useradd -m -g users -G wheel,video -s /bin/bash user

	cp /etc/X11/xinit/xinitrc /home/user/.xinitrc


	#видео и аудиодрайверы
	pacman -S bash-completion xorg-server xorg-xinit xorg-utils xorg-server-utils mesa xf86-video-nouveau alsa-lib alsa-utils alsa-oss alsa-plugins ttf-liberation ttf-droid --noconfirm

	#DE и софт
	pacman -S lxde chromium sublime-text evince fbreader screenfetch htop youtube-dl moc gcolor2 pinta unzip unrar p7zip truecrypt gvfs polkit-gnome ntfs-3g gpicview --noconfirm

	echo exec startlxde > ~/.xinitrc

	systemctl enable dhcpd.service

	
fi

	arch-chroot /mnt /bin/bash -x << _EOF_
	passwd
	root
	root
	_EOF_

	arch-chroot /mnt /bin/bash -x << _EOF_
	passwd user
	user
	user
	_EOF_


umount -R /mnt/boot
umount -R /mnt
reboot
_EOF_