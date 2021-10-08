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

git fetch origin
git branch -D master || true
git checkout -b master --track origin/master
git merge --ff-only sc
git push
git checkout sc
forall_repos git fetch origin
forall_repos git branch -D master || true
forall_repos git checkout -b master --track origin/master
forall_repos git merge --ff-only sc
forall_repos git push
forall_repos git checkout sc

popd > /dev/null
