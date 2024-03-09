#!/bin/sh -l
#############################################################################
# This is a documentation builder script for TheSyDeKick

# 
# Written by Marko Kosunen, marko.kosunen@aalto.fi, 2022
#############################################################################

help_f()
{
cat << EOF    
build_docs Release 1.0 (1.11.2022)
For building documentationof  TheSyDeKick releases
Written by Marko Pikkis Kosunen

SYNOPSIS
  build_docs.sh [OPTIONS]
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

#if [ -z "${BRANCH}" ]; then
#    echo "Branch not given"
#    exit 1
#fi

if [ -z "$TOKEN" ]; then
    echo "Token must be provided for CI/CD"
    exit 1
fi
# Assumption is that we are working in the cloe of this project.

# Local pip-installations to follow the dependencies of the main program
#mkdir ${HOME}/.local
#mkdir ${HOME}/.local/bin
#PATH="${PATH}:${HOME}./local:${HOME}/.local/bin"

#if [ -d ./thesdk_template ]; then
#    rm -rf ./thesdk_template
#fi
#
#
#git clone https://github.com/TheSystemDevelopmentKit/thesdk_template.git 
#PYTHONPATH="$(pwd)/thesdk_template/Entities"
#export PYTHONPATH
#
#cd ./thesdk_template
#git checkout v1.8_RC
#git pull

git config --global --add safe.directory /__w/thesdk_template/thesdk_template
# Normal workflow
./configure
sed -i 's#\(url = \)\(git@\)\(.*\)\(:\)\(.*$\)#\1https://\3/\5#g' .gitmodules \
    && git submodule sync \
    && git submodule update --init

#./pip3userinstall.sh

cd ./doc
./configure
make html

# Let's push the docs to the docs project
# There might be a more clever way to do this.
git clone https://github.com/TheSystemDevelopmentKit/docs.git
cd docs && git checkout main && git pull
cp -rp ../build/html/* ./
git add -A
if [ "$CICD" == "1" ]; then
    git config --global user.name "ecdbot"
    git config --global user.email "${GITHUB_ACTOR}@noreply.github.com"
fi

git commit -m"Update docs" 

# We ´push this to a different place than this project.
git remote set-url origin "https://x-access-token:${TOKEN}@github.com/TheSystemDevelopmentKit/docs.git"

echo "Pushing to https://x-access-token:${TOKEN}@github.com/TheSystemDevelopmentKit/docs.git"
git push 

exit 0

