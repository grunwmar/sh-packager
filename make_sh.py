import os
import sys


def main():
    working_dir = os.environ['APPPACK_WD']
    dirname = os.environ['APPPACK_DIRNAME']
    b64_path = os.environ['APPPACK_B64PATH']

    pkg_sh_name = os.path.join(working_dir, f'{dirname}.pkginst.sh')

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

TMP_TARPATH="$PWD"/"tmp_{dirname}".tar.gz

echo -e "\033[1m** Unpacking '\033[1;32m{dirname}\033[0m\033[1m' package \033[0m";
echo "$B64TARCHIVE" | base64 --decode > "$TMP_TARPATH"
echo -e "\033[1;33m"
tar -xzvf "$TMP_TARPATH"
echo -e "\033[0m"
rm "$TMP_TARPATH"
cd "{dirname}"

if [ -f requirements.txt ]; then
    echo "Installing virtual environment for python3."
    python3 -m venv venv
    ./venv/bin/pip install -r requirements.txt
    echo "$RUNSH" > run.sh
    chmod +x run.sh
fi

echo -e "\033[1mDone.\033[0m"
read QUITKEY
        '''
        f2.write(sh)


if __name__ == "__main__":
    main()
