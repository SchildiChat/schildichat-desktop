#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"
pushd "$mydir" > /dev/null

source ./merge_helpers.sh

get_branch_of() {
    local repo="$1"
    pushd "$repo" > /dev/null
    local b=`git branch --show-current`
    if [[ "$b" = sc_v* ]]; then
        echo "$b"
    else
        >&2 echo "Unexpected branch name for $repo: $b"
        exit 1
    fi
    popd > /dev/null
}

b_js=`get_branch_of matrix-js-sdk`
b_react=`get_branch_of matrix-react-sdk`
b_web=`get_branch_of element-web`
b_desktop=`get_branch_of element-desktop`

if [ "$b_js" != "$b_react" ] || [ "$b_react" != "$b_web" ] || [ "$b_web" != "$b_desktop" ]; then
    echo "Detected branch name mismatch!"
    echo "js-sdk: $b_js"
    echo "react-sdk: $b_react"
    echo "element-web: $b_web"
    echo "element-desktop: $b_desktop"
    exit 1
fi

branch="$b_js"

echo "Pushing to all repos: $branch"
forall_repos git push --set-upstream origin "$branch" "$@"
