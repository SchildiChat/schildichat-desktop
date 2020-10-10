#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"

pushd "$mydir" > /dev/null

source ./merge_helpers.sh


forall_repos git fetch upstream
forall_repos git merge upstream/master

popd > /dev/null
