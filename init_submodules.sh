#!/usr/bin/env bash
#Selective initialization of submodules
#Written by by Marko Kosunen, marko.kosunen@aalto.fi, 2017
DIR=$( cd `dirname $0` && pwd )
SUBMODULES="\
    ./Entities/ads \
    ./Entities/rtl \
    ./Entities/spice \
    ./Entities/thesdk \
    ./Entities/inverter \
    ./Entities/inverter_testbench \
    ./Entities/inverter_tests \
    ./Entities/myentity \
    ./Entities/register_template \
    ./thesdk_helpers \
    ./doc/TheSyDeKick-roadshow \
"

git submodule sync
for mod in $SUBMODULES; do 
    git submodule update --init $mod
    cd ${mod}
    if [ -f ./init_submodules.sh ]; then
        ./init_submodules.sh
    fi
    cd ${DIR}

done
exit 0


