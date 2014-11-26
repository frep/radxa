#!/bin/bash

##########################################################################################################
# Paths and variables
##########################################################################################################

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${scriptdir}
cd ..
basedir=$(pwd)

# read config-file
source ${basedir}/build.cfg


##########################################################################################################
# program
##########################################################################################################

if [ ! -f ${bootImgDir}/modules.tar.gz ]; then
	echo "modules and firmware archive not found. Check <bootImgDir> in build.cfg!"
	exit 0
fi

cd ${basedir}
if [ ! -d ${imagedir} ]; then
	# image directory does not exist yet. Create it!
	mkdir images
fi

kalidir=${imagedir}/kali-${version}

# Package installations for various sections.
# This will build a minimal XFCE Kali system with the top 10 tools.
# This is the section to edit if you would like to add more packages.
# See http://www.kali.org/new/kali-linux-metapackages/ for meta packages you can
# use. You can also install packages, using just the package name, but keep in
# mind that not all packages work on ARM! If you specify one of those, the
# script will throw an error, but will still continue on, and create an unusable
# image, keep that in mind.

arm="abootimg cgpt fake-hwclock ntpdate vboot-utils vboot-kernel-utils uboot-mkimage"
base="kali-menu kali-defaults initramfs-tools"
desktop="xfce4 network-manager network-manager-gnome xserver-xorg-video-fbdev"
tools="passing-the-hash winexe aircrack-ng hydra john sqlmap wireshark libnfc-bin mfoc"
services="openssh-server apache2"
extras="iceweasel wpasupplicant"

export packages="${arm} ${base} ${desktop} ${tools} ${services} ${extras}"
export architecture="armhf"

# Set this to use an http proxy, like apt-cacher-ng, and uncomment further down
# to unset it.
#export http_proxy="http://localhost:3142/"

if [ ! -d ${kalidir} ]; then
        # image directory does not exist yet. Create it!
        mkdir -p ${kalidir}
fi

cd ${kalidir}

#Based on kali-arm-build-scripts/mini-x
echo "Download the kali-arm-build-scripts"
git clone https://github.com/offensive-security/kali-arm-build-scripts.git
cd kali-arm-build-scripts
./build-deps.sh

cd ${kalidir}

# Create the rootfs - not much to modify here, except maybe the hostname
debootstrap --foreign --arch $architecture kali kali-$architecture http://http.kali.org/kali

cp /usr/bin/qemu-arm-static kali-$architecture/usr/bin/

LANG=C chroot kali-$architecture /debootstrap/debootstrap --second-stage
cat > kali-$architecture/etc/apt/sources.list << "EOF"
deb http://http.kali.org/kali kali main contrib non-free
deb http://security.kali.org/kali-security kali/updates main contrib non-free
EOF

echo ${hostname} > kali-$architecture/etc/hostname

cat > kali-$architecture/etc/hosts << "EOF"
127.0.0.1       kali    localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

cat > kali-$architecture/etc/resolv.conf << "EOF"
nameserver 8.8.8.8
EOF

cat > kali-$architecture/etc/network/interfaces << "EOF"
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

export MALLOC_CHECK_=0 # workaround for LP: #520465
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

modprobe binfmt_misc
mount -t proc proc kali-$architecture/proc
mount -o bind /dev/ kali-$architecture/dev/
mount -o bind /dev/pts kali-$architecture/dev/pts

cat << "EOF" > kali-$architecture/debconf.set
console-common console-data/keymap/policy select Select keymap from full list
console-common console-data/keymap/full select en-latin1-nodeadkeys
EOF

cat > kali-$architecture/third-stage << "EOF"
#!/bin/bash
dpkg-divert --add --local --divert /usr/sbin/invoke-rc.d.chroot --rename /usr/sbin/invoke-rc.d
cp /bin/true /usr/sbin/invoke-rc.d
echo -e "#!/bin/sh\nexit 101" > /usr/sbin/policy-rc.d
chmod +x /usr/sbin/policy-rc.d

apt-get update
apt-get -y install locales-all

debconf-set-selections /debconf.set
rm -f /debconf.set
apt-get update
apt-get -y install git-core binutils ca-certificates initramfs-tools uboot-mkimage
apt-get -y install locales console-common less nano git
echo "root:${rootPw}" | chpasswd
sed -i -e 's/KERNEL\!=\"eth\*|/KERNEL\!=\"/' /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
apt-get --yes --force-yes install $packages

rm -f /usr/sbin/policy-rc.d
rm -f /usr/sbin/invoke-rc.d
dpkg-divert --remove --rename /usr/sbin/invoke-rc.d

rm -f /third-stage
EOF

chmod +x kali-$architecture/third-stage

LANG=C chroot kali-$architecture /third-stage

cat > kali-$architecture/cleanup << "EOF"
#!/bin/bash
rm -rf /root/.bash_history
apt-get update
apt-get clean
rm -f /0
rm -f /hs_err*
rm -f cleanup
rm -f /usr/bin/qemu*
EOF

chmod +x kali-$architecture/cleanup

echo "Autostart services"
update-rc.d ssh defaults
update-rc.d bluetooth defaults
update-rc.d apache2 defaults

