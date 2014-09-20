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


##########################################################################################################
# Functions
##########################################################################################################

function getCrossCompiler {
	git clone https://github.com/offensive-security/gcc-arm-linux-gnueabihf-4.7
}

function generateInitrd {
	git clone https://github.com/frep/initrd
	make -C initrd
	mv initrd.img initrd/
}

function installMkbootimg {
	git clone https://github.com/frep/rockchip-mkbootimg
	cd rockchip-mkbootimg
	make
	sudo make install
	cd ..
}

function installRkflashtool {
	git clone https://github.com/frep/rkflashtool
	cd rkflashtool
	make
	cd ..
}

function getPackTools {
	git clone https://github.com/frep/rockchip-pack-tools
}

function getUpgradeTool {
	mkdir upgradeTool
	cd upgradeTool
	wget http://dl.radxa.com/rock/tools/linux/Linux_Upgrade_Tool_v1.16.zip
	unzip Linux_Upgrade_Tool_v1.16.zip
	cd ..
}

function getRkflashkit {
	git clone https://github.com/linuxerwang/rkflashkit
	cd rkflashkit
	./waf debian
	apt-get install python-gtk2
	dpkg -i rkflashkit_0.1.2_all.deb
	cd ..
}


##########################################################################################################
# program
##########################################################################################################

if [ ! -d ${tooldir} ]; then
	# tool directory does not exist yet. Create it!
	cd ${basedir}
	mkdir tools
fi

cd ${tooldir}

sudo apt-get install build-essential lzop libncurses5-dev libssl-dev lib32stdc++6 libusb-1.0

# get arm cross-compiler
if [ -d gcc-arm-linux-gnueabihf-4.7 ]; then
        while true; do
                read -p "Cross compiler directory already exists. Delete and [r]eimport or [s]kip ?" rs
                case $rs in
                [Rr]* ) rm -rf gcc-arm-linux-gnueabihf-4.7;
                        getCrossCompiler;
                        break;;
                [Ss]* ) break;;
                * )     echo "Please answer [r] or [s].";;
                esac
        done
else
	getCrossCompiler
fi

# generate initrd
if [ -d initrd ]; then
        while true; do
                read -p "initrd directory already exists. Delete and [r]eimport or [s]kip ?" rs
                case $rs in
                [Rr]* ) rm -rf initrd;
                        generateInitrd;
                        break;;
                [Ss]* ) break;;
                * )     echo "Please answer [r] or [s].";;
                esac
        done
else
        generateInitrd
fi

# get mkbootimg
if [ -d rockchip-mkbootimg ]; then
        while true; do
                read -p "rockchip-mkbootimg directory already exists. Delete and [r]eimport or [s]kip ?" rs
                case $rs in
                [Rr]* ) rm -rf rockchip-mkbootimg;
                        installMkbootimg;
                        break;;
                [Ss]* ) break;;
                * )     echo "Please answer [r] or [s].";;
                esac
        done
else
        installMkbootimg
fi

# install rkflashtool
if [ -d rkflashtool ]; then
        while true; do
                read -p "rkflashtool directory already exists. Delete and [r]eimport or [s]kip ?" rs
                case $rs in
                [Rr]* ) rm -rf rkflashtool;
                        installRkflashtool;
                        break;;
                [Ss]* ) break;;
                * )     echo "Please answer [r] or [s].";;
                esac
        done
else
        installRkflashtool
fi

# get rockchip-pack-tools
if [ -d rockchip-pack-tools ]; then
        while true; do
                read -p "Pack-tools directory already exists. Delete and [r]eimport or [s]kip ?" rs
                case $rs in
                [Rr]* ) rm -rf rockchip-pack-tools;
                        getPackTools;
                        break;;
                [Ss]* ) break;;
                * )     echo "Please answer [r] or [s].";;
                esac
        done
else
        getPackTools
fi

# get upgrade tool to flash parameter-linux
if [ -d upgradeTool ]; then
        while true; do
                read -p "upgrade-tool directory already exists. Delete and [r]eimport or [s]kip ?" rs
                case $rs in
                [Rr]* ) rm -rf upgradeTool;
                        getUpgradeTool;
                        break;;
                [Ss]* ) break;;
                * )     echo "Please answer [r] or [s].";;
                esac
        done
else
        getUpgradeTool
fi

# get rkflashkit (GUI-based tool to flash and backup partitions)
if [ -d rkflashkit ]; then
        while true; do
                read -p "rkflashkit directory already exists. Delete and [r]eimport or [s]kip ?" rs
                case $rs in
                [Rr]* ) rm -rf rkflashkit;
                        getRkflashkit;
                        break;;
                [Ss]* ) break;;
                * )     echo "Please answer [r] or [s].";;
                esac
        done
else
        getRkflashkit
fi

exit
