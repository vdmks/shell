#!/bin/bash
#
# root:111
# user:111
#
# /dev/sda1 200M
# /dev/sda2 4G
# /dev/sda3 All available space
#
# Install:
# 1) wget https://github.com/vdmks/shell/tarball/master -O - | tar xz 
# 2) cd <dir>
# 3) chmod +x arch-base-install.sh
# 4) ./arch-base-install.sh
#

ischroot=0

if [ $ischroot -eq 0 ]
then

cat << _EOF_ > create.disks
label: dos
label-id: 0xbe58cb3b
device: /dev/sda
unit: sectors

/dev/sda1 : start=        2048, size=      409600, type=83, bootable
/dev/sda2 : start=      411648, size=     8388608, type=82
/dev/sda3 : start=     8800256, size=   200914911, type=83
_EOF_

	sfdisk /dev/sda < create.disks

	mkfs.ext2 /dev/sda1
	mkfs.ext4 /dev/sda3
	mkswap /dev/sda2

	mount /dev/sda3 /mnt
	mkdir /mnt/boot
	mkdir /mnt/home
	mount /dev/sda1 /mnt/boot
	swapon /dev/sda2

	pacstrap /mnt base base-devel --noconfirm

	genfstab -p /mnt >> /mnt/etc/fstab

	sed -i 's/ischroot=0/ischroot=1/' ./arch-base-install.sh
	cp ./arch-base-install.sh /mnt/arch-base-install.sh

	arch-chroot /mnt /bin/bash -x << _EOF_
sh /arch-base-install.sh
_EOF_

fi

if [ $ischroot -eq 1 ]
then

	echo arch > /etc/hostname

	ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime

	sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen

	echo LANG=en_US.UTF-8 > /etc/locale.conf

	locale-gen
	
	pacman -S vim sudo grub-bios --noconfirm
	
	useradd -m -g users -G wheel,video -s /bin/bash user
	
	sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/' /etc/sudoers
	sed -i 's/# %wheel ALL=(ALL) NOPASSWD: ALL/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

	grub-install /dev/sda
	grub-mkconfig -o /boot/grub/grub.cfg

	sed -i 's/#Color/Color/' /etc/pacman.conf

	pacman -S bash-completion ttf-liberation ttf-droid screenfetch htop xorg-server xorg-xinit xorg-utils xorg-server-utils mesa xf86-video-nouveau alsa-lib alsa-utils alsa-oss alsa-plugins xorg-twm xterm xorg-xclock xf86-input-synaptics virtualbox-guest-utils linux-headers --noconfirm

	modprobe -a vboxguest vboxsf vboxvideo

	cp /etc/X11/xinit/xinitrc /home/user/.xinitrc
	echo -e "\nvboxguest\nvboxsf\nvboxvideo" >> /home/user/.xinitrc

	sed -i 's/#!\/bin\/sh/#!\/bin\/sh\n\/usr\/bin\/VBoxClient-all/' /home/user/.xinitrc

	# pacman -S lxde --noconfirm

	systemctl enable dhcpcd.service

	# sudo pacman -S chromium screenfetch unzip unrar p7zip pinta shutter evince vlc deadbeef truecrypt --noconfirm
fi

arch-chroot /mnt /bin/bash -x << _EOF_
passwd
111
111
_EOF_

arch-chroot /mnt /bin/bash -x << _EOF_
passwd user
111
111
_EOF_

umount -R /mnt/boot
umount -R /mnt
reboot
