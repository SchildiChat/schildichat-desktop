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

./setup.sh

popd > /dev/null
