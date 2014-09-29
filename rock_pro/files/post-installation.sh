#!/bin/bash

# set correct timezone
#dpkg-reconfigure tzdata

# install conky
#apt-get install conky
#cp .conkyrc /root/

# resize rootfs to fit the entire nand
#resize2fs /dev/block/mtd/by-name/linuxroot

# activate some alias commands
#cp -f .bashrc /root/

# enable autologin
#cp -f inittab /etc/inittab

# auto startx
#cp rc.local /etc/rc.local

# change xterm colors
#cp .Xdefaults /root/

# start conky at startx
#cp launchAtStartx.sh /root/
#cp launchAtStartx.desktop /root/.config/autostart/

#install chromium
#cp -f sources.list /etc/apt/sources.list
#cp main.pref /etc/apt/preferences.d/
#apt-get update
#apt-get install libc6  -t testing -y
#apt-get install libnspr4 libnss3 libxss1 -y
#dpkg -i chromium/chromium-browser_37.0.2062.120-0ubuntu0.12.04.1~pkg917_armhf.deb chromium/chromium-codecs-ffmpeg-extra_37.0.2062.120-0ubuntu0.12.04.1~pkg917_armhf.deb
#tar xvfz chromium/PepperFlash-12.0.0.77-armv7h.tar.gz -C /usr/lib
#cp -f chromium/default /etc/chromium-browser/default
