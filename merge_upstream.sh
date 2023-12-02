#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"

if [ "$1" = "--checkout" ]; then
    git_action=checkout
    shift
else
    git_action=merge
fi

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
if [ "$git_action" != "checkout" ]; then
    automatic_i18n_reversion
    automatic_packagejson_reversion
fi

# Merge upstream

# Check if specific version to merge passed
if [ -z "$1" ]; then
    get_latest_upstream_tag
else
    latest_upstream_tag="$1"
fi
forelement_repos git "$git_action" "$latest_upstream_tag"

get_current_mxsdk_tags

pushd "matrix-js-sdk" > /dev/null
git "$git_action" "$current_mxjssdk_tag"
popd > /dev/null

pushd "matrix-react-sdk" > /dev/null
git "$git_action" "$current_mxreactsdk_tag"
popd > /dev/null

# Refresh environment
make clean
make setup

# Automatic adjustments
#automatic_i18n_adjustment
automatic_packagejson_adjustment

# Automatic theme update
#pushd "matrix-react-sdk" > /dev/null
#./theme.sh y
#popd > /dev/null

popd > /dev/null
