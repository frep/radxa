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

#install java
#mkdir -p -v /opt/java
#tar xvzf jdk-8u6-linux-arm-vfp-hflt.tar.gz -C /opt/java
#update-alternatives --install "/usr/bin/java" "java" "/opt/java/jdk1.8.0_06/bin/java" 1
#update-alternatives --set java /opt/java/jdk1.8.0_06/bin/java
#echo "JAVA_HOME=\"/opt/java/jdk1.8.0_06\"" >> /etc/enviroment
#echo "" >> /root/.bashrc
#echo "export JAVA_HOME=\"/opt/java/jdk1.8.0\"" >> /root/.bashrc
#echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> /root/.bashrc

#install arduino
#apt-get install arduino -y
#mkdir -p /lib/modules/3.0.36+/kernel/drivers/usb/class
#cp cdc-acm.ko /lib/modules/3.0.36+/kernel/drivers/usb/class/
#depmod -a
#echo "cdc-acm" >> /etc/modules

#fix wireshark error
#cp -f init.lua /usr/share/wireshark/init.lua
