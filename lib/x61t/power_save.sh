#!/bin/bash

for f in /sys/class/scsi_host/host*/link_power_management_policy; do
	echo min_power > $f
done

for f in /sys/class/net/eth*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/e1000e/*/power/control; do
	echo auto > $f
done

#ethtool -s eth0 wol d

for f in /sys/class/net/wlan*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/iwl4965/*/power/control; do
	echo auto > $f
done

#/sbin/iwconfig wlan0 power on

for f in /sys/class/sound/*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/snd_hda_intel/*/power/control; do
	echo auto > $f
done

echo Y > /sys/module/snd_hda_intel/parameters/power_save_controller
echo 1 > /sys/module/snd_hda_intel/parameters/power_save

for f in /sys/bus/pci/drivers/i915/*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/ehci_hcd/*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/uhci_hcd/*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/pcieport/*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/ahci/*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/sdhci*/*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/i801_smbus/*/power/control; do
	echo auto > $f
done

#for f in /sys/bus/pci/drivers/firewire_ohci/*/power/control; do
#	echo auto > $f
#done

for f in /sys/bus/usb/devices/*/power/control; do
	echo auto > $f
done

echo 0 > /sys/devices/system/cpu/cpu1/online

modprobe -rq yenta_socket

echo 0 > /proc/sys/kernel/nmi_watchdog
echo 0 > /proc/sys/kernel/watchdog
echo 5 > /proc/sys/vm/laptop_mode
echo 1500 > /proc/sys/vm/dirty_writeback_centisecs
