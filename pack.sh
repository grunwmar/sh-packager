#!/usr/bin/env bash
log () {
  DATETIME=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "$DATETIME $1"
  echo -e "$DATETIME $1">> "$SHDIR/history.log"
}

START_TIME=$(date +%s)
WD="$PWD" # location project directory
DIRNAME=$(basename "$WD") # name of project directory
SHDIR=$(dirname ${BASH_SOURCE[0]}) # location of packager
COMPRESSION_OPT="z"
COMPRESSION_NAME="gzip"

if [ "$1" = "-c" ] && ! [ -z "$2" ]; then
  case "$2" in
    "gz")
      COMPRESSION_OPT="z"
      COMPRESSION_NAME="gzip"
      ;;

    "xz")
      COMPRESSION_OPT="J"
      COMPRESSION_NAME="xz/lzma2"
      ;;

    "bz2")
      COMPRESSION_OPT="j"
      COMPRESSION_NAME="bzip2"
      ;;

    *)
      COMPRESSION_OPT="z"
      COMPRESSION_NAME="gzip"
      ;;
  esac
fi

COMPRESSION_METHOD="c"$COMPRESSION_OPT"f"

log "** Packing '"$WD"'"
cd ..

SHNAME="$DIRNAME".sh
B64NAME="$DIRNAME".b64

TMP_TARPATH="$PWD"/"tmp_$DIRNAME".tarpkg
TMP_B64PATH="$PWD"/"tmp_$DIRNAME".tarpkg64
EXCLUDEFILE_PREDEF="$SHDIR"/"_exclude.txt"
EXCLUDEFILE="$WD"/"exclude.txt"

if [ -d "$WD/venv" ]; then
    log "Freezing requirements"
    "$WD"/venv/bin/pip freeze > "$WD"/requirements.txt
fi

log "Compressing by ${COMPRESSION_NAME^^} method..."
if [ -f "$EXCLUDEFILE" ]; then
    log "Using exclude file $EXCLUDEFILE"
    tar $COMPRESSION_METHOD "$TMP_TARPATH" --exclude-from="$EXCLUDEFILE_PREDEF" --exclude-from="$EXCLUDEFILE" -C $PWD "$DIRNAME"
else
    tar $COMPRESSION_METHOD "$TMP_TARPATH" --exclude-from="$EXCLUDEFILE_PREDEF" -C $PWD "$DIRNAME"
fi
log "Compressed."

cat "$TMP_TARPATH" | base64 > "$TMP_B64PATH"

export APPPACK_WD="$WD"
export APPPACK_DIRNAME="$DIRNAME"
export APPPACK_B64PATH="$TMP_B64PATH"
export APPACK_COMPRESSION="$COMPRESSION_OPT"

rm "$TMP_TARPATH"
python3 "$SHDIR/make_sh.py"
chmod +x "$WD/$DIRNAME.pkgsh"
rm "$TMP_B64PATH"

export APPPACK_WD=""
export APPPACK_DIRNAME=""
export APPPACK_B64PATH=""
export APPACK_COMPRESSION=""
END_TIME=$(date +%s)
DURATION=$(( END_TIME - START_TIME ))
log "Directory '$DIRNAME' packed as '$WD/$DIRNAME.pkgsh' in $DURATION sec."
log "Done. **\n"
