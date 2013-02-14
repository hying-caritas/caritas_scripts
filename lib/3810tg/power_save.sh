#!/bin/bash

for f in /sys/class/scsi_host/host*/link_power_management_policy; do
	echo min_power > $f
done

for f in /sys/class/net/eth*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/atl1c/*/power/control; do
	echo auto > $f
done

ethtool -s eth0 wol d

for f in /sys/class/net/wlan*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/iwlagn/*/power/control; do
	echo auto > $f
done

/sbin/iwconfig wlan0 power on

for f in /sys/class/sound/*/power/control; do
	echo auto > $f
done

for f in /sys/bus/pci/drivers/HDA*/*/power/control; do
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

echo 5 > /proc/sys/vm/laptop_mode
echo 1500 > /proc/sys/vm/dirty_writeback_centisecs
