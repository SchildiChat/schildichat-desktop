#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"
branch=${BRANCH:-"sc"}

i18n_helper="node i18n-helper/index.js"
i18n_path="src/i18n/strings"
i18n_overlay_path="i18n-overlays"

pushd "$mydir" > /dev/null

source ./merge_helpers.sh

check_branch $branch
forall_repos check_branch $branch

# check_clean_git
forall_repos check_clean_git

# Automatic i18n reversion
pushd "matrix-react-sdk" > /dev/null
revert_i18n_changes "$i18n_path"
popd > /dev/null

pushd "element-web" > /dev/null
revert_i18n_changes "$i18n_path"
popd > /dev/null

pushd "element-desktop" > /dev/null
revert_i18n_changes "$i18n_path"
popd > /dev/null

# Merge
forall_repos git fetch upstream
forall_repos git merge upstream/master

# Automatic i18n adjustment
$i18n_helper "matrix-react-sdk/$i18n_path" "$i18n_overlay_path/matrix-react-sdk"
pushd "matrix-react-sdk" > /dev/null
apply_i18n_changes "$i18n_path"
popd > /dev/null

$i18n_helper "element-web/$i18n_path" "$i18n_overlay_path/element-web"
pushd "element-web" > /dev/null
apply_i18n_changes "$i18n_path"
popd > /dev/null

$i18n_helper "element-desktop/$i18n_path" "$i18n_overlay_path/element-desktop"
pushd "element-desktop" > /dev/null
apply_i18n_changes "$i18n_path"
popd > /dev/null

# Automatic theme update
pushd "matrix-react-sdk" > /dev/null
./theme.sh
popd > /dev/null

# Refresh environment
make clean
make setup

popd > /dev/null
