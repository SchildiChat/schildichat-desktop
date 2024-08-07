#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"

# Update patches?
if [ "$1" = "-u" ]; then
    keep_patches=0
    shift
else
    keep_patches=1
fi

pushd "$mydir" > /dev/null

source ./merge_helpers.sh

# Persist current state
if [ "$keep_patches" = 0 ]; then
    ./generate_patches.sh
fi

# Abandon all local submodule state
forall_repos git reset --hard
git submodule update -f --recursive

# Fetch upstream
forall_repos git fetch upstream

# Check if specific version to merge passed
if [ -z "$1" ]; then
    get_latest_upstream_tag
else
    latest_upstream_tag="$1"
fi
forelement_repos git checkout "$latest_upstream_tag"

get_current_mxsdk_tags

pushd "matrix-js-sdk" > /dev/null
git checkout "$current_mxjssdk_tag"
popd > /dev/null

pushd "matrix-react-sdk" > /dev/null
git checkout "$current_mxreactsdk_tag"
popd > /dev/null

# Refresh environment
make clean
make setup

./apply_patches.sh

popd > /dev/null
