#!/bin/sh;D:/tools/shell/sh.exe

echo Git rep: $1
git diff --staged --name-only > /dev/null

echo Erreur: Encoder les scripts SQL en UTF8 sans BOM

exit 0
