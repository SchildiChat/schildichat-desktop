#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"
pushd "$mydir" > /dev/null

source ./merge_helpers.sh

persist_patches() {
    local repo="$(realpath "$1")"
    local patch_dir="$SCHILDI_ROOT/patches/$(basename "$1")"
    if [ ! -d "$repo" ]; then
        echo "Unknown repo: $repo"
        return 1
    fi

    pushd "$repo"

    if [ -d "$patch_dir" ]; then
        echo "Clearing old patches..."
        rm "$patch_dir"/*
    else
        echo "Creating new patch dir $patch_dir..."
        mkdir "$patch_dir"
    fi
    echo "Creating new patches"
    git format-patch -k upstream/master.. -o "$patch_dir"
    echo "Clearing automated commits from patches"
    find "$patch_dir" -name "*-Automatic-package.json-adjustment.patch" -exec rm {} \;
    find "$patch_dir" -name "*-Update-version-to-*.patch" -exec rm {} \;
    popd
}

persist_patches element-desktop
#persist_patches element-web
persist_patches matrix-react-sdk

popd > /dev/null
