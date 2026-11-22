# creating minimal initrd
simple straight forward initrd just for loading main root system


## bootloader parameters
### root device
- root=none			: to prevent device driver modules to load (for unshare container)
- root=				: loading into shell
- root=/dev/sda1	: device with rootfs
### path to live-system squashfs
- live				: default squash /live/filesystem.squashfs
- live=/alt/sys.sqsh: explicite squash /alt/sys.sqsh
