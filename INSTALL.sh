#!/usr/bin/env bash
DIR="$HOME"/.sh_packager
if [ -d "$DIR" ]; then
  echo "Directory \"$DIR\" already exists. Exit..."
  exit
fi

mkdir "$DIR"

cp ./pack.sh "$DIR"/pack.sh
cp ./make_sh.py "$DIR"/make_sh.py

if [ -f "$HOME/.bashrc" ]; then
  echo "alias shpkg=\"\$HOME/.sh_packager/pack.sh \$@\"" >> "$HOME/.bashrc"
fi
