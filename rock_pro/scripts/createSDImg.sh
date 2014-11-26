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
# functions
##########################################################################################################

function setAutoStartX {
        cd ${rootfsdir}
        mkdir mp
        mount -o loop rock_rootfs-${version}.img mp
	cat mp/etc/rc.local | sed 's@^autoStartX=.*$@autoStartX=\"'${autoStartX}'\"@' > tmpFile
        mv tmpFile mp/etc/rc.local
        chmod +x mp/etc/rc.local
	sleep 10
        umount mp
        rmdir mp
}

function createSDImage {
	echo "create raw sd-image"
	cd ${rootfsdir}
	dd if=/dev/zero of=${sdImageName}-${version}.img bs=1M count=${sdImageSize}
}

function copyBootloader {
	echo "copy bootloader to sd-image"
	cd ${rootfsdir}
	dd if=${bootloaderdir}/sdboot_rk3188.img of=${sdImageName}-${version}.img conv=notrunc
}

function createParameterImg {
	cd ${rootfsdir}
	rkcrc -p ${parameterdir}/parameter_linux_sd parameter.img
}

function copyParameter {
	echo "copy parameter.img to sd-image"
	cd ${rootfsdir}
	createParameterImg
	dd if=parameter.img of=${sdImageName}-${version}.img conv=notrunc seek=$((0x2000))
	rm parameter.img
}

function copyKernel {
	echo "copy kernel to sd-image"
	cd ${rootfsdir}
	dd if=${bootImgDir}/boot-linux.img of=${sdImageName}-${version}.img conv=notrunc seek=$((0x2000+0x2000))
}

function prepareRootfsToSD {
	cd ${rootfsdir}
	mkdir mp
	mount -o loop rock_rootfs-${version}.img mp
	cat mp/etc/rc.local | sed 's@imagetype="nand"@imagetype="sd"@' > tmpFile
	mv tmpFile mp/etc/rc.local
	chmod +x mp/etc/rc.local
	sleep 10
	umount mp
	rmdir mp
}

function copyRootfs {
	echo "copy rootfs to sd-image"
	cd ${rootfsdir}
	dd if=rock_rootfs-${version}.img of=${sdImageName}-${version}.img conv=notrunc seek=$((0x2000+0xA000))
}

function restoreRootfsToNand {
        cd ${rootfsdir}
        mkdir mp
        mount -o loop rock_rootfs-${version}.img mp
        cat mp/etc/rc.local | sed 's@imagetype="sd"@imagetype="nand"@' > tmpFile
        mv tmpFile mp/etc/rc.local
        chmod +x mp/etc/rc.local
	sleep 10
        umount mp
        rmdir mp
}

function partitionSDImage {
	cd ${rootfsdir}
	echo "partition image to make it bootable"
	echo -e "n\np\n1\n49152\n\nw" | fdisk ${sdImageName}-${version}.img
}

function cleanup {
        cd ${rootfsdir}
        rm -rf kali-armhf
        rm -rf kali-arm-build-scripts
}


##########################################################################################################
# program
##########################################################################################################

if [ ! -d ${tooldir} ]; then
	echo "tools not found. Please run ./getTools.sh first"
	exit 0
fi

if [ ! -f ${bootImgDir}/boot-linux.img ]; then
	echo "boot-linux.img not found. Please check <bootImgDir> in build.cfg!"
	exit 0
fi

if [ ! -f ${bootImgDir}/modules.tar.gz ]; then
	echo "modules and firmware archive: modules.tar.gz not found. Please check <bootImgDir> in build.cfg!"
	exit 0
fi

if [ ! -d ${rootfsdir} ]; then
        # image directory does not exist yet. Create it!
        mkdir ${rootfsdir}
fi

# create the rootfs image, if it doesn't exist yet
if [ ! -f ${rootfsdir}/rock_rootfs-${version}.img ]; then
	cd ${scriptdir}
	./createKaliRootfs.sh
	setAutoStartX
	cleanup
fi

createSDImage
copyBootloader
copyParameter
copyKernel
prepareRootfsToSD
copyRootfs
restoreRootfsToNand
partitionSDImage

echo "The kali-sdcard-image is located at: "${rootfsdir}"/"${sdImageName}"-"${version}".img"

exit
