#!/bin/bash

for binDep in $(find -type f -exec sed -n '/.*\/bin\/.*\+/ { s,.*bin/\([[:alnum:]\-]\+\).*,\1,;p}' '{}' ';'  | sort -u) dhclient; do
	binPath=$(which $binDep)
	[ -n "$binPath" ] && echo $binPath OK || echo $binDep KO
done

echo "!!! CHECK THE PATH OF DHCLIENT !!!"
