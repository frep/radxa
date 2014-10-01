#!/bin/bash

##########################################################################################################
# Paths and variables
##########################################################################################################

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${scriptdir}
cd ..
basedir=$(pwd)
kerneldir=${basedir}/kernel/ubuntuImage
imagedir=${basedir}/images
rootfsdir=${imagedir}/kali-$1
tooldir=${basedir}/tools
backupdir=${basedir}/backups

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

today=$(date +"%Y_%m_%d")
partition=" "
offset=" "
size=" "

##########################################################################################################
# functions
##########################################################################################################

function getPackTools {
        git clone https://github.com/frep/rockchip-pack-tools
}

function createNandImg {
	cd ${rootfsdir}
	getPackTools
	mkdir -p rockchip-pack-tools/Linux
	mv rock_rootfs-$1.img rockchip-pack-tools/Linux/rootfs.img
	cp ${kerneldir}/boot-linux.img rockchip-pack-tools/Linux/
	cd rockchip-pack-tools
	./mkupdate.sh
}

function cleanup {
	mv Linux/rootfs.img ../rock_rootfs-$1.img
	mv update.img ../update_kali-$1.img
	cd ..
	rm -rf rockchip-pack-tools
	rm -rf kali-armhf
	rm -rf kali-arm-build-scripts
}


##########################################################################################################
# program
##########################################################################################################

if [[ $# -eq 0 ]] ; then
	echo "Please pass version number, e.g. $0 1.0.1"
	exit 0
fi

if [ ! -d ${tooldir} ]; then
	echo "tools not found. Please run ./getTools.sh first"
fi

if [ ! -f ${kerneldir}/boot-linux.img ]; then
	echo "boot-linux.img not found. Please check variable kerneldir!"
fi

if [ ! -f ${kerneldir}/modules.tar.gz ]; then
	echo "modules and firmware archive: modules.tar.gz not found. Please check variable kerneldir!"
fi

# create the rootfs image
cd ${scriptdir}
./createKaliRootfs.sh $1 ${kerneldir}


createNandImg $1

cleanup $1

echo "The kali-nand-image is located at: "${rootfsdir}"/update_kali-"$1".img"

exit
