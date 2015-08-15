#!/bin/bash

##########################################################################################################
# Paths and variables
##########################################################################################################

kernelDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
tempDir=$kernelDir/build.radxa.com/rabian/nightly/rock2_square/$1/rockdev/

targetDir=$kernelDir/rabian/$1/

radxaNightlyDir=http://build.radxa.com/rabian/nightly
radxaRock2Dir=$radxaNightlyDir/rock2_square

##########################################################################################################
# functions
##########################################################################################################

function getFiles()
{
	wget -r --no-parent --reject "index.html*" $radxaRock2Dir/$1/rockdev/package-file
	wget -r --no-parent --reject "index.html*" $radxaRock2Dir/$1/rockdev/parameter
	wget -r --no-parent --reject "index.html*" $radxaRock2Dir/$1/rockdev/boot/boot-linux.img
	wget -r --no-parent --reject "index.html*" $radxaRock2Dir/$1/rockdev/boot/resource.img
	wget -r --no-parent --reject "index.html*" $radxaRock2Dir/$1/rockdev/modules/lib
}

function copyFiles()
{
	cd $tempDir
	cp package-file $targetDir
	cp parameter $targetDir
	cp boot/resource.img $targetDir
	cp boot/boot-linux.img $targetDir
	cd modules/lib
	tar cvfz modules.tar.gz firmware/ modules/
	cp modules.tar.gz $targetDir
	cd $kernelDir
}

function cleanup()
{
	cd $kernelDir
	rm -rf build.radxa.com
}

##########################################################################################################
# program
##########################################################################################################

if [ "$#" -ne 1 ]; then
  echo "Usage: ./getRabianKernel.sh <nightly-build-date>"
  echo "e.g: ./getRabianKernel.sh 150815"
  exit 1
fi

mkdir $targetDir
getFiles $1
copyFiles
cleanup

exit
