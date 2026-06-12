#!/usr/bin/env bash
#############################################################################
# Selective initialization of submodules
# Written by by Marko Kosunen, marko.kosunen@aalto.fi, 2017
# Improved with parallezation by Aleksi Korsman, 13.6.2026
#############################################################################
set -euo pipefail

help_f()
{
SCRIPTNAME="init_submodules.sh"
cat << EOF
${SCRIPTNAME} Release 1.0
$(echo ${SCRIPTNAME} | tr [:upper:] [:lower:])-basic setups for you unix environment"
Written by <name>

SYNOPSIS
$(echo ${SCRIPTNAME} |  tr [:upper:] [:lower:])  [OPTIONS]
DESCRIPTION
    Configures the chip compilation flow .

OPTIONS
  -j
      [INT] Number of parallel jobs. Default 8
  -h
      Show this help.
EOF
}

DIR=$( cd `dirname $0` && pwd )
JOBS=8
while getopts j:h opt
do
  case "$opt" in
    j) JOBS=${OPTARG};;
    h) help_f; exit 0;;
    \?) help_f;;
  esac
done

SUBMODULES="\
    ./Entities/momem \
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
    ./doc/TheSyDeKick_tutorial \
"

if [ -d "${DIR}/.githooks" ]; then
    git config --local core.hooksPath .githooks/
fi

cd ${DIR}

# Phase 1: register + fetch/checkout everything in ONE call.
# --jobs parallelizes this safely; separate concurrent calls would
# race on .git/config.lock and .git/index.lock.
git submodule sync
git submodule update --init --jobs "$JOBS" $SUBMODULES

# Phase 2: run each module's own init script in parallel.
# Each touches a separate repo -> no shared-lock contention.
printf '%s\n' $SUBMODULES \
    | xargs -P "$JOBS" -I {} \
    bash -c '
        mod="$1"
        dir="$2"
        if [ -f "$dir/$mod/init_submodules.sh" ]; then
            cd "$dir/$mod" && ./init_submodules.sh
        fi
      ' _ {} "${DIR}"
exit 0

