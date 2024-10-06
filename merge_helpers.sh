#!/bin/bash

SCHILDI_ROOT="$(dirname "$(realpath "$0")")"

branch=${BRANCH:-"lite"}

i18n_helper_path="$SCHILDI_ROOT/i18n-helper/index.js"
i18n_path="src/i18n/strings"
i18n_overlay_path="$SCHILDI_ROOT/i18n-overlays"

yarn=yarnpkg

add_upstream() {
    if git remote | grep -q upstream; then
        echo "Remote named upstream already exists, deleting..."
        git remote remove upstream
    fi
    local sc_remote="$(git remote -v|grep origin|grep fetch|sed 's|.*\t\(.*\) (fetch)|\1|')"
    if echo "$sc_remote" | grep -q matrix-js-sdk; then
        # matrix.org repo
        local upstream_remote="$(echo "$sc_remote" | sed 's|SchildiChat|matrix-org|')"
    elif echo "$sc_remote" | grep -q "element\\|matrix-react-sdk"; then
        # vector-im repo
        local upstream_remote="$(echo "$sc_remote" | sed 's|SchildiChat|element-hq|')"
    else
        echo "Don't know upstream repo for $sc_remote"
        return 1
    fi
    echo "Adding upstream $upstream_remote"
    git remote add upstream "$upstream_remote"
    git fetch upstream
}

forall_repos() {
    for repo in "matrix-js-sdk" "matrix-react-sdk" "element-web" "element-desktop"; do
        pushd "$SCHILDI_ROOT/$repo" > /dev/null
        "$@"
        popd > /dev/null
    done
}

forelement_repos() {
    for repo in "element-web" "element-desktop"; do
        pushd "$SCHILDI_ROOT/$repo" > /dev/null
        "$@"
        popd > /dev/null
    done
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
    local revision="$2"
    local skip_commit="$3"

    git checkout "$revision" -- "$i18n_path"

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

    local current_upstream_tag
    get_current_upstream_tag

    local current_mxjssdk_tag
    local current_mxreactsdk_tag
    get_current_mxsdk_tags

    pushd "$SCHILDI_ROOT/matrix-react-sdk" > /dev/null
    revert_i18n_changes "$i18n_path" "$current_mxreactsdk_tag" "$skip_commit"
    popd > /dev/null

    pushd "$SCHILDI_ROOT/element-web" > /dev/null
    revert_i18n_changes "$i18n_path" "$current_upstream_tag" "$skip_commit"
    popd > /dev/null

    pushd "$SCHILDI_ROOT/element-desktop" > /dev/null
    revert_i18n_changes "$i18n_path" "$current_upstream_tag" "$skip_commit"
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

    # both zero means the initial version after a merge
    if [[ ${versions[1]} -eq 0 || ${versions[2]} -gt 0 ]]; then
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
    versions[2]=$((versions[2] + 1))

    forelement_repos write_version "package.json"
}

bump_release_version() {
    local versions
    get_current_versions
    
    # increment release version
    versions[1]=$((versions[1] + 1))
    
    # set test version to 0
    versions[2]=0

    forelement_repos write_version "package.json"
}

revert_packagejson_changes() {
    local path="$1"
    local revision="$2"
    local skip_commit="$3"

    git checkout "$revision" -- "$path"

    if [[ "$skip_commit" != [Yy]* ]]; then
        git commit -m "Automatic package.json reversion" || true
    fi
}

apply_packagejson_overlay() {
    local orig_path="$1"
    local overlay_path="../overlay/$(basename "$PWD")/package.json"

    # see: https://stackoverflow.com/a/24904276
    new_content=`jq -s '.[0] * .[1]' "$orig_path" "$overlay_path" | sed 's|  |    |g'`

    echo "$new_content" > "$orig_path"
    git add "$orig_path"
    git commit -m "Automatic package.json adjustment" || true
}

automatic_packagejson_reversion() {
    local skip_commit="$1"

    local current_upstream_tag
    get_current_upstream_tag

    forelement_repos revert_packagejson_changes "package.json" "$current_upstream_tag" "$skip_commit"
}

automatic_packagejson_adjustment() {
    local versions
    get_current_versions

    forelement_repos apply_packagejson_overlay "package.json"
    forelement_repos write_version "package.json"
}

get_latest_upstream_tag() {
    pushd "$SCHILDI_ROOT/element-web" > /dev/null
    git fetch upstream
    latest_upstream_tag=`git for-each-ref --sort=creatordate --format '%(refname) %(creatordate)' refs/tags | sed -nr 's|refs/tags/(v[0-9]+(\.[0-9]+(\.[0-9]+)?)?) .*|\1|p' | tail -n 1`
    popd > /dev/null
}

get_current_upstream_tag() {
    local versions
    get_current_versions
    current_upstream_tag="v${versions[0]}"
}

get_current_mxsdk_tags() {
    current_mxreactsdk_tag="v$(cat "$SCHILDI_ROOT/element-web/package.json" | jq '.dependencies["matrix-react-sdk"]' -r)"
    current_mxjssdk_tag="v$(cat "$SCHILDI_ROOT/element-web/package.json" | jq '.dependencies["matrix-js-sdk"]' -r)"
}

apply_patches() {
    local repo="$(realpath "$1")"
    local patch_dir="$SCHILDI_ROOT/patches/$(basename "$1")"
    if [ ! -d "$repo" ]; then
        echo "Unknown repo: $repo"
        return 1
    fi
    if [ ! -d "$patch_dir" ]; then
        echo "No patches found at $patch_dir"
        return 1
    fi
    pushd "$repo"
    for patch in "$patch_dir"/*; do
        echo "Applying $patch to $repo..."
        git am "$patch" || on_apply_patch_fail_try_original_commit "$patch" "$repo"
    done
    popd
}

on_apply_patch_fail_try_original_commit() {
    local patch="$1"
    local repo="$2"
    local orig_commit="$(head -n 1 "$patch"|sed 's|From ||;s| .*||')"
    echo "Applying $patch failed, trying with original commit $orig_commit..."
    git am --abort
    git cherry-pick "$orig_commit" || on_apply_patch_fail "$patch" "$repo" "$orig_commit"
}

on_apply_patch_fail() {
    local patch="$1"
    local repo="$2"
    local orig_commit="$3"
    echo "----------------------------------"
    echo "Applying patch failed, please commit manually!"
    echo "Patch: $patch"
    echo "Repo: $repo"
    echo "Original commit: $(head -n 1 "$patch"|sed 's|From ||;s| .*||')"
    echo "----------------------------------"
    read -p "Press enter after committing resolved conflicts: "
}
