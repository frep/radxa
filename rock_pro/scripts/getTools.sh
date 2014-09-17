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
	#export PATH=${PATH}:${basedir}/gcc-arm-linux-gnueabihf-4.7/bin
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


############################################################################
# To create the boot.img, the mkbootimg is needed
############################################################################
#wget http://dl.radxa.com/rock/tools/linux/mkbootimg
#apt-get -y install lib32stdc++6
#chmod +x mkbootimg

############################################################################
# Upgrade tool to flash parameter-linux
############################################################################
#mkdir upgradeTool
#cd upgradeTool
#wget http://dl.radxa.com/rock/tools/linux/Linux_Upgrade_Tool_v1.16.zip
#unzip Linux_Upgrade_Tool_v1.16.zip
#cp upgrade_tool ../
#cd ${tooldir}

############################################################################
# GUI-based tool to flash and backup partitions
############################################################################
#git clone https://github.com/linuxerwang/rkflashkit 
#cd rkflashkit
#./waf debian
#apt-get install python-gtk2
#dpkg -i rkflashkit_0.1.2_all.deb

############################################################################
# rockchip-pack-tools: Tools to create an update.img
############################################################################
#git clone https://github.com/radxa/rockchip-pack-tools.git

exit
