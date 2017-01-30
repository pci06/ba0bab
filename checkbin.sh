#!/bin/bash

for binDep in $(find -type f -exec sed -n '/.*\/bin\/.*\+/ { s,.*bin/\([^ ]\+\).*,\1,;p}' '{}' ';'  | sort -u); do
	binPath=$(which $binDep)
	[ -n "$binPath" ] && echo $binPath OK || echo $binDep KO
done
