#!/bin/bash

##########################################################################################################
# Paths and variables
##########################################################################################################

scriptdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${scriptdir}
cd ..
basedir=$(pwd)
cd ..
radxadir=$(pwd)
cd ${basedir}

# read config-file
source ${basedir}/build.cfg


##########################################################################################################
# functions
##########################################################################################################


##########################################################################################################
# program
##########################################################################################################

if [ ! -f ${rootfsdir}/${nandImageName}-${version}.img ]; then
	echo "no nand-image found at "${rootfsdir}". Create image with <createNandImage.sh>!"
	exit 0
fi

while true; do
        read -p "Is radxa connected in loader mode? [y]es, or [n]o, abort flashing!" yn
        case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * )     echo "connect radxa in loader mode and confirm with [y] or abort with [n]o!";;
        esac
done

sudo ${tooldir}/upgradeTool/upgrade_tool uf ${rootfsdir}/${nandImageName}-${version}.img

exit
