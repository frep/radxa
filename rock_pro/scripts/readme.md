Precondition:
=============
These scripts are based on the [Kali-ARM-Build-Scripts](https://github.com/offensive-security/kali-arm-build-scripts).
As you can read there: *These scripts have been tested on a Kali Linux 32 and 64 bit installations only, after making sure that all the dependencies have been installed.*
So you should run these scripts on a kali-linux as root, otherwise you won't get happy.

**Important:**    
To check, if all the required packages are installed on your build-enviroment, do the following steps:

`git clone https://github.com/offensive-security/kali-arm-build-scripts`     
`./build-deps.sh`     

If the script is happy, you should be fine!!

Steps to create a nand-kali-image:
==================================
1. get the needed tools (if not done yet): 
   `./rock_pro/scripts/getTools.sh`

2. Optional: check general settings in build-configuration:
   `nano /rock_pro/build.cfg`

3. create a Nand-image for radxa rock pro:
   `./createNandImg.sh`

Flash the image:
----------------
Simply run: `./rock_pro/scripts/flashNandImg.sh`

Missing steps:
--------------
- [ ] create self-compiled kernel and use it for image
- [x] Create image for sd-card

Steps to create a sd-card-kali-image:
=====================================
1. get the needed tools (if not done yet):
   `./rock_pro/scripts/getTools.sh`

2. Optional: check general settings in build-configuration:
   `nano /rock_pro/build.cfg`

3. create a sd-image for radxa rock pro:
   `./rock_pro/scripts/createSDImg.sh`

Write the sd-card:
------------------
Insert and unmount your sd-card. Copy image: `sudo dd if=/path/to/image of=/<sdcard>`

General notes:
--------------
* The script to create a rootfs is based on the work of [manu7irl](https://github.com/manu7irl).
* The image is modified in such a way that after bootup there is an auto-login as root and startx gets executed due to the fact, that at the moment after bootup, there is no output visible, which is not useable.
* If a sd-image is used, at first boot, the partition table of the sd-card is changed. After that, a reboot is performed, to apply these changes. At second boot, the actual resize of the rootfs is performed. So don't mind, that at first bootup, radxa restarts itself and take a while to boot. This is only the first time!

Getting started:
================
Now, the resize of the flash is automatically done at first boot. Also, the first boot is logged into the file /root/firstBoot.log. Feel free to
delete it, if you don't need it. As before, you can download this workspace and modify the script: `post-installation.sh`. Uncomment all the steps, you want to be executed. Then run it!

Missing steps:
--------------
- [x] karaf 3.0.2 is working
- [ ] test bluetooth
- [x] post-installation: Solve dependencies of launchAtStartX in post-installation-script.
- [ ] post-installation: after installRuby default ruby is not set. (At the moment run `rvm ruby-2.1.3 --default` after reboot)
- [ ] post-installation: get netatalk running for remote access from mac os
- [x] post-installation: add installPyRock

Create a partition backup:
==========================
To create a backup of a partition, run `./makeBackup.sh`

Missing steps:
--------------
- [ ] Restore a backup to the nand.
