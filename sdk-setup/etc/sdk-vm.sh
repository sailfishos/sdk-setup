eval $(systemctl show-environment |sed -n '/^SAILFISH_SDK_/s/^/export /p')
