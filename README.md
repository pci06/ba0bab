# ba0bab
These scripts aim to configure easily an IPv4/IPv6 (w/ Dynamic Prefix) box for Orange ISP
 for a Debian like distribution.

Directories description:

- original/
Contains source configuration to be customized by genconfig.sh

- systemd
Contains a radvd systemd unit
Don't forget to:
systemctl daemon-reload && systemctl enable myradvd.service


Scripts:
checkbin.sh: check the necessary binaries
genconfig.sh: helper to generate your configuration
