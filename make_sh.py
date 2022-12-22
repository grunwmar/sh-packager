import os
import sys

def main():
    working_dir = os.environ['APPPACK_WD']
    dirname = os.environ['APPPACK_DIRNAME']
    b64_path = os.environ['APPPACK_B64PATH']
    pkg_sh_name = os.path.join(working_dir, f'{dirname}.pkgsh')
    compression_opt = os.environ['APPACK_COMPRESSION']

    try:
        with open(b64_path, 'r') as f1:
            b64_tar = f1.read()
    except FileNotFound:
        print(f"File '{b64_path}' not found. Exit...")
        sys.exit(1)

    with open(pkg_sh_name, 'w') as f2:
        sh=f'''#!/bin/bash
TS=$(date '+%Y-%m-%d_%H-%M-%S')
B64TARCHIVE=$(cat <<-TAR64
{b64_tar}TAR64
);
RUNSH=$(cat <<-RUNSH
source ./venv/bin/activate
python '__main__.py \$@'
RUNSH
);
ERRORS=0
WD="$PWD"

if [[ "$1" = "--path" ]]; then
    WD="$2"
    cd "$WD"
fi

TMP_TARPATH="$WD"/"tmp_{dirname}".tarpkg

log () {{
  DATETIME=$(date '+%Y-%m-%d %H:%M:%S')
  echo -e "$DATETIME $1"
  echo -e "$DATETIME $1">> "$WD/$TS""_{dirname.upper()}.log"
}}

check_status() {{
    if ! [ "$?" = "0" ]; then
        log "! An error occured !"
        ERRORS=1
    fi
}}


log "** Unpacking '{dirname}' package...";
echo "$B64TARCHIVE" | base64 --decode > "$TMP_TARPATH"
tar -x{compression_opt}vf "$TMP_TARPATH"
rm "$TMP_TARPATH"
cd "{dirname}"

if [ -f requirements.txt ]; then
    log "Creating virtual environment for python3."
    python3 -m venv venv

    source venv/bin/activate

    if ! [ -z $"$VIRTUAL_ENV" ]; then

        log "Upgrading pip."
        pip install --upgrade pip

        log "Installing packages to virtual environment."
        pip install -r requirements.txt

        if ! ([ -f "run.sh" ] || [ -f "run" ]); then
            if [ -f "__main__.py" ]; then
                echo "$RUNSH" > run.sh
                log "File 'run.sh' was created."
            fi
        fi

    fi
fi

if [ -f run.sh ]; then
    chmod +x run.sh
    log "File 'run.sh' was set executable."
fi

log "Done."
echo "-------------------------------------------"
echo -n "Directory: "
pwd
echo ""

ls
echo ""

if ! [ -z $(which notify-send) ]; then
        notify-send "Unpacked" "File \'$0\' unpacked."
    else
        log "Command 'notify-send' is not installed."
fi

if ! [ $ERRORS = "0" ]; then
    log "ERROR(S) OCCURED DURING INSTALLATION."
fi

echo "Press ENTER to exit..."
read QUIT
'''
        f2.write(sh)


if __name__ == "__main__":
    main()
