#!/bin/bash

#dbus-send --system --print-reply --dest=org.freedesktop.Hal  /org/freedesktop/Hal/devices/computer  org.freedesktop.Hal.Device.SystemPowerManagement.Suspend int32:0


dbus-send --system --print-reply --dest="org.freedesktop.UPower" /org/freedesktop/UPower org.freedesktop.UPower.Suspend
