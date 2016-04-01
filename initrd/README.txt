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
