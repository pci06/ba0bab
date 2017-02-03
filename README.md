# ba0bab
These scripts aim to configure easily an IPv4/IPv6 (w/ Dynamic Prefix) box for Orange ISP
 for a Debian like distribution.

## Directories description:

- original/
Contains source configuration to be customized by genconfig.sh

- systemd
Contains a radvd systemd unit

**Don't forget to:**
systemctl daemon-reload && systemctl enable myradvd.service


## Scripts:
- checkbin.sh: check the necessary binaries
- genconfig.sh: helper to generate your configuration


## Links have to be created:

- /etc/dhcp/dhclient-exit-hooks.d/02-update-radvd -> /etc/dhcp/orange/dhclient-exit-hooks.d/02-update-radvd
- /etc/dhcp/dhclient-enter-hooks.d/01-orange-bound4 -> /etc/dhcp/orange/dhclient-enter-hooks.d/01-orange-bound4
- /etc/dhcp/dhclient-enter-hooks.d/01-orange-bound6 -> /etc/dhcp/orange/dhclient-enter-hooks.d/01-orange-bound6


Command to link:

    ln -s /etc/dhcp/orange/dhclient-exit-hooks.d/02-update-radvd /etc/dhcp/dhclient-exit-hooks.d/02-update-radvd ;
    ln -s /etc/dhcp/orange/dhclient-enter-hooks.d/01-orange-bound4 /etc/dhcp/dhclient-enter-hooks.d/01-orange-bound4 ;
    ln -s /etc/dhcp/orange/dhclient-enter-hooks.d/01-orange-bound6 /etc/dhcp/dhclient-enter-hooks.d/01-orange-bound6 ;

