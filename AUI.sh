#!/bin/bash

# Arch UEFI Install (AUI)
# ---------------------------------------------------------------
# Author    : Chaotic_Guru                                       |
# Github    : https://github.com/Chaotic-Lab                     |
#	      https://github.com/ChaoticHackingNetwork           |
# Discord   : https://discord.gg/nv445EX (ChaoticHackingNetwork) |
# ---------------------------------------------------------------

echo -e "\033[33;36mChaoticGuru's Arch Linux UEFI Installer!!!\033[0m"

#Network Connections
read -p 'Are you connected to the Internet? [y/N]: ' connected
if ! [ $connected = 'y' ] && ! [ $connected = 'Y' ]
then
	echo "Please connect to the Internet to continue..."
	exit
fi

#Mounting the File System Warning!
echo "This script will create and format the following partitions:"
echo
echo "--------- /dev/sda1 - 512M will be mounted as /boot/EFI ------------"
echo "--------- /dev/sda2 - 16G of space will be mounted as SWAP ---------"
echo "--------- /dev/sda3 - rest of space will be mounted as / -----------"
echo
echo "Exit now if this is not correct!!!"
echo
read -p 'Continue? [y/N]: ' partition
if ! [ $partition = 'y' ] && ! [ $partition = 'Y' ]
then
	echo "Please edit the script to continue..."
	exit
fi

#Create partitions thru fdisk...
#https://superuser.com/a/984637
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk /dev/sda # CHANGE THIS IF NEEDED!!!
	o # Clear the in-memory partition table
	n # New partition
	p # Primary partition
	1 # First partition
		# EFI - start at beginning of disk
	+512M # /boot/EFI
	n
	p
	2
		# SWAP - start immediately after preceding partition
	+16G
	n 
	p
	3
		# ROOT, start immediately after preceding partition
		# default, use rest of disk space
	p # print the in-memory table
	w # write changes to disk
	q # quit
		
EOF

#Format partitions
mkfs.ext4 /dev/sda3
mkfs.fat -F32 /dev/sda1

#Mount partitions
mount /dev/sda3 /mnt

#Create swap space
mkswap /dev/sda2
swapon /dev/sda2

#Display new tables and confirm
lsblk
echo "/dev/sda1 - /boot/EFI will be mounted in the next script"
echo "Are the mount points correct?"
read -p 'Continue? [Y/n]' confirm
if ! [ $confirm = 'y' ] && ! [ $confirm = 'Y' ]
then 
	echo "Please edit the script to continue..."
	exit
fi

#Initialize Pacman
pacman-key --init
pacman-key --populate archlinux

#Install base system
pacstrap /mnt base base-devel linux linux-firmware

#Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab

#Finish last minute setup
echo 0 > /proc/sys/kernel/hung_task_timeout_secs
wget https://raw.githubusercontent.com/ChaoticHackingNetwork/Scripts/master/ACUI.sh
mv ACUI.sh /mnt
echo "The next script (ACBI.sh) has been moved to your new root directory..."
echo "Run the following commands to finish setup..."
echo 
echo "	[1] arch-chroot /mnt /bin/bash"
echo "	[2] chmod +x ACUI.sh"
echo "  [3] ./ACUI.sh"

exit
