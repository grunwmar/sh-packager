#!/bin/bash
B64TARCHIVE=$(cat <<-TAR64
H4sIAAAAAAAAA+1XbW/bNhDOZ/6KG2dAdlfLli3bwFIXc5MUCdpmXl5WDHEhKDIdabFeJsmJnSz/
fUeKerETbwOWtijG54MtHY/HI+/43ElPXCuynWv7isWtnc+DNmIw6PF/Y9BrV/9z7Bhm1+ybhtHr
mTtto9s2OjvQ+0z+rGGRpHYMsHPH5ixYbdf7p/FvFHo1/vwBBc+9hoh/b2v8DaNjyvhjmhgoN8xO
H+Pffm5HnsL/PP7ff9daJHHr0gtaLLiBSztxCfm4P6S18cd9SvaPTo5HHw6GtTqOsMD2GdAaDjTI
6SGOoXzqxVLcRilhjhtCTU4jzhR0XcrQHsFZwhzNNSimG3nTNzell32TkLMPY+tsdDIenR1Kf1o0
9SOrVMPQ6Vd3QhGN/I2isMcD7dzN0NWKZQrNJls688WUDekNnsGaYPM9Wj2WpG4YrIksK1o5tuMy
y1qT61deioI9cRZQ7pY4drrp1J88FKxvwms5IvdH8YiXURinMBqPx6O9d5YIFo/VhjwPXWWdDY3y
yNYXiP0Nb0i2yS6KRdhpy7evmZW4erQqtQsDXzunFf491vj/6Pj0bPT+/XOXAE7y/b65tf6bg0FR
/7ttwf9mz1D8/yXwFP9zYqe1w5+RMlrV/CDeDC6gOc2oi8KnXUhdFhAAwfB034uZk4bxCiZCY0LB
nsfMnq6ALb0kTXQ4WHqpruuUz8FHMvMI8a+xhkibhDgR6HkjIoX5azZWUk8+XCEj6SLneO5/S+cb
ip3Hvtpzz04gcaPrq+GETqT2E80QTGo/TSiF1683bXLnv3b4/jPWtlwe5LOuIe6/ufX+d7rtXnH/
+1n/N1D935eB54uWIEyIfEpWCSFkymbg215Qb/yIVwbgNoyvveDK4jd1iNo6koUXh8GFVrYh2ieh
mjeET6vJXkTqYluG2Ze6W5RlR4HKQhvvKmanVVrnU/XfQ3Sz4t9LmGn30okHHed4QZJimmuNzEoa
r7I9iX15uHgYsaCeu/IStFhrAJLDzCj1cmd5rgxxROe0Vm+IcezvWJTCW2/OjsP0bbgIpuXEKPaC
tD6jfBS0+3yVBw2CMIUZVy5ZsVFMwyjonCDrhvS6dLRyCujrrfS1Uy6ZuMOZpmnI7JzVBaPjQWIv
t3d49Ctv5Xm7+epVEyXYFd/LbT1kr41dQk7Oj08PSz3xSpJwETsM+Zf3yMKy7aTejZ0y2R2CZlk8
ZSyLUzOyppYZEia3tfJFoIpePvtaaOIHxaTd7V4Y/osXcB5wisL4gpYJd7sdv5gqRG1fqmsg6Qyk
nO5mJmmtcgqVBrvZnDInnLKi0y663g1Pdrtdn4qPiOby7mbzM2JDG9d9oo/G7yFabrmsVjH7Y4HF
02cBFsl0mVbKVV6wjjCL7fmcHwLeknRhz0HeFz4LMykG2aWL6gr5GzR94CETP2KgEsLIi8DLDEMz
fuRGZfmaiCWWQYgXAa/FfMhx/XAKPyxzGa/mm+HbDwOml0eC1wZ+OT86e3fwW5GwmKzF86yj38Ze
yuqJi5nPD8gSqW5ZMBwCzVOMZumeUdS3X4UVFBQUFBQUFBQUFBQUFBQUFBQUFJ4ffwFrWhP3ACgA
AA==
TAR64
);

RUNSH=$(cat <<-RUNSH
source ./venv/bin/activate
python '__main__.py \$@'
RUNSH
);

TMP_TARPATH="$PWD"/"tmp_.sh_packager".tar.gz

echo -e "[1m** Unpacking '[1;32m.sh_packager[0m[1m' package [0m";
echo "$B64TARCHIVE" | base64 --decode > "$TMP_TARPATH"
echo -e "[1;33m"
tar -xzvf "$TMP_TARPATH"
echo -e "[0m"
rm "$TMP_TARPATH"
cd ".sh_packager"

if [ -f requirements.txt ]; then
    echo "Installing virtual environment for python3."
    python3 -m venv venv
    ./venv/bin/pip install -r requirements.txt
    echo "$RUNSH" > run.sh
    chmod +x run.sh
fi

echo -e "[1mDone.[0m"
read QUITKEY
        