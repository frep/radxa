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
export PATH=${PATH}:${tooldir}/gcc-arm-linux-gnueabihf-4.7/bin

today=$(date +"%Y_%m_%d")
partition=" "
offset=" "
size=" "

##########################################################################################################
# functions
##########################################################################################################


##########################################################################################################
# program
##########################################################################################################

if [[ $# -eq 0 ]] ; then
	echo "Please pass /path/to/nand-image"
	exit 0
fi

if [ ! -f $1 ]; then
	echo "no nand-image found at "$1". Please check path!"
fi

while true; do
        read -p "Is radxa connected in loader mode? [y]es, or [n]o, abort flashing!" yn
        case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * )     echo "connect radxa in loader mode and confirm with [y] or abort with [n]o!";;
        esac
done

sudo ${tooldir}/upgradeTool/upgrade_tool uf $1

exit
