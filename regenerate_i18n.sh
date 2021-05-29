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
automatic_i18n_reversion y

# Automatic i18n adjustment
automatic_i18n_adjustment

popd > /dev/null
