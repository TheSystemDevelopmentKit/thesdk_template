#!/bin/sh -l
#############################################################################
# Test and relesase script for TheSyDeKick
# Intended operation: When pushed to the latest release-candidate branch
# The particular module is updated to the HEAD of thesdk_template and the operation 
# is tested by running the inverter selftest (probably other tests in the future)
# If the tests are passed, the resulting updated thesdk_template module is pushed to
# the latest development branch.
# 
# Written by Marko Kosunen, marko.kosunen@aalto.fi, 18.9.2022
#############################################################################

help_f()
{
cat << EOF    
test_and_release Release 1.0 (18.09.2022)
For testing and releasing TheSyDeKick releases
Written by Marko Pikkis Kosunen

SYNOPSIS
  test_and_release.sh [OPTIONS]
DESCRIPTION
   Defines and runs tests for the submodules of thesdk_template

OPTIONS
  .b 
     Branch of thesdk_template to operate on
     Commit and push to that branch after testing.

  -c Run in CI/CD with this option 
      .
  -t
     STRING : Access token 
  -h
      Show this help.
EOF
}


# Token we use for push is given as the first argument
CICD="0"
TOKEN=""
BRANCH=""
while getopts b:ct:h opt
do
  case "$opt" in
    b) BRANCH="$OPTARG";;
    c) CICD="1";;
    t) TOKEN="$OPTARG";;
    h) help_f; exit 0;;
    \?) help_f;;
  esac
done

if [ -z "${BRANCH}" ]; then
    echo "Branch not given"
    exit 1
fi

if [ -z "$TOKEN" ]; then
    echo "Token must be provided for CI/CD"
    exit 1
fi

# Assumption is that we are working in the clone of the submodule project.
WORKDIR=$(pwd)
PID="$$"
ENTITY="$(git remote get-url origin | sed -n 's#\(.*/\)\(.*\)\(.git\)#\2#p')"
HASH="$(git rev-parse --verify HEAD)"
MESSAGE="$(git log -1 --pretty=%B | head -n 1)"

git clone https://github.com/TheSystemDevelopmentKit/thesdk_template.git ./thesdk_template_${PID}
PYTHONPATH="$(pwd)/thesdk_template_${PID}/Entities"
export PYTHONPATH

cd ${WORKDIR}/thesdk_template_${PID}
TEMPLATEDIR="$(pwd)"
git checkout "$BRANCH"
git pull

# Local pip-installations to follow the dependencies of the main program
mkdir ${HOME}/.local
mkdir ${HOME}/.local/bin
PATH="${PATH}:${HOME}./local:${HOME}/.local/bin"

# Normal workflow
./configure
sed -i 's#\(url = \)\(git@\)\(.*\)\(:\)\(.*$\)#\1https://\3/\5#g' .gitmodules \
    && git submodule sync \
    && git submodule update --init

./pip3userinstall.sh

cd ./Entities/${ENTITY}
git checkout ${HASH}

cd $TEMPLATEDIR
# Let's perform the test(s)
cd ${TEMPLATEDIR}/Entities/inverter && ./configure &&  make sim
SIMSTAT=$?
cd ${TEMPLATEDIR}/Entities/inverter && ./configure &&  make doc
DOCSTAT=$?

if [ "$SIMSTAT" !=  "0" ] \
    || [ "$DOCSTAT" !=  "0" ]; then
    STATUS="1"
    echo "Tests failed"
else 
    STATUS="0"
    echo "Tests OK, proceeding"
fi

if [ "$STATUS" == "0" ]; then
    cd $TEMPLATEDIR
    echo "Staging ./Entities/${ENTITY}"
    git add ./Entities/${ENTITY}

    echo "Committing ./Entities/${ENTITY}"
    COMMITMESSAGE="$(echo -e "Update Entity ${ENTITY}:\n\n"$MESSAGE"\n\n")"
    echo "$COMMITMESSAGE"
    git commit -m"$COMMITMESSAGE"
    if [ ${CICD} == "1" ]; then 
        git config --global user.name "ecdbot"
        git config --global user.email "${GITHUB_ACTOR}@noreply.github.com"
    fi
    git remote set-url origin "https://x-access-token:${TOKEN}@github.com/TheSystemDevelopmentKit/thesdk_template.git"
    git push 
fi
cd ${WORKDIR} && rm -rf ./thesdk_template_${PID} 
exit $STATUS

