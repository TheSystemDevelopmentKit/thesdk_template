#!/bin/sh -l
#############################################################################
# Test and relesase script for TheSyDeKick thesdk_template
# Intended operation: When pushed to the latest release-candidate branch
# The all major Entity submodules are updated to the HEAD of thesdk_template and the operation 
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
  -b 
     Branch of thesdk_template to operate on
     Commit and push to that branch after testing.

  -c Run in CI/CD with this option 

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

if [ -z "$TOKEN" ] && [ ${CICD} == "1" ]; then
    echo "Token must be provided for CI/CD"
    exit 1
fi

PID="$$"
#If not in CICD, we will make a test clone.
if [ "$CICD" != "1" ]; then
    git clone git@github.com:TheSystemDevelopmentKit/thesdk_template.git ./thesdk_template_${PID}
    cd ./thesdk_template_${PID}
    WORKDIR=$(pwd)
    git checkout "$BRANCH"
    git pull
else
    git config --global --add safe.directory /__w/thesdk_template/thesdk_template
    WORKDIR=$(pwd)
fi
# Assumption is that we are working in the latest commit of thesdk_template.
#ENTITY="$(git remote get-url origin | sed -n 's#\(.*/\)\(.*\)\(.git\)#\2#p')"
HASH="$(git rev-parse --verify HEAD)"
MESSAGE="$(git log -1 --pretty=%B | head -n 1)"

PYTHONPATH="$(pwd)/Entities"
export PYTHONPATH

# For local pip-installations to follow the dependencies of the main program
mkdir -p ${HOME}/.local/bin
PATH="${PATH}:${HOME}./local:${HOME}/.local/bin"
TEMPLATEDIR="$(pwd)"

# Normal workflow
./configure
# change ssh submodule urls to git
if [ "$CICD" == "1" ]; then
    sed -i 's#\(url = \)\(git@\)\(.*\)\(:\)\(.*$\)#\1https://\3/\5#g' .gitmodules
fi
#Init the submodules as user would
#Currently fails on ssh cloned subsubmodules
${WORKDIR}/init_submodules.sh

# Test the dependency installation
# These are already in the buildimage
#./pip3userinstall.sh

SUBMODULES="$(sed -n '/\[submodule/p' .gitmodules | sed -n 's/.* \"\(.*\)\"]/\1/p' | xargs)"
UNDERDEVEL=""
for entity in ${SUBMODULES}; do 
    echo "In $entity:"
    cd ${WORKDIR}/${entity} 
    CURRENT="$(git rev-parse HEAD)"
    git checkout ${BRANCH} 2> /dev/null
    if [ "$?" == "0" ]; then
        git pull
        UPDATED="$(git rev-parse HEAD)"
        if [ "${UPDATED}" != "${CURRENT}" ]; then 
            UNDERDEVEL="${UNDERDEVEL} ${entity}"
        fi
    else
        echo "Branch ${BRANCH} does not exist for submodule ${entity}. No changes made."
    fi
    cd ${WORKDIR}
done

cd $TEMPLATEDIR
# Let's perform the test(s)
cd ${TEMPLATEDIR}/doc && make html
DOCSTAT=$?

for entity in inverter myentity inverter_tests; do
    cd ${TEMPLATEDIR}/Entities/${entity} && ./configure &&  make sim
    SIMSTAT=$?
    if [ "$SIMSTAT" !=  "0" ] \
        || [ "$DOCSTAT" !=  "0" ]; then
        STATUS="1"
        echo "Tests failed in ${entity}"
        exit 1
    else 
        STATUS="0"
        echo "Tests OK in ${entity}, proceeding"
    fi
done

if [ "$STATUS" == "0" ]; then
    cd $TEMPLATEDIR
    for entity in ${UNDERDEVEL}; do 
        echo "Staging $entity"
        git add ${entity}
    done

    echo "Committing changes"
    MSG=""
    COMMITMESSAGE="$(
    cat << EOF
Auto update entities

$(for entity in ${UNDERDEVEL}; do
    echo $entity
done)
EOF
)"
    echo "$COMMITMESSAGE"
    if [ ${CICD} == "1" ]; then 
        git config --global user.name "ecdbot"
        git config --global user.email "${GITHUB_ACTOR}@noreply.github.com"
        git remote set-url origin "https://x-access-token:${TOKEN}@github.com/TheSystemDevelopmentKit/thesdk_template.git"
    fi
    git commit -m"$COMMITMESSAGE"
    git push 
fi
cd ${WORKDIR} && rm -rf ./thesdk_template_${PID} 
exit $STATUS

