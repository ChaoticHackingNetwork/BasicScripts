#!/bin/bash

# Arch Chroot UEFI Install (ACUI)
# ---------------------------------------------------------------
# Author    : Chaotic_Guru                                       |
# Github    : https://github.com/Chaotic-Lab                     |
#	          https://github.com/ChaoticHackingNetwork           |
# Discord   : https://discord.gg/nv445EX (ChaoticHackingNetwork) |
# ---------------------------------------------------------------

# Set locale to en_US.UTF-8 UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

#Set time & clock
timedatectl set-ntp true
hwclock --systohc --utc

#Change localtime *Note this script has it set too Chicago*
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime #CHANGE THIS TO YOUR TIMEZONE

#Initialize Pacman
pacman-key --init
pacman-key --populate archlinux
#pacman-key --refresh-keys

#Install some needed packages
pacman -Syyu
pacman -S vi vim nano net-tools perl go ruby dhcpcd mlocate dnsutils zip ntfs-3g dialog wpa_supplicant sudo man-db usbutils vlc firefox chromium flashplugin aria2 python3 git wget curl grub netctl neofetch os-prober reflector rsync tar p7zip alsa-utils alsa dosfstools mtools efibootmgr libguestfs xf86-video-fbdev --noconfirm

#Set root password
echo -e "\033[33;36mPlease set ROOT password!!!\033[0m"
passwd

#Create a new user
read -p "Enter a new Username: " username
echo "Welcome to your new system $username!"
useradd -mg users -G wheel,power,storage,uucp,network -s /bin/bash $username
echo -e "\033[33;36mPlease set your password now!!!\033[0m"
passwd $username
perl -i -pe 's/# (%wheel ALL=\(ALL\) ALL)/$1/' /etc/sudoers

#Install MATE Desktop env and LightDM
pacman -S mate mate-extra xorg xorg-xinit xorg-server lightdm xorg-xrandr lightdm-gtk-greeter --noconfirm
systemctl enable lightdm

#Install bootloader
mkdir /boot/EFI
mount /dev/sda1 /boot/EFI
grub-install --target=x86_64-efi --bootloader-id=ARCH_UEFI --recheck
grub-mkconfig -o /boot/grub/grub.cfg

#Install BlackArch Mirror
wget https://blackarch.org/strap.sh
chmod +x strap.sh
./strap.sh

#Successfully Installed
neofetch
echo "Arch Linux UEFI base has been successfully installed on your system..."
echo "A reboot should now take place"
echo "Run the following commands to reboot properly!"
echo
echo "  [1]: exit "
echo "  [2]: umount -a "
echo "  [3]: telinit 6 "

exit
