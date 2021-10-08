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

bump_test_version

popd > /dev/null
