#!/usr/bin/env bash
#Selective initialization of submodules
#Written by by Marko Kosunen, marko.kosunen@aalto.fi, 2017
DIR=$( cd `dirname $0` && pwd )
SUBMODULES="\
    ./Entities/verilog \
    ./Entities/vhdl \
    ./Entities/thesdk \
    ./Entities/thesdk_helpers \
    ./Entities/inverter \
    ./Simulations/Slidetemplate \
    ./Simulations/Simtemplate"

git submodule sync
for mod in $SUBMODULES; do 
    git submodule update --init $mod
    cd ${mod}
    if [ -f ./init_submodules.sh ]; then
        ./init_submodules
    fi
    cd ${DIR}

done
exit


