# clean up after ourself
make distclean

# start with default config
make defconfig

# make a static binary
sed -i -e '/CONFIG_STATIC/d' .config
echo "CONFIG_STATIC=y" >>.config

# enable "big" compatibility corner cases
sed -i -e 's/.*CONFIG_EXTRA_COMPAT is not set/CONFIG_EXTRA_COMPAT=y/g' .config

# enable busybox to store its config
sed -i -e 's/.*CONFIG_BBCONFIG is not set/CONFIG_BBCONFIG=y/g' .config
sed -i -e 's/.*CONFIG_FEATURE_COMPRESS_BBCONFIG is not set/CONFIG_FEATURE_COMPRESS_BBCONFIG=y/g' .config

# disable the applet installer
sed -i -e 's/^CONFIG_FEATURE_INSTALLER=y/# CONFIG_FEATURE_INSTALLER is not set/g' .config
sed -i -e 's/^CONFIG_INSTALL_APPLET_SYMLINKS=y/# CONFIG_INSTALL_APPLET_SYMLINKS is not set/g' .config
sed -i -e 's/.*CONFIG_INSTALL_NO_USR is not set/CONFIG_INSTALL_NO_USR=y/g' .config
sed -i -e 's/.*CONFIG_INSTALL_APPLET_DONT is not set/CONFIG_INSTALL_APPLET_DONT=y/g' .config

# enable GPT disklabels in fdisk
sed -i -e 's/.*CONFIG_FEATURE_GPT_LABEL is not set/CONFIG_FEATURE_GPT_LABEL=y/g' .config

# verbose message stuff
sed -i -e 's/.*CONFIG_FEATURE_VERBOSE_CP_MESSAGE is not set/CONFIG_FEATURE_VERBOSE_CP_MESSAGE=y/g' .config
sed -i -e 's/.*CONFIG_VERBOSE_RESOLUTION_ERRORS is not set/CONFIG_VERBOSE_RESOLUTION_ERRORS=y/g' .config

# network extras
sed -i -e 's/.*CONFIG_FEATURE_IP_RARE_PROTOCOLS is not set/CONFIG_FEATURE_IP_RARE_PROTOCOLS=y/g' .config
sed -i -e 's/.*CONFIG_FEATURE_TRACEROUTE_SOURCE_ROUTE is not set/CONFIG_FEATURE_TRACEROUTE_SOURCE_ROUTE=y/g' .config
sed -i -e 's/.*CONFIG_FEATURE_TRACEROUTE_USE_ICMP is not set/CONFIG_FEATURE_TRACEROUTE_USE_ICMP=y/g' .config

# enable the 'ar' program
sed -i -e 's/.*CONFIG_AR is not set/CONFIG_AR=y/g' .config
sed -i -e 's/.*CONFIG_FEATURE_AR_LONG_FILENAMES is not set/CONFIG_FEATURE_AR_LONG_FILENAMES=y/g' .config
sed -i -e 's/.*CONFIG_FEATURE_AR_CREATE is not set/CONFIG_FEATURE_AR_CREATE=y/g' .config

# enable the dpkg programs
sed -i -e 's/.*CONFIG_DPKG_DEB is not set/CONFIG_DPKG_DEB=y/g' .config
sed -i -e 's/.*CONFIG_DPKG is not set/CONFIG_DPKG=y/g' .config

# enable the 'inotifyd' program
sed -i -e 's/.*CONFIG_INOTIFYD is not set/CONFIG_INOTIFYD=y/g' .config

# enable the 'taskset' program with fancy output
sed -i -e 's/.*CONFIG_TASKSET is not set/CONFIG_TASKSET=y/g' .config
sed -i -e 's/.*CONFIG_FEATURE_TASKSET_FANCY is not set/CONFIG_FEATURE_TASKSET_FANCY=y/g' .config

# enable the 'tune2fs' program
sed -i -e 's/.*CONFIG_TUNE2FS is not set/CONFIG_TUNE2FS=y/g' .config

# enable the 'uncompress' program and .Z support
sed -i -e 's/.*CONFIG_UNCOMPRESS is not set/CONFIG_UNCOMPRESS=y/g' .config
sed -i -e 's/.*CONFIG_FEATURE_SEAMLESS_Z is not set/CONFIG_FEATURE_SEAMLESS_Z=y/g' .config

# enable extra nc program options
sed -i -e 's/.*CONFIG_NC_110_COMPAT is not set/CONFIG_NC_110_COMPAT=y/g' .config

# enable BLKID_TYPE and squashfs volume ID
sed -i -e 's/.*CONFIG_FEATURE_BLKID_TYPE is not set/CONFIG_FEATURE_BLKID_TYPE=y/g' .config
sed -i -e 's/.*CONFIG_FEATURE_VOLUMEID_SQUASHFS is not set/CONFIG_FEATURE_VOLUMEID_SQUASHFS=y/g' .config

# disable FTP authentication - breaks anonymous ftpd
sed -i -e 's/CONFIG_FEATURE_FTP_AUTHENTICATION=y/# CONFIG_FEATURE_FTP_AUTHENTICATION is not set/g' .config

# enable bash applet thing
sed -i -e '/CONFIG_FEATURE_BASH_IS_/d' .config
echo '# CONFIG_FEATURE_BASH_IS_HUSH is not set' >>.config
echo '# CONFIG_FEATURE_BASH_IS_NONE is not set' >>.config
echo 'CONFIG_FEATURE_BASH_IS_ASH=y' >>.config

# rewrite config
make oldconfig

# build it
echo ''
echo "now run 'make'"
echo ''
