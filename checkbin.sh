#!/bin/bash

for binDep in $(find -type f -exec sed -n '/.*\/bin\/.*\+/ { s,.*bin/\([[:alnum:]\-]\+\).*,\1,;p}' '{}' ';'  | sort -u) dhclient vconfig rdisc6; do
	binPath=$(/usr/bin/which $binDep)
	[ -n "$binPath" ] && echo $binPath OK || { toFind=(${toFind[@]} "$binDep") ; echo $binDep KO; }
done

for bin2Find in ${toFind[@]}; do
	/usr/lib/command-not-found --no-failure-msg -- "$bin2Find"
done 2>&1 | grep sudo
