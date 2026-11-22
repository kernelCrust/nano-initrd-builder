#!/bin/sh
set -euo pipefail

COMMON_ARG="-m 2G -kernel /boot/vmlinuz-6.12.107+deb13-amd64 \
-initrd $INITRD_IMG -net nic -net user"

VIRTIO_SCSI="-device virtio-scsi-pci -device scsi-hd,drive=hd0 \
-drive file=$DISK_IMG,format=raw,if=none,id=hd0"
NVME="-device nvme,drive=hd0,serial=nvme-1 \
-drive file=$DISK_IMG,format=raw,if=none,id=hd0"
AHCI="-device ahci,id=ahci0 -device ide-hd,drive=hd0,bus=ahci0.0 \
-drive file=$DISK_IMG,format=raw,if=none,id=hd0"

case "$1" in
    kvm.normal) 
			STORAGE="$VIRTIO_SCSI"
			APPEND='console=ttyS0 root=/dev/sda'
			;;
    kvm.normal.uuid) 
			STORAGE="$VIRTIO_SCSI"
			APPEND='console=ttyS0 root=UUID=607f39b5-17c0-49b4-934d-bb5270d8d38c'
			;;
    kvm.normal.label) 
			STORAGE="$VIRTIO_SCSI"
			APPEND='console=ttyS0 root=LABEL=testLBL'
			;;
    kvm.alt_live) 
			STORAGE="$VIRTIO_SCSI"
			APPEND='root=/dev/sda live='
			;;
    kvm.label) 
			STORAGE="$VIRTIO_SCSI"
			APPEND='root=LABEL=testLBL live=/live/sys.sqsh'
			;;
    kvm) 
			STORAGE="$VIRTIO_SCSI"
			APPEND='wait=11 console=ttyS0 root=/dev/sda live=/live/sys.sqsh'
			;;
    kvm.shell) 
			STORAGE="$VIRTIO_SCSI"
			APPEND=''
			;;
    kvm.ttyS0) 
			STORAGE="$VIRTIO_SCSI"
			APPEND='console=ttyS0 root=/dev/sda live'
			;;
    kvm.ahci) 
			STORAGE="$AHCI"
			APPEND='root=/dev/sda live'
			;;
    kvm.nvme) 
			STORAGE="$NVME"
			APPEND='root=/dev/nvme0n1 live'
			;;
    *)  return 1 ;;
esac

kvm $COMMON_ARG $STORAGE -append "$APPEND"

