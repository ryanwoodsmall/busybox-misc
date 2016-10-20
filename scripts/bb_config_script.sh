#!/bin/bash

# TODO:
# - musl option
# - ulibc option
# - installer option
# - path (/usr CONFIG_INSTALL_NO_USR) option

# who are we
scriptname="$(basename "${BASH_SOURCE[0]}")"

# defaults
musl=0
uclibc=0
rhel6=0
rhel7=0
static=0

# simple delete/toggle_off/toggle_on  functions
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

# options/usage
function usage() {
	cat <<-EOF
	${scriptname} [-6] [-7] [-m] [-u] [-s]
	  -6 : rhel/centos 6 specific options
	  -7 : rhel/centos 7 specific options
	  -m : musl specific options
	  -u : uclibc/uclibc-ng specific options
	  -s : force static
	EOF
	exit 1
}

# read options
while getopts ":67mu" opt ; do
	case ${opt} in
		6)
			rhel6=1
			;;
		7)
			rhel7=1
			;;
		m)
			musl=1
			;;
		u)
			uclibc=1
			;;
		s)
			static=1
			;;
		\?)
			usage
			;;
	esac
done

# backup any .config
test -e .config && cp .config{,.PRE-$(date '+%Y%m%d%H%M%S')}

# clean up after ourself
make distclean

# start with default config
make defconfig

# make a static binary (default)
toggle_on CONFIG_STATIC

# rhel/centos 6 and 7 specific settings
if [ "${rhel7}" -eq 1 ] ; then
	toggle_off CONFIG_STATIC
	toggle_on CONFIG_PAM
elif [ "${rhel6}" -eq 1 ] ; then
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
fi

# check for force static here since we may reset on rhel-specific above
if [ "${static}" -eq 1 ] ; then
	toggle_on CONFIG_STATIC
fi

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

# enable larger but faster code
toggle_on CONFIG_FEATURE_FAST_TOP
toggle_on CONFIG_FEATURE_LZMA_FAST

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
