Name:       sdk-setup

Summary:    SDK setup packages for Mer SDK
Version:    1.4.14
Release:    1
Group:      System/Base
License:    GPL
BuildArch:  noarch
URL:        https://github.com/sailfishos/sdk-setup
Source0:    %{name}-%{version}.tar.bz2
BuildRequires:  pkgconfig(systemd)

%description
Scripts, configurations and utilities to build Mer SDK and variants

%package -n sdk-chroot
Summary:    Mer SDK files for the chroot variant
Group:      System/Base
BuildArch:  noarch
Requires(pre): rpm
Requires(pre): /bin/rm
Conflicts:  sdk-vm

%description -n sdk-chroot
Contains the mer_sdk_chroot script and supporting configs

%package -n sdk-vm
Summary:    Mer SDK files for the VM variant
Group:      System/Base
BuildArch:  noarch
Requires:   sdk-utils == %{version}
Requires:   sdk-welcome-message
Requires:   connman >= 1.14
Requires:   connman-tools
Requires:   virtualbox-guest-tools
Requires:   openssh-server
Requires:   kbd
Requires:   ncurses
Requires:   python3-fuse
Requires(post): /bin/ln
Conflicts:  sdk-chroot
%systemd_requires

%description -n sdk-vm
Contains the supporting configs for VMs

%package -n sdk-tooling-chroot
Summary:    Mer SDK files for build tools distribution
Group:      System/Base
BuildArch:  noarch
Requires(pre): rpm
Requires(pre): /bin/rm

%description -n sdk-tooling-chroot
Contains the mer-tooling-chroot script

%package -n sdk-sb2-config
Summary:    Mer SDK mode names for sb2
Group:      System/Base
BuildArch:  noarch
Requires:   scratchbox2 >= 2.3.90+git1

%description -n sdk-sb2-config
Contains the sdk-build and sdk-install mode symlinks for scratchbox2.

%package -n sdk-utils
Summary:    Mer SDK utility scripts
Group:      System/Base
BuildArch:  noarch
Requires:   createrepo_c
Requires:   libxml2
Requires:   rpm-build
Requires:   python3-lxml
Requires:   rsync
Requires:   sudo
Requires:   scratchbox2 >= 2.3.90+git2
Requires:   sdk-register
Requires:   ssu >= 0.43.2
Requires:   git
Requires:   tar
Requires:   p7zip-full
Requires:   gnu-cpio
Requires:   compiledb
Requires:   /usr/bin/python3
Conflicts:  sdk-harbour-rpmvalidator < 1.49

%description -n sdk-utils
Contains some utility scripts to support Mer SDK development

%package -n sdk-resize-rootfs
Summary:    Service that expands root FS at system startup
Group:      System/Base
BuildArch:  noarch
Requires:   util-linux
Requires:   e2fsprogs
%systemd_requires

%description -n sdk-resize-rootfs
Provides a startup service that will automatically expand the root FS to utilize
all space on the root partition if it was enlarged since the last run.

%package -n sdk-mer-branding
Summary:    Mer Branding for the SDK Engine
Group:      System/Base
BuildArch:  noarch
Requires:   plymouth-lite
Requires:   sdk-vm
Provides:   boot-splash-screen
Provides:   sdk-welcome-message

%description -n sdk-mer-branding
Splash screen for the SDK Engine

%package -n connman-configs-mersdk-emul
Summary:    Connman configs for SDK Emulator
Group:      System/Base
BuildArch:  noarch
Requires:   connman
Provides:   connman-configs

%description -n connman-configs-mersdk-emul
Connman configs for SDK emulator to ensure session is started

%prep
%setup -q -n %{name}-%{version}/%{name}

%build

%install
rm -rf %{buildroot}
# all sdks
mkdir -p %{buildroot}%{_bindir}/
cp src/sdk-version %{buildroot}%{_bindir}/
mkdir %{buildroot}/home
ln -s /var/cache/zypp %{buildroot}/home/.zypp-cache