# mtd-by-name link the mtdblock to name
echo "mtd by name fix"

cat > kali-$architecture/usr/local/bin/mtd-by-name.sh << "EOF"
#!/bin/sh -e
# radxa.com, thanks to naobsd
rm -rf /dev/block/mtd/by-name/
mkdir -p /dev/block/mtd/by-name
for i in `ls -d /sys/class/mtd/mtd*[0-9]`; do
name=`cat $i/name`
tmp="`echo $i | sed -e 's/mtd/mtdblock/g'`"
dev="`echo $tmp |sed -e 's/\/sys\/class\/mtdblock/\/dev/g'`"
ln -s $dev /dev/block/mtd/by-name/$name
done
EOF

chmod +x kali-$architecture/usr/local/bin/mtd-by-name.sh

cat > kali-$architecture/etc/rc.local << "EOF"
#!/bin/sh -e
#
# rc.local
#
# This script is executed at the end of each multiuser runlevel.
# Make sure that the script will "exit 0" on success or any other
# value on error.
#
# In order to enable or disable this script just change the execution
# bits.
#
# By default this script does nothing.

writeStartup()
{
        cat /etc/rc.local | sed 's@^startup=.*$@startup=\"'$1'\"@' > tmpFile
        mv tmpFile /etc/rc.local
        chmod +x /etc/rc.local
}

startup="firstBoot"
imagetype="nand"
autoStartX="false"
if [ ${imagetype} = "nand" ]; then
    /usr/local/bin/mtd-by-name.sh
fi

if [ ${startup} = "firstBoot" ]; then
        if [ ${imagetype} = "nand" ]; then
                resize2fs /dev/block/mtd/by-name/linuxroot;
                writeStartup "startupDone"
        else
                set +e
        	echo  "d\nn\np\n1\n49152\n\nw" | fdisk /dev/mmcblk0
		set -e
                writeStartup "secondBoot"
		shutdown -r now
        fi
        # log the first boot
        dmesg > /root/firstBoot.log
fi

if [ ${startup} = "secondBoot" ]; then
        resize2fs /dev/mmcblk0p1
        writeStartup "startupDone"
fi

if [ ${autoStartX} = "true" ]; then
# start X at boot
su -l root -c startx
fi

exit 0
EOF

chmod +x kali-$architecture/etc/rc.local

# add some repositories
echo "deb http://ftp.us.debian.org/debian testing main contrib non-free" >> kali-$architecture/etc/apt/sources.list
echo "deb-src http://ftp.us.debian.org/debian testing main contrib non-free" >> kali-$architecture/etc/apt/sources.list
echo "deb http://ftp.debian.org/debian/ jessie-updates main contrib non-free" >> kali-$architecture/etc/apt/sources.list
echo "deb-src http://ftp.debian.org/debian/ jessie-updates main contrib non-free" >> kali-$architecture/etc/apt/sources.list
echo "deb http://security.debian.org/ jessie/updates main contrib non-free" >> kali-$architecture/etc/apt/sources.list
echo "deb-src http://security.debian.org/ jessie/updates main contrib non-free" >> kali-$architecture/etc/apt/sources.list

cat > kali-$architecture/etc/apt/preferences.d/main.pref << "EOF"
Package: *
Pin: release n=kali
Pin-Priority: 350

Package: *
Pin: release n=kali-bleeding-edge
Pin-Priority: 300

Package: *
Pin: release n=jessie
Pin-Priority: 10
EOF

LANG=C chroot kali-$architecture /cleanup

#umount kali-$architecture/proc/sys/fs/binfmt_misc
umount kali-$architecture/dev/pts
umount kali-$architecture/dev/
umount kali-$architecture/proc

# Create the disk and partition it
echo "Creating rock_rootfs-${version}.img"
cd ${kalidir}
dd if=/dev/zero of=rock_rootfs-${version}.img bs=1M count=${nandImageSize}

#kernel use the label linuxroot to mount the rootfs as /
echo "Formatting rock_rootfs-${version}.img to ext4"
mkfs.ext4 -F -L linuxroot rock_rootfs-${version}.img
rootfs="rock_rootfs-${version}.img"

# Create the dirs for the partitions and mount them
echo "Mounting rootfs"
rootimg="${basedir}/root"
mkdir -p ${rootimg}
mount -o loop ${rootfs} ${rootimg}

echo "Rsyncing rootfs into image file"
rsync -HPavz -q ${kalidir}/kali-$architecture/ ${rootimg}

# Uncomment this if you use apt-cacher-ng otherwise git clones will fail.
#unset http_proxy

cd ${bootImgDir}
tar xvfz modules.tar.gz -C ${rootimg}/lib

if [ ${autoLogin} == "true" ]; then
# enable autologin
cd ${rootimg}/etc
cat inittab | sed 's@1:2345:respawn:/sbin/getty 38400 tty1@1:2345:respawn:/bin/login -f root tty1 </dev/tty1 >/dev/tty1 2>\&1@' > tempFile
mv tempFile inittab
fi

# Unmount partitions
cd ${basedir}
umount ${rootimg}

