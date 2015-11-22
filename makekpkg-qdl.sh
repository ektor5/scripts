#!/bin/bash
threads=8
dtb=( imx6{q,dl}-udoo{-{15,7}lvds,}.dtb )

export KCFLAGS="-O2 -march=armv7-a -mtune=cortex-a9 -mfpu=vfpv3-d16 -pipe -fomit-frame-pointer"
export ARCH=arm
export CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf-
export KBUILD_DEBARCH=armhf 
export KBUILD_IMAGE=zImage 

#export KDEB_PKGVERSION="1udoobuntu"
export LOCALVERSION="-udooqdl" 

export DEBFULLNAME="UDOO Team" 
export EMAIL="social@udoo.org" 

#export BUILD_HEADERS=yes

#make -j${threads} clean
#make -j${threads} udoo_quad_defconfig
make -j${threads} ${dtb[*]}
make -j${threads} zImage modules
make -j${threads} deb-pkg