# sdk-chroot
mkdir -p %{buildroot}/%{_sysconfdir}
cp src/mer-sdk-chroot %{buildroot}/
cp src/mer-bash-setup %{buildroot}/
echo "This file serves for detection that this is a chroot SDK installation" > %{buildroot}/%{_sysconfdir}/mer-sdk-chroot
mkdir -p %{buildroot}/srv/mer/targets
mkdir -p %{buildroot}/srv/mer/toolings
mkdir -p %{buildroot}%{_sysconfdir}/zypp/systemCheck.d
cp etc/sdk-chroot.check %{buildroot}%{_sysconfdir}/zypp/systemCheck.d/
mkdir -p %{buildroot}%{_libexecdir}/%{name}

# sdk-vm
mkdir -p %{buildroot}/%{_unitdir}
cp -r --no-dereference systemd/* %{buildroot}/%{_unitdir}/
cp src/sdk-info %{buildroot}%{_bindir}/
cp src/sdk-setup-enginelan %{buildroot}%{_bindir}/
mkdir -p %{buildroot}/%{_sysconfdir}/udev/rules.d
ln -s /dev/null %{buildroot}/%{_sysconfdir}/udev/rules.d/80-net-setup-link.rules
cp src/sdk-shutdown %{buildroot}%{_bindir}/
cp src/dynexecfs %{buildroot}%{_bindir}/
mkdir -p %{buildroot}%{_libexecdir}/%{name}
cp src/workspace-autodetect %{buildroot}%{_libexecdir}/%{name}/
cp src/sdk-setup-env %{buildroot}%{_libexecdir}/%{name}/
# This should really be %%{_unitdir}/default.target but systemd owns that :/
mkdir -p %{buildroot}/%{_sysconfdir}/systemd/system/
ln -sf %{_unitdir}/multi-user.target  %{buildroot}/%{_sysconfdir}/systemd/system/default.target
echo "This file serves for detection that this is a VirtualBox SDK installation" > %{buildroot}/%{_sysconfdir}/mer-sdk-vbox
mkdir -p %{buildroot}%{_sysconfdir}/zypp/systemCheck.d
cp etc/sdk-vm.check %{buildroot}%{_sysconfdir}/zypp/systemCheck.d/
mkdir -p %{buildroot}%{_sysconfdir}/modprobe.d
cp etc/blacklist-vboxvideo.conf %{buildroot}%{_sysconfdir}/modprobe.d/
mkdir -p %{buildroot}%{_sysconfdir}/profile.d
cp etc/sdk-vm.sh %{buildroot}%{_sysconfdir}/profile.d/
mkdir -p %{buildroot}/%{_sysconfdir}/dbus-1/system.d
cp etc/dbus-1/system.d/sdk.conf %{buildroot}/%{_sysconfdir}/dbus-1/system.d/

mkdir -p %{buildroot}/%{_sysconfdir}/mersdk

mkdir -p %{buildroot}/%{_sysconfdir}/ssh/
mkdir -p %{buildroot}/%{_sysconfdir}/ssh/authorized_keys
cp etc/ssh-env.conf  %{buildroot}/%{_sysconfdir}/ssh/
cp etc/sshd_config_engine  %{buildroot}/%{_sysconfdir}/ssh/

mkdir -p %{buildroot}/home/deploy
chmod 1777 %{buildroot}/home/deploy

# Until login.prefs.systemd is ready
cp etc/mersdk.env.systemd  %{buildroot}/%{_sysconfdir}/

# sdk-resize-rootfs
install -D -m 755 src/resize-rootfs %{buildroot}%{_bindir}/resize-rootfs

# sdk-tooling-chroot
cp src/mer-tooling-chroot %{buildroot}/

# sdk-sb2-config
mkdir -p %{buildroot}/usr/share/scratchbox2/modes/
ln -sf obs-rpm-build  %{buildroot}/usr/share/scratchbox2/modes/sdk-build
ln -sf obs-rpm-build+pp  %{buildroot}/usr/share/scratchbox2/modes/sdk-build+pp
ln -sf obs-rpm-install  %{buildroot}/usr/share/scratchbox2/modes/sdk-install

# sdk-utils
cp src/git-change-log %{buildroot}%{_bindir}/
cp src/mb %{buildroot}%{_bindir}/
cp src/mb2 %{buildroot}%{_bindir}/
cp src/qb %{buildroot}%{_bindir}/
cp src/sdk-foreach-su %{buildroot}%{_bindir}/
cp src/sdk-manage %{buildroot}%{_bindir}/
cp src/sdk-assistant %{buildroot}%{_bindir}/
cp src/updateQtCreatorTargets %{buildroot}%{_bindir}/updateQtCreatorTargets
cp src/sdk-motd %{buildroot}%{_bindir}/
cp src/rpmvalidation %{buildroot}%{_bindir}/
ln -sf rpmvalidation %{buildroot}%{_bindir}/rpmvalidation.sh
cp src/git-lltb %{buildroot}%{_bindir}/
cp src/sdk-init %{buildroot}%{_bindir}/
cp src/sdk-make-qmltypes %{buildroot}%{_bindir}/
mkdir -p %{buildroot}%{_libexecdir}/%{name}
cp src/oomadvice %{buildroot}%{_libexecdir}/%{name}/
cp src/sdk-setup-swap %{buildroot}%{_libexecdir}/%{name}/
cp src/ssh-askpass %{buildroot}%{_libexecdir}/%{name}/
mkdir -p %{buildroot}%{_datadir}/%{name}
cp README.tips.wiki %{buildroot}%{_datadir}/%{name}/

# update version info to scripts
sed -i "s/VERSION_FROM_SPEC/%{version}/" %{buildroot}%{_bindir}/mb2
sed -i "s/VERSION_FROM_SPEC/%{version}/" %{buildroot}%{_bindir}/sdk-manage

mkdir -p %{buildroot}/%{_sysconfdir}/ssh/
cp etc/ssh_config.sdk %{buildroot}/%{_sysconfdir}/ssh/
install -D -m 644 src/mb2.bash %{buildroot}/%{_sysconfdir}/bash_completion.d/mb2.bash
install -D -m 644 src/sdk-assistant.bash %{buildroot}/%{_sysconfdir}/bash_completion.d/sdk-assistant.bash

# sdk-mer-branding
install -D -m 644 branding/mer-splash.png %{buildroot}%{_datadir}/plymouth/splash.png
install -D -m 755 branding/splashfontcol %{buildroot}%{_sysconfdir}/sysconfig/splashfontcol
install -D -m 755 branding/sdk-welcome-message %{buildroot}%{_sysconfdir}/sdk-welcome-message

# connman-configs-mersdk-emul
mkdir -p %{buildroot}%{_sysconfdir}/connman
install -D -m 755 etc/connman_main.conf %{buildroot}%{_sysconfdir}/connman/main.conf

# Make all bindir executable
chmod 755 %{buildroot}%{_bindir}/*

%pre -n sdk-chroot
if ! rpm --quiet -q ca-certificates && [ -d /%{_sysconfdir}/ssl/certs ] ; then echo "Cleaning up copied ssl certs. ca-certificates should now install"; rm -rf /%{_sysconfdir}/ssl/certs ;fi
rm -Rf /home/.zypp-cache

%pre -n sdk-vm
rm -Rf /home/.zypp-cache

%preun -n sdk-vm
%systemd_preun workspace.service
%systemd_preun sdk-setup-env.service
%systemd_preun etc-mersdk-share.service
%systemd_preun etc-ssh-authorized_keys.mount
%systemd_preun host_home.service
%systemd_preun host_install.service
%systemd_preun host_targets.service
%systemd_preun information.service
%systemd_preun sdk-enginelan.service
%systemd_preun oneshot-root-late-sdk.service
%systemd_preun sdk-freespace.service

%post -n sdk-vm
%systemd_post workspace.service
%systemd_post sdk-setup-env.service
%systemd_post etc-mersdk-share.service
%systemd_post etc-ssh-authorized_keys.mount
%systemd_post host_home.service
%systemd_post host_install.service
%systemd_post host_targets.service
%systemd_post information.service
%systemd_post sdk-enginelan.service
%systemd_post sdk-refresh.service
%systemd_post sdk-refresh.timer
%systemd_post sdk-setup-swap.service
%systemd_post sshd.socket
%systemd_post oneshot-root-late-sdk.service
%systemd_post sdk-freespace.service
# this could be mounted read-only so to avoid a
# cpio: chmod failed - Read-only file system
if [ $1 -eq 1 ] ; then
[ -d %{_sysconfdir}/ssh/authorized_keys ] || install -d %{_sysconfdir}/ssh/authorized_keys 2>/dev/null || :
fi

%postun -n sdk-vm
%systemd_postun

%post -n sdk-resize-rootfs
%systemd_post resize-rootfs.service

%files -n sdk-chroot
%defattr(-,root,root,-)
/mer-sdk-chroot
/mer-bash-setup
%{_bindir}/sdk-version
/home/.zypp-cache
%{_sysconfdir}/mer-sdk-chroot
%dir /srv/mer/targets
%dir /srv/mer/toolings
%{_sysconfdir}/zypp/systemCheck.d/sdk-chroot.check

%files -n sdk-vm
%defattr(-,root,root,-)
%{_bindir}/sdk-version
%{_bindir}/sdk-info
%{_bindir}/sdk-setup-enginelan
%{_bindir}/sdk-shutdown
%{_bindir}/dynexecfs
%{_libexecdir}/%{name}/workspace-autodetect
%{_libexecdir}/%{name}/sdk-setup-env
/home/.zypp-cache
%{_unitdir}/information.service
%{_unitdir}/sdk-enginelan.service
%{_unitdir}/host_home.service
%{_unitdir}/host_install.service
%{_unitdir}/host_targets.service
%{_unitdir}/workspace.service
%{_unitdir}/workspace-raw@.service
%{_unitdir}/workspace-dynexec@.service
%{_unitdir}/workspace-dynexec-docker@.service
%{_unitdir}/sdk-setup-env.service
%{_unitdir}/etc-mersdk-share.service
%{_unitdir}/etc-ssh-authorized_keys.mount
%{_unitdir}/sdk-refresh.service
%{_unitdir}/sdk-refresh.timer
%{_unitdir}/sdk-setup-swap.service
%{_unitdir}/dbus.socket.d/sdk.conf
%{_unitdir}/oneshot-root-late-sdk.service
%{_unitdir}/sdk-freespace.service
%config %{_sysconfdir}/systemd/system/default.target
%config %{_sysconfdir}/udev/rules.d/80-net-setup-link.rules
%config %{_sysconfdir}/ssh/ssh-env.conf
%config %{_sysconfdir}/ssh/sshd_config_engine
%config %{_sysconfdir}/mersdk.env.systemd
%config %{_sysconfdir}/profile.d/sdk-vm.sh
%config %{_sysconfdir}/dbus-1/system.d/sdk.conf
%dir /home/deploy
%{_sysconfdir}/mer-sdk-vbox
%attr(-,mersdk,mersdk) %{_sysconfdir}/mersdk/
%{_sysconfdir}/zypp/systemCheck.d/sdk-vm.check
%{_sysconfdir}/modprobe.d/blacklist-vboxvideo.conf

%files -n sdk-resize-rootfs
%defattr(-,root,root,-)
%{_bindir}/resize-rootfs
%{_unitdir}/resize-rootfs.service

%files -n sdk-tooling-chroot
%defattr(-,root,root,-)
/mer-tooling-chroot

%files -n sdk-sb2-config
%defattr(-,root,root,-)
%{_datadir}/scratchbox2/modes/*

%files -n sdk-utils
%defattr(-,root,root,-)
%{_bindir}/git-change-log
%{_bindir}/mb
%{_bindir}/mb2
%{_bindir}/qb
%{_bindir}/sdk-foreach-su
%{_bindir}/sdk-manage
%{_bindir}/sdk-assistant
%{_bindir}/updateQtCreatorTargets
%{_bindir}/sdk-motd
%{_bindir}/rpmvalidation.sh
%{_bindir}/rpmvalidation
%{_bindir}/git-lltb
%{_bindir}/sdk-init
%{_bindir}/sdk-make-qmltypes
%{_libexecdir}/%{name}/oomadvice
%{_libexecdir}/%{name}/sdk-setup-swap
%{_libexecdir}/%{name}/ssh-askpass
%config %{_sysconfdir}/ssh/ssh_config.sdk
%config %{_sysconfdir}/bash_completion.d/mb2.bash
%config %{_sysconfdir}/bash_completion.d/sdk-assistant.bash
%{_datadir}/%{name}/README.tips.wiki

%files -n sdk-mer-branding
%defattr(-,root,root,-)
%{_datadir}/plymouth/splash.png
%{_sysconfdir}/sysconfig/splashfontcol
%{_sysconfdir}/sdk-welcome-message

%files -n connman-configs-mersdk-emul
%defattr(-,root,root,-)
%{_sysconfdir}/connman/main.conf
