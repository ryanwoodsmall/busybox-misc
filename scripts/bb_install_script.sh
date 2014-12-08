#!/bin/sh

BBBASEDIR="/opt/busybox"
BBPREVLINK="${BBBASEDIR}/previous"
BBCURLINK="${BBBASEDIR}/current"

fail_exit(){
	echo "${@}" 1>&2
	exit 1
}

test -e busybox || fail_exit "no busybox binary found in this directory"

./busybox --list >/dev/null 2>&1 || fail_exit "the busybox in ${PWD} doesn't seem to work"

BBVER=`./busybox | head -1 | grep -i '^busybox' | cut -f2 -d' ' | tr -d v`
echo ${BBVER} | grep -q -e '^[0-9]\{1,\}\.[0-9]\{1,\}.*' || fail_exit "${BBVER} doesn't look like a valid version"

BBINSTDIR="${BBBASEDIR}/busybox-${BBVER}"
mkdir -p ${BBINSTDIR} || fail_exit "couldn't make dir ${BBINSTDIR}"

install -m 0755 ./busybox ${BBINSTDIR}/ || fail_exit "couldn't install busybox into ${BBINSTDIR}"
pushd ${BBINSTDIR} >/dev/null 2>&1 || fail_exit "couldn't cd into ${BBINSTDIR}"
echo "installing `./busybox --list | wc -l` links in ${BBINSTDIR}"
for BBLINK in `./busybox --list` ; do
	ln -sf ${BBINSTDIR}/busybox ${BBINSTDIR}/${BBLINK}
done
popd >/dev/null 2>&1

ln -sf ${BBINSTDIR}/busybox ${BBINSTDIR}/busybox-big

test -e ${BBPREVLINK} && rm -f ${BBPREVLINK}
test -e ${BBCURLINK}  && mv ${BBCURLINK} ${BBPREVLINK}
ln -sf ${BBINSTDIR} ${BBCURLINK}

echo "busybox ${BBVER} installed in ${BBINSTDIR}"

exit 0
