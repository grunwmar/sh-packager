#!/usr/bin/env bash

WD="$PWD"
DIRNAME=$(basename "$WD")

echo $DIRNAME
cd ..
echo $PWD

SHNAME="$DIRNAME".sh
B64NAME="$DIRNAME".b64

TMP_TARPATH="$PWD"/"tmp_$DIRNAME".tar.gz
TMP_B64PATH="$PWD"/"tmp_$DIRNAME".b64

tar czf "$TMP_TARPATH" --exclude="venv" --exclude="env" --exclude="pyenv" --exclude="python" --exclude="__pycache__" --exclude=".git" -C $PWD "$DIRNAME"
cat "$TMP_TARPATH" | base64 > "$TMP_B64PATH"

export APPPACK_WD="$WD"
export APPPACK_DIRNAME="$DIRNAME"
export APPPACK_B64PATH="$TMP_B64PATH"

rm "$TMP_TARPATH"
python3 make_sh.py
rm "$TMP_B64PATH"
