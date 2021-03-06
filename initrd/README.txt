example busybox based initrd with dropbear ssh

this is an attempt at an in-memory SSI cluster using kerrighed

musl-libc - version 1.1.15 - static linking only
  config: ./configure --prefix=/usr/local/musl --disable-shared --enable-debug
*or* 
uclibc-ng - version 1.0.17 - static as well
  configs: https://github.com/ryanwoodsmall/uclibc-misc/tree/master/conf

busybox - version 1.25.1 - built, statically linked
  config: run bb_config.sh script with "-m -i" options for musl and "busybox --install" support
  config: run bb_config.sh script with "-u -i" options for uclibc-ng and "busybox --install" support

dropbear - version 2016.74 - built with multi config, statically linked with musl-libc (should work w/uclibc-ng)
  config, build: https://github.com/ryanwoodsmall/dropbear-misc/tree/master/musl

example kernel version is 2.6.30-krg3.0.0 - Kerrighed 3.0.0 single system image cluster

(a vanilla kernel 4.4.x using a fedora .config should work if a single node is doable)

binaries and lib modules copied to proper places in init tree

initrd created with:
  find . | cpio -H newc -o | gzip > /tmp/busybox-initrd.img.gz

tested with qemu direct kernel boot ("-kernel" and "-initrd" options)

only user is "root" - no password, dropbear configured to allow no password logins

see "example_filelist.txt" for full list of files and their types in an example initrd

todo:
XXX - uClibc-ng is probably better for NFS roots
- rpc (libtirpc? libdrpc looks like a lot of work) - use uclibc-ng for now!
  - patches from http://git.alpinelinux.org/cgit/aports/tree/main/libtirpc?h=master (musl-fixes.patch , nis.h)
  - sys/queue.h (libc-dev in alpine)
- rpcbind
  - more from alpine: http://git.alpinelinux.org/cgit/aports/tree/main/rpcbind
- nfs (nfs-utils?)
- in-initrd musl based toolchain (leverage crosstool-ng)
- chroot/pivot_root
- dhcpc/dhclient
- copy resolv.conf
- disable network/NetworkManager startups
- copy busybox into new root fs
- kill any initramfs procs before chroot
- make sure we read/set sysctl values from /etc/sysctl.conf if it's there
- UTC timezone TZ setting
- C LANG for non-locale environment
- agetty for terminal(s)

Sabotage and Alpine are good small distros with lots of great, useful bits.
  http://sabotage.tech/ - https://github.com/sabotage-linux/sabotage
  http://www.alpinelinux.org/ - http://git.alpinelinux.org/
