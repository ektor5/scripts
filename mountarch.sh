#!/bin/bash

if [[ $UID -ne 0 ]]
then
  echo "Non sei admin!!";
  exit 1;
fi

PATH=$PATH:/bin

export PATH

mount /dev/sdb5
mount /sys /media/arch/sys -t sysfs
mount /dev /media/arch/dev -o bind
mount /proc /media/arch/proc -t proc
chroot /media/arch /bin/bash