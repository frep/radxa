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

partition=" "
offset=" "
size=" "

##########################################################################################################
# functions
##########################################################################################################

function getParameterFile {
	cd ${tooldir}/rkflashtool
	# if there is already a backupfile, delete old one first!
	rm -f ${backupdir}/parameter_${today}
	./rkflashtool p > ${backupdir}/parameter_${today}
}

function readPartitionData {
	partitioninfo=$(cat ${backupdir}/parameter_${today} | grep -o -e "0x[0-9a-fA-F]\{8\}\@0x[0-9a-fA-F]\{8\}("$1")" -e "-\@0x[0-9a-fA-F]\{8\}("$1")")
	offset=$(echo "${partitioninfo}" | grep -o "0x[0-9a-fA-F]\{8\}(" | grep -o "0x[0-9a-fA-F]\{8\}")
	size=$(echo "${partitioninfo}" | grep -o ".*\@" | grep -o -e "-" -e "0x[0-9a-fA-F]\{8\}")
	if [ "${size}" == "-" ]; then
		# 0x1000000 is the number of 512bytes-blocks of a 8-GB memory
        	#sizeAsInt=$((0x1000000 - ${offset}))
        	#size=$(printf 0x%X ${sizeAsInt})
		# so much for the math. startup tells me a size of 0xEF0000
		size=0xEF0000
	fi
	echo "Partition "$1": offset = ${offset}, size = ${size}"
}

function backupPartition {
	cd ${tooldir}/rkflashtool
	backupname=${partition}_${today}.img
	# if there is already a backupfile, delete old one first!
	rm -f ${backupname}
	rm -f ${backupname}.xz
	echo "Create backup: ${backupname}"
	./rkflashtool r ${offset} ${size} > ${backupdir}/${backupname}
}

function compressPartition {
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
}


##########################################################################################################
# program
##########################################################################################################

if [ ! -d ${backupdir} ]; then
	# root backup directory does not exist yet. Create it!
	cd ${basedir}
	mkdir backups
fi

# check, if rkflashtool is available
if [ ! -f ${tooldir}/rkflashtool/rkflashtool ]; then
	echo "rkflashtool not found! run getTools.sh first!"
	exit
fi

if [ ! -d ${backupdir}/${today} ]; then
	# actual backup directory does not exist yet. Create it!
	cd ${backupdir}
	mkdir ${today}
fi
backupdir=${backupdir}/${today}

while true; do
	read -p "Is radxa connected in loader mode? [y]es, or [n]o, abort backup!" yn
	case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * )     echo "connect radxa in loader mode and confirm with [y] or abort with [n]o!";;
        esac
done

while true; do
        read -p "Back up which partition? [b]oot, [l]inuxroot or [n]one of them!" bln
        case $bln in
        [Bb]* ) partition="boot";
		break;;
        [Ll]* ) partition="linuxroot";
		break;;
	[Nn]* ) exit;;
	* )     echo "Choose [b]oot [l]inuxroot or [n] to exit";;
	esac
done

getParameterFile

readPartitionData ${partition}

backupPartition

compressPartition

exit
