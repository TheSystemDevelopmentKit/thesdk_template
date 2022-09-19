#!/bin/sh -l
#############################################################################
# This is a documentation builder script for TheSyDeKick
# 
# Written by Marko Kosunen, marko.kosunen@aalto.fi, 2022
#############################################################################


# Token we use for push is given as the first argument
TOKEN=$1

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

# Normal workflow
./configure
sed -i 's#\(url = \)\(git@\)\(.*\)\(:\)\(.*$\)#\1https://\3/\5#g' .gitmodules \
    && git submodule sync \
    && git submodule update --init

#./pip3userinstall.sh

cd ./doc
make html

# Let's push the docs to the docs project
# There might be a more clever way to do this.
git clone https://github.com/TheSystemDevelopmentKit/docs.git
cd docs && git checkout main && git pull
cp -rp ../build/html/* ./
git add -A
git config --global user.name "ecdbot"
git config --global user.email "${GITHUB_ACTOR}@noreply.github.com"
git commit -m"Update docs" 

# We ´push this to a different place than this project.
git remote set-url origin "https://x-access-token:${TOKEN}@github.com/TheSystemDevelopmentKit/docs.git"

echo "Pushing to https://x-access-token:${TOKEN}@github.com/TheSystemDevelopmentKit/docs.git"
git push 

exit 0

