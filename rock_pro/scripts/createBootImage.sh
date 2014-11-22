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
# Functions
##########################################################################################################
function buildKernelAndModules {
	cd ${kerneldir}
	make -j8
	mkdir modules
   	make INSTALL_MOD_PATH=./modules modules modules_install
}

function generateInitramfs {
	cd ${kerneldir}
	git clone https://github.com/radxa/initrd.git
	make -C initrd
}

function buildBootImg {
	# Create boot-linux.img
	mkbootimg --kernel ${kerneldir}/arch/arm/boot/Image --ramdisk ${kerneldir}/initrd.img -o boot-linux.img
}

function createModulesArchive {
	cd ${kerneldir}/modules/lib
	tar cvfz modules.tar.gz firmware/ modules/
}

function moveData {
	cp ${kerneldir}/boot-linux.img ${basedir}/kernel/currentBuild/
	mv ${kerneldir}/modules/lib/modules.tar.gz ${basedir}/kernel/currentBuild/
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

if [ -f boot-linux.img ]; then
        while true; do
                read -p "Boot-image already created. [r]ecreate or [s]kip ?" rs
                case $rs in
                [Rr]* ) rm -rf modules;
			rm boot-linux.img;
			rm -rf initrd;
			rm initrd.img;
			rm arch/arm/boot/Image;
			rm arch/arm/boot/zImage;
                        break;;
                [Ss]* ) exit;;
                * )     echo "Please answer [r] or [s].";;
                esac
        done
fi


buildKernelAndModules

generateInitramfs

buildBootImg

createModulesArchive

moveData

exit
