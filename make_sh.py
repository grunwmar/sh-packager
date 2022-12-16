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
B64TARCHIVE=$(cat <<-TAR64
{b64_tar}TAR64
);
RUNSH=$(cat <<-RUNSH
source ./venv/bin/activate
python '__main__.py \$@'
RUNSH
);
WD="$PWD"
if [[ "$1" = "--path" ]]; then
    WD="$2"
    cd "$WD"
fi
TMP_TARPATH="$WD"/"tmp_{dirname}".tarpkg
echo "** Unpacking '{dirname}' package...";
echo "$B64TARCHIVE" | base64 --decode > "$TMP_TARPATH"
tar -x{compression_opt}vf "$TMP_TARPATH"
rm "$TMP_TARPATH"
cd "{dirname}"
if [ -f requirements.txt ]; then
    echo "Installing virtual environment for python3."
    python3 -m venv venv
    ./venv/bin/pip install -r requirements.txt
    if ! ([ -f "run.sh" ] || [ -f "run" ]); then
        echo "$RUNSH" > run.sh
        chmod +x run.sh
    fi
fi
echo "Done."
echo "-------------------------------------------"
pwd
ls
echo ""
if ! [ -z $(which notify-send) ]; then
    notify-send "Unpacked" "File \'$0\' unpacked."
fi

'''
        f2.write(sh)


if __name__ == "__main__":
    main()
