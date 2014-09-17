#!/bin/bash

##########################################################################################################
# Paths and variables
##########################################################################################################

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${scriptdir}
cd ..
basedir=$(pwd)
kerneldir=${basedir}/kernel_rockchip
tooldir=${basedir}/tools

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-
export PATH=${PATH}:${tooldir}/gcc-arm-linux-gnueabihf-4.7/bin
export PATH=${PATH}:${tooldir}/rockchip-mkbootimg

##########################################################################################################
# Functions
##########################################################################################################
function buildKernelAndModules {
	make -j8
	mkdir modules
	export INSTALL_MOD_PATH=./modules
	make modules
	make modules_install
}


##########################################################################################################
# program
##########################################################################################################

if [ ! -d ${kerneldir} ]; then
        echo "Kernel sources are needed to build the kernel. Run <getKernelSource.sh> and <createKernelConfig.sh>!"
        exit
fi

cd ${kerneldir}

if [ ! -f .config ]; then
        echo "No kernel config found. Run <createKernelConfig.sh> first!"
        exit
fi

buildKernelAndModules

# Create boot.img
mkbootimg --kernel ${kerneldir}/arch/arm/boot/Image --ramdisk ${tooldir}/initrd/initrd.img -o boot.img


exit
