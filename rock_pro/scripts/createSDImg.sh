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
	cd ${rootfsdir}
	dd if=/dev/zero of=${sdImageName}-${version}.img bs=1M count=${sdImageSize}
}

function copyBootloader {
	cd ${rootfsdir}
	dd if=${bootloaderdir}/sdboot_rk3188.img of=${sdImageName}-${version}.img conv=notrunc
}

function createParameterImg {
	cd ${rootfsdir}
	rkcrc -p ${parameterdir}/parameter_linux_sd parameter.img
}

function copyParameter {
	cd ${rootfsdir}
	createParameterImg
	dd if=parameter.img of=${sdImageName}-${version}.img conv=notrunc seek=$((0x2000))
	rm parameter.img
}

function copyKernel {
	cd ${rootfsdir}
	dd if=${bootImgDir}/boot-linux.img of=${sdImageName}-${version}.img conv=notrunc seek=$((0x2000+0x2000))
}

function copyRootfs {
	cd ${rootfsdir}
	dd if=rock_rootfs-${version}.img of=${sdImageName}-${version}.img conv=notrunc seek=$((0x2000+0xA000))
}

function partitionSDImage {
	cd ${rootfsdir}
	# still to do !!!!!
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

# create the rootfs image
cd ${scriptdir}
./createKaliRootfs.sh

createSDImage
copyBootloader
copyParameter
copyKernel
copyRootfs
partitionSDImage

echo "The kali-sdcard-image is located at: "${rootfsdir}"/"${sdImageName}"-"${version}".img"

exit
