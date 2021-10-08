#!/bin/bash

SCHILDI_ROOT="$(dirname "$(realpath "$0")")"

branch=${BRANCH:-"sc"}

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
    pushd "$SCHILDI_ROOT/matrix-js-sdk" > /dev/null
    "$@"
    popd > /dev/null

    pushd "$SCHILDI_ROOT/matrix-react-sdk" > /dev/null
    "$@"
    popd > /dev/null

    pushd "$SCHILDI_ROOT/element-web" > /dev/null
    "$@"
    popd > /dev/null

    pushd "$SCHILDI_ROOT/element-desktop" > /dev/null
    "$@"
    popd > /dev/null
}

forelement_repos() {
    pushd "$SCHILDI_ROOT/element-web" > /dev/null
    "$@"
    popd > /dev/null

    pushd "$SCHILDI_ROOT/element-desktop" > /dev/null
    "$@"
    popd > /dev/null
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
    revert_i18n_changes "$i18n_path" "$skip_commit"
    popd > /dev/null

    pushd "$SCHILDI_ROOT/element-web" > /dev/null
    revert_i18n_changes "$i18n_path" "$skip_commit"
    popd > /dev/null

    pushd "$SCHILDI_ROOT/element-desktop" > /dev/null
    revert_i18n_changes "$i18n_path" "$skip_commit"
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

get_current_versions() {
    local version=`cat "$SCHILDI_ROOT/element-web/package.json" | jq .version -r`
    if [[ "$version" =~ ([0-9\.]*)(-sc\.([0-9]+)(\.test.([0-9]+))?)? ]]; then
        upstream="${BASH_REMATCH[1]}"
        release="${BASH_REMATCH[3]}"
        test="${BASH_REMATCH[5]}"
    fi

    versions=("${upstream:-"0.0.1"}" "${release:-"0"}" "${test:-"0"}")
}

get_versions_string() {
    versions_string="${versions[0]}-sc.${versions[1]}"

    if [[ ${versions[2]} -gt 0 ]]; then
        versions_string+=".test.${versions[2]}"
    fi
}

write_version() {
    local file="$1"
    local versions_string
    get_versions_string

    new_content=`jq --arg version "$versions_string" '.version = $version' "$file"`
    echo "$new_content" > "$file"

    git add "$file"
    git commit -m "Update version to $versions_string" || true
}

bump_test_version() {
    local versions
    get_current_versions
    
    # increment test version
    (( versions[2]++ ))

    forelement_repos write_version "package.json"
}

bump_release_version() {
    local versions
    get_current_versions
    
    # increment release version
    (( versions[1]++ ))
    
    # set test version to 0
    versions[2]=0

    forelement_repos write_version "package.json"
}

revert_packagejson_changes() {
    local path="$1"
    local skip_commit="$2"

    git checkout upstream/master -- "$path"

    if [[ "$skip_commit" != [Yy]* ]]; then
        git commit -m "Automatic package.json reversion" || true
    fi
}

apply_packagejson_overlay() {
    local orig_path="$1"
    local overlay_path="$2"

    # see: https://stackoverflow.com/a/24904276
    new_content=`jq -s '.[0] * .[1]' "$orig_path" "$overlay_path"`

    echo "$new_content" > "$orig_path"
    git add "$orig_path"
    git commit -m "Automatic package.json adjustment" || true
}

automatic_packagejson_reversion() {
    local skip_commit="$1"

    forelement_repos revert_packagejson_changes "package.json" "$skip_commit"
}

automatic_packagejson_adjustment() {
    local versions
    get_current_versions

    forelement_repos apply_packagejson_overlay "package.json" "overlay-package.json"
    forelement_repos write_version "package.json"
}
