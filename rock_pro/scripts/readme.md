Steps to create an kali-image:
==============================
1. get the needed tools: 
   `./getTools.sh`

2. create a Nand-image for radxa rock pro:
   `./createNandImg.sh <versionNumer>` (e.g. ./createNandImg.sh 1.0.0)

Missing steps:
--------------
- [ ] create self-compiled kernel and use it for image
- [ ] Create image for sd-card
- [ ] buildRootfs: add launchAtStartX 
- [ ] buildRootfs: modify source.list and add main.pref
- [ ] buildRootfs: automatic resizeRootfs at first bootup

Notes:
------
* The script to create a rootfs is based on the work of [manu7irl](https://github.com/manu7irl).
* The image is modified in such a way that after bootup there is an auto-login as root and startx gets executed due to the fact, that at the moment after bootup, there is no output visible, which is not useable.

Getting started:
================
The first thing you may want to do after the image is running, is to resize the Rootfs to use the whole nand:
`resize2fs /dev/block/mtd/by-name/linuxroot`
Once this is done, you can download this workspace and modify the script: `post-installation.sh`. Uncomment all the steps, you want to be executed. Then run it!

Missing steps:
--------------
- [ ] fixSshService
- [ ] installRuby
- [ ] replaceNetworkManagerWithWicd
- [ ] try karaf 3.0.2-snapshot (or 2.4.0) -> due to java8 support
- [ ] test bluetooth
- [ ] When buildRootfs steps are done, adjust post-installation accordingly.

Create a partition backup:
==========================
To create a backup of a partition, run `./makeBackup.sh`

Missing steps:
--------------
- [ ] Restore a backup to the nand.
