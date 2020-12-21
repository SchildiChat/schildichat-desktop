#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"
branch=${BRANCH:-"sc"}

pushd "$mydir" > /dev/null

source ./merge_helpers.sh

check_branch $branch
forall_repos check_branch $branch

forall_repos git fetch upstream
forall_repos git merge upstream/master

# Automatic theme update
pushd "matrix-react-sdk" > /dev/null
./theme.sh
popd > /dev/null

# Refresh environment
make clean
make setup

popd > /dev/null
