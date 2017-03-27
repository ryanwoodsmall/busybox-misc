%define	spname		busybox
%define	instdir		/opt/%{spname}
%define	profiled	%{_sysconfdir}/profile.d

Name:		%{spname}-big-musl-static
Version:	1.26.2
Release:	1%{?dist}
Summary:	busybox compiled with musl-static

Group:		System Environment/Shells
License:	GPLv2
URL:		https://www.busybox.net/
Source0:	http://busybox.net/downloads/%{spname}-%{version}.tar.bz2
Source1:	https://raw.githubusercontent.com/ryanwoodsmall/busybox-misc/master/scripts/bb_config_script.sh

# if you need musl-static: https://github.com/ryanwoodsmall/musl-misc/blob/master/rpm/SPECS/musl-static.spec

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


%post
cd %{instdir}
for applet in `./%{name} --list` ; do ln -sf %{instdir}/%{name} %{instdir}/${applet} ; done
exit 0


%preun
cd %{instdir}
for applet in `./%{name} --list` ; do test -e %{instdir}/${applet} && rm -f %{instdir}/${applet} ; done
exit 0


%files
%{instdir}/%{spname}*
%{profiled}/%{name}.sh


%changelog
* Mon Mar 27 2017 ryan woodsmall <rwoodsmall@gmail.com> - 1.26.2-1
- initial rpm spec file for musl-static compiled busybox
