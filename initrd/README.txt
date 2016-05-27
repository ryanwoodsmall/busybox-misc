example busybox based initrd with dropbear ssh

musl-libc - version 1.1.14 - static linking only
  config: ./configure --prefix=/usr/local/musl --disable-shared --enable-debug

busybox - version 1.24.1 - built, statically linked with musl-libc
  config: https://github.com/ryanwoodsmall/busybox-misc/tree/master/configs

dropbear - version 2016.73 - built with multi config, statically linked with musl-libc
  config, build: https://github.com/ryanwoodsmall/dropbear-misc/tree/master/musl

example kernel version is 2.6.30-krg3.0.0 - Kerrighed 3.0.0 single system image cluster

binaries and lib modules copied to proper places in init tree

initrd created with:
  find . | cpio -H newc -o | gzip > /tmp/busybox-initrd.img.gz

tested with qemu direct kernel boot ("-kernel" and "-initrd" options)

only user is "root" - no password, dropbear configured to allow no password logins

see "example_filelist.txt" for full list of files and their types in an example initrd

todo:
- rpc (libtirpc? libdrpc looks like a lot of work) - use uclibc-ng for now!
  - patches from http://git.alpinelinux.org/cgit/aports/tree/main/libtirpc?h=master (musl-fixes.patch , nis.h)
  - sys/queue.h (libc-dev in alpine)
- rpcbind
  - more from alpine: http://git.alpinelinux.org/cgit/aports/tree/main/rpcbind
- nfs (nfs-utils?)
- in-initrd musl based toolchain (leverage crosstool-ng)

uClibc-ng is probably better for NFS roots

- chroot/pivot_root
- dhcpc/dhclient
- copy resolv.conf
- disable network/NetworkManager startups
- copy busybox into new root fs
- kill any initramfs procs before chroot

Sabotage and Alpine are good small distros with lots of great, useful bits.
  http://sabotage.tech/ - https://github.com/sabotage-linux/sabotage
  http://www.alpinelinux.org/ - http://git.alpinelinux.org/
