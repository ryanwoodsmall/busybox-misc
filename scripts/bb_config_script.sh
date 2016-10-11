# simple delete/toggle_off/toggle_on 

function delete_setting() {
	sed -i -e "/^${1}=y/d" .config
	sed -i -e "/^# ${1} is not set/d" .config
}

function toggle_off() {
	delete_setting "${1}"
	echo "# ${1} is not set" >> .config
}

function toggle_on() {
	delete_setting "${1}"
	echo "${1}=y" >> .config
}

# backup any .config
test -e .config && cp .config{,.PRE-$(date '+%Y%m%d%H%M%S')}

# clean up after ourself
make distclean

# start with default config
make defconfig

# make a static binary
toggle_on CONFIG_STATIC

# rhel/centos 6 and 7 specific settings
# XXX - these need to be optional/override-able so they're not picked up by:
# - cross-compile
# - separate native compiler/linker/loader/libc
# - ...
test -e /etc/redhat-release && {
	# rhel == 7
	rpm --eval '%{rhel}' | grep -q ^7 && {
		toggle_off CONFIG_STATIC
		toggle_on CONFIG_PAM
	}
	# rhel == 6
	rpm --eval '%{rhel}' | grep -q ^6 && {
		# XXX - MTD_MODE_RAW vs MTD_FILE_MODE_RAW - #ifndef/#define?
		# http://lists.busybox.net/pipermail/buildroot/2013-October/080960.html
		toggle_off CONFIG_NANDWRITE
		toggle_off CONFIG_NANDDUMP
		# XXX - no blkdiscard on rhel 6
		toggle_off CONFIG_BLKDISCARD
		# XXX - setns is not in glibc on rhel 6
		# https://sourceforge.net/p/ltp/mailman/message/34252897/
		toggle_off CONFIG_NSENTER
		toggle_off CONFIG_FEATURE_NSENTER_LONG_OPTS
	}
}

# enable "big" compatibility corner cases
toggle_on CONFIG_EXTRA_COMPAT

# enable busybox to store its config
toggle_on CONFIG_BBCONFIG
toggle_on CONFIG_FEATURE_COMPRESS_BBCONFIG

# disable the applet installer
toggle_off CONFIG_FEATURE_INSTALLER
toggle_off CONFIG_INSTALL_APPLET_SYMLINKS
toggle_on CONFIG_INSTALL_NO_USR
toggle_on CONFIG_INSTALL_APPLET_DONT

# enable GPT disklabels in fdisk
toggle_on CONFIG_FEATURE_GPT_LABEL

# verbose message stuff
toggle_on CONFIG_FEATURE_VERBOSE_CP_MESSAGE
toggle_on CONFIG_VERBOSE_RESOLUTION_ERRORS

# network extras
toggle_on CONFIG_FEATURE_IP_RARE_PROTOCOLS
toggle_on CONFIG_FEATURE_TRACEROUTE_SOURCE_ROUTE
toggle_on CONFIG_FEATURE_TRACEROUTE_USE_ICMP

# enable the 'ar' program
toggle_on CONFIG_AR
toggle_on CONFIG_FEATURE_AR_LONG_FILENAMES
toggle_on CONFIG_FEATURE_AR_CREATE

# enable the dpkg programs
toggle_on CONFIG_DPKG_DEB
toggle_on CONFIG_DPKG

# enable the 'inotifyd' program
toggle_on CONFIG_INOTIFYD

# enable the 'taskset' program with fancy output
toggle_on CONFIG_TASKSET
toggle_on CONFIG_FEATURE_TASKSET_FANCY

# enable the 'tune2fs' program
toggle_on CONFIG_TUNE2FS

# enable the 'uncompress' program and .Z support
toggle_on CONFIG_UNCOMPRESS
toggle_on CONFIG_FEATURE_SEAMLESS_Z

# enable extra nc program options
toggle_on CONFIG_NC_110_COMPAT

# enable BLKID_TYPE and squashfs volume ID
toggle_on CONFIG_FEATURE_BLKID_TYPE
toggle_on CONFIG_FEATURE_VOLUMEID_SQUASHFS

# disable FTP authentication - breaks anonymous ftpd
toggle_off CONFIG_FEATURE_FTP_AUTHENTICATION

# enable gzip compression levels
toggle_on CONFIG_FEATURE_GZIP_LEVELS

# disable fancy sync
toggle_off CONFIG_FEATURE_SYNC_FANCY

# enable mount helpers
toggle_on CONFIG_FEATURE_MOUNT_HELPERS

# enable bash applet thing
toggle_off CONFIG_FEATURE_BASH_IS_HUSH
toggle_off CONFIG_FEATURE_BASH_IS_NONE
toggle_on CONFIG_FEATURE_BASH_IS_ASH

# rewrite config
make oldconfig

# build it
echo
echo "now run 'make'"
echo
