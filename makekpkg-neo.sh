#!/bin/bash
threads=8
dtb=( imx6sx-udoo-neo{,-basicks}{,-lvds{15,7},-hdmi}{,-m4}.dtb )

set -e

export ARCH=arm
export CROSS_COMPILE=/usr/bin/arm-linux-gnueabihf-
export KBUILD_DEBARCH=armhf 
export KBUILD_IMAGE=zImage 

#export KDEB_PKGVERSION="1udoobuntu"
export LOCALVERSION="-udooneo" 

export DEBFULLNAME="UDOO Team" 
export EMAIL="social@udoo.org" 


make -j${threads} clean
make -j${threads} udoo_neo_defconfig
make -j${threads} ${dtb[*]}
make -j${threads} zImage modules
make -j${threads} deb-pkg
