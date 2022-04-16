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

bump_release_version

# Get version string
get_current_versions
get_versions_string

# Add everything
git add -A
git commit --allow-empty -m "New release v$versions_string"
git tag -s "v$versions_string" -m "New release v$versions_string"

popd > /dev/null
