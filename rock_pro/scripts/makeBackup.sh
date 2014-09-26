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
backupdir=${basedir}/backups

export ARCH=arm
export CROSS_COMPILE=arm-linux-gnueabihf-

today=$(date +"%Y_%m_%d")

##########################################################################################################
# program
##########################################################################################################

if [ ! -d ${backupdir} ]; then
	# backup directory does not exist yet. Create it!
	cd ${basedir}
	mkdir backups
fi

# check, if rkflashtool is available
if [ ! -f ${tooldir}/rkflashtool/rkflashtool ]; then
	echo "rkflashtool not found! run getTools.sh first!"
	exit
fi

cd ${backupdir}

while true; do
	read -p "Is radxa connected in loader mode? [y]es, let's go, or [n]o, abort backup!" yn
      	case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * )     echo "connect radxa in loader mode and confirm with [y] or abort with [n]o!";;
        esac
done

# TODO: Read offset and size of partitions out of the device

while true; do
        read -p "Back up which partition? [b]oot, [l]inuxroot, [n]one of them!" bln
        case $bln in
        [Bb]* ) partition="boot";
		offset=0x2000;
		size=0x8000;
		break;;
        [Ll]* ) partition="linuxroot";
		offset=0xA000;
		size=0xFF6000;
		break;;
	[Nn]* ) exit;;
        * )     echo "Choose [b]oot, [l]inuxroot, or [n] to exit";;
        esac
done

cd ${tooldir}/rkflashtool
backupname=${partition}_${today}.img
echo "Create backup: ${backupname}"
./rkflashtool r ${offset} ${size} > ${backupdir}/${backupname}

cd ${backupdir}
# compress the backup for the linuxroot partition
if [ "${partition}" == "linuxroot" ]; then
echo "Compress backup"
pixz ${backupname} ${backupname}.xz
sha1sum ${backupname}.xz > ${backupname}.xz.sha1sum

while true; do
        read -p "Keep the uncompressed backup? [k]eep or [d]elete" kd
        case $kd in
        [Kk]* ) break;;
        [Dd]* ) rm ${backupname};
		break;;
        * )     echo "Choose [k]eep or [d]elete";;
        esac
done
fi

exit
