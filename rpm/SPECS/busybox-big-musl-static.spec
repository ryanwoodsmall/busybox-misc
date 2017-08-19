# XXX - tag version in BB_EXTRA_VERSION
# XXX - musl-static/uclibc-ng-static/newlib/glibc variants, use --with/--define
# XXX - separate compiler/libc wrappers
# XXX - separate by directory
# XXX - use alternatives (glibc/musl-static/uclibc-ng-static in decreasion prio)
# XXX - symlink applets in install section so manifest/filelist is right

%define	spname		busybox
%define	instdir		/opt/%{spname}
%define	profiled	%{_sysconfdir}/profile.d

Name:		%{spname}-big-musl-static
Version:	1.27.2
Release:	0%{?dist}
Summary:	busybox compiled with musl-static

Group:		System Environment/Shells
License:	GPLv2
URL:		https://www.busybox.net/
Source0:	http://busybox.net/downloads/%{spname}-%{version}.tar.bz2
Source1:	https://raw.githubusercontent.com/ryanwoodsmall/busybox-misc/master/scripts/bb_config_script.sh

# if you need musl-static:
# https://github.com/ryanwoodsmall/musl-misc/blob/master/rpm/SPECS/musl-static.spec

BuildRequires:	musl-static
BuildRequires:	gcc
BuildRequires:	make
BuildRequires:	kernel-headers

Obsoletes:	busybox

Provides:	%{spname}
Provides:	%{spname}-big
Provides:	%{name}

%description

BusyBox: The Swiss Army Knife of Embedded Linux

%prep
%setup -q -n %{spname}-%{version}


%build
bash %{SOURCE1} -$(rpm --eval '%{rhel}') -m -s
make %{?_smp_mflags} V=1 HOSTCC=musl-gcc CC=musl-gcc


%install
#make install DESTDIR=%{buildroot}
mkdir -p %{buildroot}%{instdir}
install -p -m 0755 busybox %{buildroot}%{instdir}/%{name}
ln -sf %{name} %{buildroot}%{instdir}/%{spname}
ln -sf %{name} %{buildroot}%{instdir}/%{spname}-big
mkdir -p %{buildroot}%{profiled}
echo 'export PATH="${PATH}:%{instdir}"' > %{buildroot}%{profiled}/%{name}.sh


%posttrans
test -e %{instdir}/%{name} || exit 0
for applet in `%{instdir}/%{name} --list` ; do ln -sf %{instdir}/%{name} %{instdir}/${applet} ; done
exit 0


%preun
test -e %{instdir}/%{name} || exit 0
for applet in `%{instdir}/%{name} --list` ; do test -e %{instdir}/${applet} && rm -f %{instdir}/${applet} ; done
exit 0


%files
%{instdir}/%{spname}*
%{profiled}/%{name}.sh


%changelog
* Sat Aug 19 2017 ryan woodsmall <rwoodsmall@gmail.com> - 1.27.2-0
- busybox 1.27.2 stable release

* Tue Jul 18 2017 ryan woodsmall <rwoodsmall@gmail.com> - 1.27.1-0
- busybox 1.27.1 stable release

* Fri May  5 2017 ryan woodsmall <rwoodsmall@gmail.com> - 1.26.2-3
- enable ipv6 on musl-libc

* Mon Mar 27 2017 ryan woodsmall <rwoodsmall@gmail.com> - 1.26.2-2
- use posttrans instead of post to work around upgrade uninstall

* Mon Mar 27 2017 ryan woodsmall <rwoodsmall@gmail.com> - 1.26.2-1
- initial rpm spec file for musl-static compiled busybox
