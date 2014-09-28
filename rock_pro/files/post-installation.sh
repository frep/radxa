#!/bin/bash

# set correct timezone
#dpkg-reconfigure tzdata

# install conky
#apt-get install conky
#cp .conkyrc /root/

# resize rootfs to fit the entire nand
#resize2fs /dev/block/mtd/by-name/linuxroot

# activate some alias commands
#cp .bashrc /root/

# enable autologin
cp inittab /etc/inittab

# auto startx
cp rc.local /etc/rc.local
