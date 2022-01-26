#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"

pushd "$mydir" > /dev/null

source ./merge_helpers.sh

# Check branch
check_branch $branch
forall_repos check_branch $branch

# Ensure clean git state
forall_repos check_clean_git

# Fetch upstream
forall_repos git fetch upstream

# Automatic reversions
automatic_i18n_reversion
automatic_packagejson_reversion

# Merge upstream
get_latest_upstream_tag
forelement_repos git merge "$latest_upstream_tag"

get_current_mxsdk_tags

pushd "matrix-js-sdk" > /dev/null
git merge "$current_mxjssdk_tag"
popd > /dev/null

pushd "matrix-react-sdk" > /dev/null
git merge "$current_mxreactsdk_tag"
popd > /dev/null

# Refresh environment
make clean
make setup

# Automatic adjustments
automatic_i18n_adjustment
automatic_packagejson_adjustment

# Automatic theme update
pushd "matrix-react-sdk" > /dev/null
./theme.sh y
popd > /dev/null

popd > /dev/null
