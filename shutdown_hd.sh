#!/bin/bash

set -e

swapoff -a
systemctl stop mpd
systemctl stop media-data.mount
systemctl stop swap.target
hdparm -Y /dev/sdb

echo "Success!"
