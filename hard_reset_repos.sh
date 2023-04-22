#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"

cd "$mydir"

source ./merge_helpers.sh

# Note: this doesn't delete files starting with a dot,
# and in particular not the '.git' directory, which we
# want to keep
forall_repos bash -c 'rm -rf *'
forall_repos git reset HEAD --hard
