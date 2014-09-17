#!/bin/bash

##########################################################################################################
# Paths and variables
##########################################################################################################

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${scriptdir}
cd ..
basedir=$(pwd)
kerneldir=${basedir}/kernel_rockchip


##########################################################################################################
# Functions
##########################################################################################################

function getKernel {
	cd ${basedir}
	git clone -b radxa/stable-3.0 https://github.com/frep/kernel_rockchip.git
	cd ${kerneldir}
	echo "Patching kernel"
	wget http://patches.aircrack-ng.org/mac80211.compat08082009.wl_frag+ack_v1.patch -O mac80211.patch
	patch -p1 --no-backup-if-mismatch < mac80211.patch
	touch .scmversion
}


##########################################################################################################
# program
##########################################################################################################

#check, if kernel-directory already exists
if [ -d ${kerneldir} ]; then
	while true; do
		read -p "Kernel directory already exists. Delete and [r]eimport or [s]kip ?" rs
		case $rs in
		[Rr]* )	rm -rf ${kerneldir};
			getKernel;
			exit;;
		[Ss]* )	exit;;
		* )	echo "Please answer [r] or [s].";;
		esac
	done
fi

getKernel

exit
