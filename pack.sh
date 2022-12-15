#!/usr/bin/env bash

WD="$PWD" # location project directory
DIRNAME=$(basename "$WD") # name of project directory
SHDIR=$(dirname ${BASH_SOURCE[0]}) # location of packager

echo "** Packing '"$WD"'."
cd ..

SHNAME="$DIRNAME".sh
B64NAME="$DIRNAME".b64

TMP_TARPATH="$PWD"/"tmp_$DIRNAME".tarxz
TMP_B64PATH="$PWD"/"tmp_$DIRNAME".tarxz64
EXCLUDEFILE_PREDEF="$SHDIR"/"exclude.txt"
EXCLUDEFILE="$WD"/"exclude.txt"

if [ -f "$EXCLUDEFILE" ]; then
    echo "Using exclude file $EXCLUDEFILE"
    tar cJf "$TMP_TARPATH" --exclude-from="$EXCLUDEFILE_PREDEF" --exclude-from="$EXCLUDEFILE" -C $PWD "$DIRNAME"
else
    tar cJf "$TMP_TARPATH" --exclude-from="$EXCLUDEFILE_PREDEF" -C $PWD "$DIRNAME"
fi

cat "$TMP_TARPATH" | base64 > "$TMP_B64PATH"

export APPPACK_WD="$WD"
export APPPACK_DIRNAME="$DIRNAME"
export APPPACK_B64PATH="$TMP_B64PATH"

rm "$TMP_TARPATH"
python3 "$SHDIR/make_sh.py"
chmod +x "$WD/$DIRNAME.pkgsh"
rm "$TMP_B64PATH"

export APPPACK_WD=""
export APPPACK_DIRNAME=""
export APPPACK_B64PATH=""
echo "Directory '$DIRNAME' packed as '$WD/$DIRNAME.pkgsh'"
echo "Done."
