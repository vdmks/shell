#!/bin/bash
#
# root:111
# user:111
#
# /dev/sda1 200M boot
# /dev/sda2 4G swap
# /dev/sda3 10G root
# /dev/sda4 All available space (Max - 85G)
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

/dev/sda1 : start=        2048, size=      409600, type=83
/dev/sda2 : start=      411648, size=     8388608, type=82
/dev/sda3 : start=     8800256, size=     20971520, type=83
/dev/sda4 : start=     29771776, size=   178257920, type=83
_EOF_

	sfdisk /dev/sda < create.disks

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

	grub-install /dev/sda
	grub-mkconfig -o /boot/grub/grub.cfg

	sed -i 's/#Color/Color/' /etc/pacman.conf

	pacman -S bash-completion ttf-liberation ttf-droid moc screenfetch htop xterm xorg-server xorg-xinit xorg-server-utils mesa xf86-video-nouveau alsa-lib alsa-utils alsa-oss alsa-plugins xf86-input-synaptics virtualbox-guest-utils linux-headers --noconfirm

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
