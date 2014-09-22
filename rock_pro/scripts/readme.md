Steps to create an image:
=========================

1. get the needed tools: 
   `getTools.sh`

2. get the kernel sources:
   `getKernelSource.sh`

3. create kernel config: (and modify it, if you know what you do)
   `createKernelConfig.sh`

4. create the boot image:
   `createBootImage.sh`
   Actually, my self-compiled kernel is not working. I'm using the the boot-image extracted from the
   ubuntu-Image. If you have any hint, why self-created image is not working, please let me know!

4. create a rootfs image:
   `createKaliRootfs.sh`
