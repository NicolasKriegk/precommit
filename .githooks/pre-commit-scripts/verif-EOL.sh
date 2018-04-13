#!/bin/bash;D:/tools/shell/bash.exe

#recherche des fins de ligne: erreur si présence CR (format windows ou Mac)
if echo "$(file -b "$1")" | grep -iq 'CR'
then
	exit 1
fi
