Steps to create a nand-kali-image:
==================================
1. get the needed tools (if not done yet): 
   `./getTools.sh`

2. Optional: check build-configuration:
   `nano build.cfg`

3. create a Nand-image for radxa rock pro:
   `./createNandImg.sh`

Flash the image:
================
Simply run: `./flashNandImg.sh`

Missing steps:
--------------
- [ ] create self-compiled kernel and use it for image
- [ ] Create image for sd-card

Notes:
------
* The script to create a rootfs is based on the work of [manu7irl](https://github.com/manu7irl).
* The image is modified in such a way that after bootup there is an auto-login as root and startx gets executed due to the fact, that at the moment after bootup, there is no output visible, which is not useable.

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
