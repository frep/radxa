#!/bin/bash

##########################################################################################################
# Paths and variables
##########################################################################################################

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${scriptdir}
cd ..
basedir=$(pwd)
cd ..
radxadir=$(pwd)
cd ${basedir}

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

arm="abootimg cgpt fake-hwclock ntpdate u-boot-tools vboot-utils vboot-kernel-utils"
base="e2fsprogs initramfs-tools kali-defaults kali-menu parted sudo usbutils"
desktop="fonts-croscore fonts-crosextra-caladea fonts-crosextra-carlito gnome-theme-kali gtk3-engines-xfce kali-desktop-xfce kali-root-login lightdm network-manager network-manager-gnome xfce4 xserver-xorg-video-fbdev"
tools="aircrack-ng ethtool hydra john libnfc-bin mfoc nmap passing-the-hash sqlmap usbutils winexe wireshark"
services="apache2 openssh-server"
extras="iceweasel xfce4-terminal wpasupplicant"

export packages="${arm} ${base} ${desktop} ${tools} ${services} ${extras}"
export architecture="armhf"

# If you have your own preferred mirrors, set them here.
# You may want to leave security.kali.org alone, but if you trust your local
# mirror, feel free to change this as well.
# After generating the rootfs, we set the sources.list to the default settings.
mirror=repo.kali.org
security=security.kali.org

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

# create the rootfs - not much to modify here, except maybe the hostname.
debootstrap --foreign --arch $architecture sana kali-$architecture http://$mirror/kali

cp /usr/bin/qemu-arm-static kali-$architecture/usr/bin/

LANG=C chroot kali-$architecture /debootstrap/debootstrap --second-stage
cat << EOF > kali-$architecture/etc/apt/sources.list
deb http://$mirror/kali sana main contrib non-free
deb http://$security/kali-security sana/updates main contrib non-free
EOF

# Set hostname
echo ${hostname} > kali-$architecture/etc/hostname

# So X doesn't complain, we add kali to hosts
cat << EOF > kali-$architecture/etc/hosts
127.0.0.1       kali    localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters
EOF

cat << EOF > kali-$architecture/etc/network/interfaces
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet dhcp
EOF

cat << EOF > kali-$architecture/etc/resolv.conf
nameserver 8.8.8.8
EOF

export MALLOC_CHECK_=0 # workaround for LP: #520465
export LC_ALL=C
export DEBIAN_FRONTEND=noninteractive

modprobe binfmt_misc
mount -t proc proc kali-$architecture/proc
mount -o bind /dev/ kali-$architecture/dev/
mount -o bind /dev/pts kali-$architecture/dev/pts

cat << EOF > kali-$architecture/debconf.set
console-common console-data/keymap/policy select Select keymap from full list
console-common console-data/keymap/full select en-latin1-nodeadkeys
EOF

cat << EOF > kali-$architecture/third-stage
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
apt-get -y install git-core binutils ca-certificates initramfs-tools u-boot-tools
apt-get -y install locales console-common less nano git
echo "root:toor" | chpasswd
sed -i -e 's/KERNEL\!=\"eth\*|/KERNEL\!=\"/' /lib/udev/rules.d/75-persistent-net-generator.rules
rm -f /etc/udev/rules.d/70-persistent-net.rules
export DEBIAN_FRONTEND=noninteractive
apt-get --yes --force-yes install $packages
apt-get --yes --force-yes dist-upgrade
apt-get --yes --force-yes autoremove

# Because copying in authorized_keys is hard for people to do, let's make the
# image insecure and enable root login with a password.

echo "Making the image insecure"
sed -i -e 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
update-rc.d ssh enable

rm -f /usr/sbin/policy-rc.d
rm -f /usr/sbin/invoke-rc.d
dpkg-divert --remove --rename /usr/sbin/invoke-rc.d

rm -f /third-stage
EOF

chmod +x kali-$architecture/third-stage

LANG=C chroot kali-$architecture /third-stage

cat << EOF > kali-$architecture/cleanup
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
LANG=C chroot kali-$architecture /cleanup

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

