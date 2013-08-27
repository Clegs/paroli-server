#!/bin/bash

# Modifies the output of the coffee compiler and makes sure
# that the right execute flags are set.

header='#!/usr/bin/env node'

for file in "$@"; do
	completeFile="build/$file"
	firstLine=`head -1 $completeFile`
	
	if [ "$firstLine" != "$header" ]; then
		sed -i "1i#!/usr/bin/env node\n" $completeFile
		chmod +x $completeFile
	fi
done

