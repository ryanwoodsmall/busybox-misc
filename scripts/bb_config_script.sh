#!/bin/bash

#
# versions tested
#
#   busybox : 1.26.2 (stable)
#   rhel : 6, 7 with default glibc
#   musl : 1.1.16 (rhel6, static, without ipv6)
#   uclibc-ng : 1.0.21 (rhel6, static, rpc, config(s) linked below)
#

#
# links:
#
#  uclibc-ng configs:
#    https://github.com/ryanwoodsmall/uclibc-misc/tree/master/conf
#

# TODO
#
#   debug option(s)
#   locale (uclibc/glibc only, no musl?)
#   selinux (ugh)
#   systemd (double ugh)
#   unicode
#

# who are we
scriptname="$(basename "${BASH_SOURCE[0]}")"

# defaults
musl=0
installer=0
usrpath=0
rhel6=0
rhel7=0
static=0
uclibc=0

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
	${scriptname} [-6] [-7] [-i] [-m] [-p] [-s] [-m]
	  -6 : rhel/centos 6 specific options
	  -7 : rhel/centos 7 specific options
	  -i : include "busybox --install" support
	  -m : musl specific options
	  -p : use /usr for "busybox --install"
	  -s : force static
	  -u : uclibc/uclibc-ng specific options
	EOF
	exit 1
}

# read options
while getopts ":67impsu" opt ; do
	case ${opt} in
		6)
			rhel6=1
			;;
		7)
			rhel7=1
			;;
		i)
			installer=1
			;;
		m)
			musl=1
			;;
		p)
			usrpath=1
			;;
		s)
			static=1
			;;
		u)
			uclibc=1
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
test -e .config && rm -f .config
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

# uclibc/musl overrides are below

# enable "big" compatibility corner cases
toggle_on CONFIG_EXTRA_COMPAT

# enable busybox to store its config
toggle_on CONFIG_BBCONFIG
toggle_on CONFIG_FEATURE_COMPRESS_BBCONFIG

# disable the applet installer by default
if [ "${installer}" -eq 0 ] ; then
	toggle_off CONFIG_FEATURE_INSTALLER
fi
# disable the use of /usr on "busybox --install" by default
if [ "${usrpath}" -eq 0 ] ; then
	toggle_on CONFIG_INSTALL_NO_USR
fi

# "make install" only
# don't setup any applet hard or symbolic links or script wrappers
# does this need to be configurable? (no?)
toggle_off CONFIG_INSTALL_APPLET_HARDLINKS
toggle_off CONFIG_INSTALL_APPLET_SCRIPT_WRAPPERS
toggle_off CONFIG_INSTALL_APPLET_SYMLINKS
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
toggle_off CONFIG_FEATURE_FTPD_AUTHENTICATION

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
toggle_off CONFIG_BASH_IS_HUSH
toggle_off CONFIG_BASH_IS_NONE
toggle_on CONFIG_BASH_IS_ASH

# sh is also ash
toggle_off CONFIG_FEATURE_SH_IS_HUSH
toggle_off CONFIG_FEATURE_SH_IS_NONE
toggle_on CONFIG_FEATURE_SH_IS_ASH

# kernel module 
toggle_off CONFIG_MODPROBE_SMALL
toggle_on CONFIG_FEATURE_LSMOD_PRETTY_2_6_OUTPUT
toggle_on CONFIG_FEATURE_MODPROBE_BLACKLIST
# XXX - ugly fix for uclibc-ng 1.0.21+
grep -q '^#ifdef __UCLIBC__$' modutils/modutils.c && \
	sed -i.ORIG '/__UCLIBC__/ s/__UCLIBC__/__UCLIBCOLD__/g' modutils/modutils.c

# musl override options
if [ "${musl}" -eq 1 ] ; then
	# XXX - mostly ipv6 stuff, can probably be fixed/enabled
	toggle_off CONFIG_EXTRA_COMPAT
	toggle_off CONFIG_FEATURE_IFUPDOWN_IPV6
	toggle_off CONFIG_FEATURE_IPV6
	toggle_off CONFIG_FEATURE_LAST_FANCY
	toggle_off CONFIG_FEATURE_PREFER_IPV4_ADDRESS
	toggle_off CONFIG_FEATURE_UPTIME_UTMP_SUPPORT
	toggle_off CONFIG_FEATURE_UTMP
	toggle_off CONFIG_FEATURE_WTMP
	toggle_off CONFIG_IFPLUGD
	toggle_off CONFIG_LAST
	toggle_off CONFIG_PING6
	toggle_off CONFIG_RUNLEVEL
	toggle_off CONFIG_TRACEROUTE6
	toggle_off CONFIG_USERS
	toggle_off CONFIG_WALL
	toggle_off CONFIG_WHO
fi

# uclibc override options
if [ "${uclibc}" -eq 1 ] ; then
	toggle_on CONFIG_FEATURE_HAVE_RPC
	toggle_on CONFIG_FEATURE_INETD_RPC
	toggle_on CONFIG_UNICODE_WIDE_WCHARS
fi

# we should be able to safely enable nsenter w/musl or uclibc-ng
if [ "${musl}" -eq 1 -o "${uclibc}" -eq 1 ] ; then
	toggle_on CONFIG_NSENTER
	toggle_on CONFIG_FEATURE_NSENTER_LONG_OPTS
	toggle_off CONFIG_MONOTONIC_SYSCALL
fi

# rewrite config
make oldconfig

# build it
echo
echo "now run 'make'"
echo
