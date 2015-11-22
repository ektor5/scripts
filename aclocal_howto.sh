#!/bin/bash

#how to make a configure file and makefiles
# ek5 @ 2015.10

# https://robots.thoughtbot.com/the-magic-behind-configure-make-make-install

cat << EOF > configure.ac
AC_INIT([mqx_upload_on_m4SoloX], [0.1], [ek5.chimenti@gmail.com])
AM_INIT_AUTOMAKE
AC_PROG_CC
AC_CONFIG_FILES([Makefile])
AC_OUTPUT
EOF

cat << EOF > configure.ac
AUTOMAKE_OPTIONS = foreign
bin_PROGRAMS = mqx_upload_on_m4SoloX
mqx_upload_on_m4SoloX_SOURCES = mqx_upload_on_m4SoloX.c
EOF

#m4 env
aclocal

#configure.ac -> configure
autoconf

#Makefile.am -> Makefile.in
automake --add-missing

#try it
./configure

#distribute it!
make dist
make distcheck

