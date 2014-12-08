#!/bin/sh

# URL is like: 
#   http://busybox.net/downloads/fixes-1.22.1/

fail_exit(){
	echo "${@}"
	exit 1
}

which curl >/dev/null 2>&1 || fail_exit "please install curl"

BBVER=`echo ${PWD} | awk -F\/ '{print $(NF-1)}' | sed 's/busybox-//g'`
echo ${BBVER} | grep -q -e '^[0-9]\{1,\}\.[0-9]\{1,\}.*' || fail_exit "${BBVER} doesn't look like a valid version"

BBFIXESURL="http://busybox.net/downloads/fixes-${BBVER}"
curl -kIL ${BBFIXESURL} >/dev/null 2>&1 || fail_exit "curl can't check ${BBFIXESURL}"

BBFIXESFILES=`curl -kL ${BBFIXESURL} 2>/dev/null | tr '"' '\n' | grep -i \\.patch$`
echo ${BBFIXESFILES} | tr ' ' '\n' | grep -i \\.patch$ | wc -l | grep -q ^0$ && fail_exit "looks like there are no patches for ${BBVER}"

for BBPATCH in ${BBFIXESFILES} ; do
	BBPATCHURL="${BBFIXESURL}/${BBPATCH}"
	echo "grabbing ${BBPATCHURL} to ${PWD}/${BBPATCH}"
	curl -kLo ${BBPATCH} ${BBPATCHURL} >/dev/null 2>&1
	if [ $? -eq 0 ] ; then
		echo "successfully grabbed ${BBPATCHURL}"
	else
		echo "couldn't grab ${BBPATCHURL} - fetch manually"
	fi
	echo ""
done
