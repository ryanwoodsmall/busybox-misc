# XXX - tag version in BB_EXTRA_VERSION
# XXX - musl-static/uclibc-ng-static/newlib/glibc variants, use --with/--define
# XXX - separate compiler/libc wrappers
# XXX - separate by directory
# XXX - use alternatives (glibc/musl-static/uclibc-ng-static in decreasion prio)
# XXX - symlink applets in install section so manifest/filelist is right

%global	debug_package	%{nil}

%define	spname		busybox
%define	instdir		/opt/%{spname}
%define	profiled	%{_sysconfdir}/profile.d

Name:		%{spname}-musl-static
Version:	1.36.0
Release:	17%{?dist}
Summary:	busybox compiled with musl-static

Group:		System Environment/Shells
License:	GPLv2
URL:		https://www.busybox.net/
Source0:	http://busybox.net/downloads/%{spname}-%{version}.tar.bz2
Source1:	https://raw.githubusercontent.com/ryanwoodsmall/busybox-misc/master/scripts/bb_config_script.sh

# if you need musl-static:
# https://github.com/ryanwoodsmall/musl-misc/blob/master/rpm/SPECS/musl-static.spec

BuildRequires:	musl-static >= 1.2.3-1
BuildRequires:	gcc
BuildRequires:	make
BuildRequires:	kernel-headers

Obsoletes:	%{spname}
Obsoletes:	%{spname}-big-musl-static

Provides:	%{spname}
Provides:	%{spname}-big
Provides:	%{spname}-big-musl-static
Provides:	%{name}

%description

BusyBox: The Swiss Army Knife of Embedded Linux

%prep
%setup -q -n %{spname}-%{version}


%build
. /etc/profile
bash %{SOURCE1} -$(rpm --eval '%{rhel}') -m -s
make %{?_smp_mflags} V=1 HOSTCC=musl-gcc CC=musl-gcc


%install
. /etc/profile
#make install DESTDIR=%{buildroot}
mkdir -p %{buildroot}%{instdir}
install -p -m 0755 busybox %{buildroot}%{instdir}/%{name}
ln -sf %{name} %{buildroot}%{instdir}/%{spname}
ln -sf %{name} %{buildroot}%{instdir}/%{spname}-big
mkdir -p %{buildroot}/sbin
ln -s %{instdir}/%{spname} %{buildroot}/sbin/
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
/sbin/%{spname}


%changelog
* Sun Feb 12 2023 ryan woodsmall
- busybox 1.36.0

* Fri Aug 19 2022 ryan woodsmall
- turn off debug
- source profile for musl-static

* Fri Apr 29 2022 ryan woodsmall
- release bump for musl 1.2.3

* Wed Jan  5 2022 ryan woodsmall
- busybox 1.35.0

* Thu Sep 30 2021 ryan woodsmall
- busybox 1.34.1

* Mon May  3 2021 ryan woodsmall
- busybox 1.33.1

* Fri Jan 15 2021 ryan woodsmall
- release bump for musl 1.2.2

* Wed Dec 30 2020 ryan woodsmall
- release bump for musl CVE-2020-28928

* Tue Dec 29 2020 ryan woodsmall
- busybox 1.33.0

* Sun Nov  1 2020 ryan woodsmall
- busybox 1.32.0

* Tue Oct 20 2020 ryan woodsmall
- release bump for musl 1.2.1

* Thu Oct 31 2019 ryan woodsmall
- busybox 1.31.1

* Sat Oct 26 2019 ryan woodsmall
- release bump for musl 1.1.24

* Wed Jul 17 2019 ryan woodsmall - 1.30.1-11
- release bump for musl 1.1.23

* Thu Apr 11 2019 ryan woodsmall - 1.30.1-10
- release bump for musl 1.1.22

* Fri Feb 15 2019 ryan woodsmall - 1.30.1-9
- busybox 1.30.1

* Tue Jan 22 2019 ryan woodsmall - 1.29.3-9
- release bump for musl 1.1.21

* Tue Sep 11 2018 ryan woodsmall - 1.29.3-8
- busybox 1.29.3
- release bump for musl 1.1.20

* Tue Jul 31 2018 ryan woodsmall - 1.29.2-7
- busybox 1.29.2

* Sun Jul 15 2018 ryan woodsmall - 1.29.1-7
- busybox 1.29.1

* Wed May 23 2018 ryan woodsmall - 1.28.3-7
- busybox 1.28.4

* Wed Mar 28 2018 ryan woodsmall - 1.28.3-7
- busybox 1.28.3

* Wed Mar 28 2018 ryan woodsmall - 1.28.2-7
- busybox 1.28.2

* Thu Feb 22 2018 ryan woodsmall - 1.28.1-7
- bump release for musl-libc 1.1.19

* Thu Feb 15 2018 ryan woodsmall - 1.28.1-6
- busybox 1.28.1

* Fri Feb 09 2018 ryan woodsmall - 1.28.0-6
- busybox-big-musl-static -> busybox-musl-static rename

* Mon Jan 22 2018 ryan woodsmall - 1.28.0-5
- include /sbin/busybox symlink

* Tue Jan 16 2018 ryan woodsmall - 1.28.0-4
- busybox 1.28.0

* Fri Dec 22 2017 ryan woodsmall - 1.27.2-4
- have to prepend CONFIG_ to toggle_on for actual feature additions

* Thu Dec 21 2017 ryan woodsmall - 1.27.2-3
- new wget tls, statusbar, etc. options

* Wed Nov  1 2017 ryan woodsmall - 1.27.2-2
- musl version bump

* Fri Oct 20 2017 ryan woodsmall - 1.27.2-1
- require minimum version of musl since we're using it statically

* Sat Aug 19 2017 ryan woodsmall - 1.27.2-0
- busybox 1.27.2 stable release

* Tue Jul 18 2017 ryan woodsmall - 1.27.1-0
- busybox 1.27.1 stable release

* Fri May  5 2017 ryan woodsmall - 1.26.2-3
- enable ipv6 on musl-libc

* Mon Mar 27 2017 ryan woodsmall - 1.26.2-2
- use posttrans instead of post to work around upgrade uninstall

* Mon Mar 27 2017 ryan woodsmall - 1.26.2-1
- initial rpm spec file for musl-static compiled busybox
