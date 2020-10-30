#!/bin/bash

SCHILDI_ROOT="$(dirname "$(realpath "$0")")"

add_upstream() {
    if git remote | grep -q upstream; then
        echo "Remote named upstream already exists!"
        return 1
    fi
    local sc_remote="$(git remote -v|grep origin|grep fetch|sed 's|.*\t\(.*\) (fetch)|\1|')"
    if echo "$sc_remote" | grep -q matrix; then
        # matrix.org repo
        local upstream_remote="$(echo "$sc_remote" | sed 's|SchildiChat|matrix-org|')"
    elif echo "$sc_remote" | grep -q element; then
        # vector-im repo
        local upstream_remote="$(echo "$sc_remote" | sed 's|SchildiChat|vector-im|')"
    else
        echo "Don't know upstream repo for $sc_remote"
        return 1
    fi
    echo "Adding upstream $upstream_remote"
    git remote add upstream "$upstream_remote"
    git fetch upstream
}

forall_repos() {
    pushd "$SCHILDI_ROOT/matrix-js-sdk"
    "$@"
    popd
    pushd "$SCHILDI_ROOT/matrix-react-sdk"
    "$@"
    popd
    pushd "$SCHILDI_ROOT/element-web"
    "$@"
    popd
    pushd "$SCHILDI_ROOT/element-desktop"
    "$@"
    popd
}
