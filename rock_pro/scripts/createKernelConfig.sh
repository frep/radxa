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
# Functions
##########################################################################################################

function createConfig {
	make radxa_rock_pro_linux_defconfig
}

function modifyConfig {
	make menuconfig
}

function createAndModify {
	createConfig
        while true; do
                read -p "Kernel config created. [m]odify or [s]kip ?" ms
                case $ms in
                [Mm]* ) modifyConfig;
                        exit;;
                [Ss]* ) exit;;
                * )     echo "Please answer [m] or [s].";;
                esac
        done
}

##########################################################################################################
# program
##########################################################################################################

if [ ! -d ${kerneldir} ]; then
	echo "Kernel sources are needed to create kernel config. Run <getKernelSource.sh> first!"
	exit
fi

cd ${kerneldir}

if [ -f .config ]; then
        while true; do
                read -p "Kernel config already exists. Delete and [r]ecreate or [s]kip ?" rs
                case $rs in
                [Rr]* ) rm .config;
                        createAndModify;
                        exit;;
                [Ss]* ) exit;;
                * )     echo "Please answer [r] or [s].";;
                esac
        done
fi

createAndModify

exit
