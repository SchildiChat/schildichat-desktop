#!/bin/bash

SCHILDI_ROOT="$(dirname "$(realpath "$0")")"

i18n_helper_path="$SCHILDI_ROOT/i18n-helper/index.js"
i18n_path="src/i18n/strings"
i18n_overlay_path="$SCHILDI_ROOT/i18n-overlays"

yarn=yarnpkg

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

ensure_yes() {
    read -e -p "$1 [y/N] " choice
    
    if [[ "$choice" != [Yy]* ]]; then
        exit 1
    fi
}

check_branch() {
    if [[ $(git branch --show-current) != "$1" ]]; then
        repo_name=$(basename `git rev-parse --show-toplevel`)
        ensure_yes "$repo_name not in branch $1. Continue?"
    fi
}

check_clean_git() {
    # Require clean git state
    uncommitted=`git status --porcelain`
    if [ ! -z "$uncommitted" ]; then
        echo "Uncommitted changes are present, please commit first!"
        exit 1
    fi
}

revert_i18n_changes() {
    local i18n_path="$1"
    local skip_commit="$2"

    git checkout upstream/master -- "$i18n_path"

    if [[ "$skip_commit" != [Yy]* ]]; then
        git commit -m "Automatic i18n reversion" || true
    fi
}

apply_i18n_changes() {
    local i18n_path="$1"

    git add "$i18n_path"
    git commit -m "Automatic i18n adjustment" || true
}

automatic_i18n_reversion() {
    local skip_commit="$1"

    pushd "$SCHILDI_ROOT/matrix-react-sdk" > /dev/null
    revert_i18n_changes "$i18n_path" $skip_commit
    popd > /dev/null

    pushd "$SCHILDI_ROOT/element-web" > /dev/null
    revert_i18n_changes "$i18n_path" $skip_commit
    popd > /dev/null

    pushd "$SCHILDI_ROOT/element-desktop" > /dev/null
    revert_i18n_changes "$i18n_path" $skip_commit
    popd > /dev/null
}

automatic_i18n_adjustment() {
    # matrix-react-sdk
    pushd "$SCHILDI_ROOT/matrix-react-sdk" > /dev/null
    $yarn i18n
    node "$i18n_helper_path" "$SCHILDI_ROOT/matrix-react-sdk/$i18n_path" "$i18n_overlay_path/matrix-react-sdk"
    apply_i18n_changes "$i18n_path"
    popd > /dev/null

    # element-web
    pushd "$SCHILDI_ROOT/element-web" > /dev/null
    $yarn i18n
    node "$i18n_helper_path" "$SCHILDI_ROOT/element-web/$i18n_path" "$i18n_overlay_path/element-web"
    apply_i18n_changes "$i18n_path"
    popd > /dev/null

    # element-desktop
    pushd "$SCHILDI_ROOT/element-desktop" > /dev/null
    $yarn i18n
    node "$i18n_helper_path" "$SCHILDI_ROOT/element-desktop/$i18n_path" "$i18n_overlay_path/element-desktop"
    apply_i18n_changes "$i18n_path"
    popd > /dev/null
}


# Version management
versionedPackageFiles=(element-desktop/ element-web/)
packageFile=package.json

do_versions() {
    function="$1"; shift
    for x in $versionedPackageFiles; do
      $function $x
    done
}

write_version() {
    file="$1"; shift
    tmp_file="$file.tmp"
    version="$1"; shift

    echo "Updating $file to version $version"

    cat "$file" | jq --arg version "$version" '.version = $version' > "$tmp_file"
    mv "$tmp_file" "$file"
}

reset_versions() {
    do_versions "reset_version"
}

reset_version() {
    pushd "$SCHILDI_ROOT/$1"
    version=`cat $packageFile | jq .version -r | sed 's/-.*//'`

    write_version "$packageFile" "$version"
    popd
}

append_versions() {
    do_versions "append_version"
}

append_version() {
    pushd "$SCHILDI_ROOT/$1"
    version=`cat $packageFile | jq .version -r | sed 's/-.*//'`

    write_version "$packageFile" "$version-sc.1.test.1"
    popd
}

release_versions() {
    do_versions "release_version"
}

release_version() {
    pushd "$SCHILDI_ROOT/$1"
    version=`cat $packageFile | jq .version -r | sed 's/\.test\.[0-9]*//'`

    write_version "$packageFile" "$version"
    popd
}

prerelease_versions() {
    do_versions "prerelease_version"
}

prerelease_version() {
    pushd "$SCHILDI_ROOT/$1"
    version=`cat $packageFile | jq .version -r`

    if [[ "$version" =~ ^[0-9\.]*-sc\.[0-9]*$  ]]; then
      sc_release=`echo "$version" | sed 's/[0-9\.]*-sc\.\([0-9]*\)/\1/'`
      version=`echo $version | sed 's/\([0-9\.]*-sc\.\).*/\1/'`

      version="$version`expr "$sc_release" + 1`.test.1"
    else
      test_version=`echo "$version" | sed 's/[0-9\.]*-sc\.[0-9]\.test\.\([0-9]*\)/\1/'`
      version=`echo $version | sed 's/\([0-9\.]*-sc\.[0-9]*\.test\.\)[0-9]*/\1/'`

      version="$version`expr "$test_version" + 1`"
    fi

    write_version "$packageFile" "$version"
    popd
}
