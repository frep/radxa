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

function copyRootfs {
	echo "copy rootfs to sd-image"
	cd ${rootfsdir}
	dd if=rock_rootfs-${version}.img of=${sdImageName}-${version}.img conv=notrunc seek=$((0x2000+0xA000))
}

function partitionSDImage {
	cd ${rootfsdir}
	echo "sd-image still needs to be partitioned"
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
fi

createSDImage
copyBootloader
copyParameter
copyKernel
copyRootfs
partitionSDImage

echo "The kali-sdcard-image is located at: "${rootfsdir}"/"${sdImageName}"-"${version}".img"

exit
