#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"
branch=${BRANCH:-"sc"}

pushd "$mydir" > /dev/null

source ./merge_helpers.sh

# Check branch
check_branch $branch
forall_repos check_branch $branch

# Ensure clean git state
forall_repos check_clean_git

# Automatic i18n reversion
automatic_i18n_reversion

# Merge
forall_repos git fetch upstream
forall_repos git merge upstream/master

# Refresh environment
make clean
make setup

# Automatic i18n adjustment
automatic_i18n_adjustment

# Automatic theme update
pushd "matrix-react-sdk" > /dev/null
./theme.sh
popd > /dev/null

popd > /dev/null
