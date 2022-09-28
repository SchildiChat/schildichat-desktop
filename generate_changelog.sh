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

# Fetch upstream
forall_repos git fetch origin > /dev/null 2>/dev/null
forall_repos git fetch upstream > /dev/null 2>/dev/null

(
    # Add new line below git log: https://unix.stackexchange.com/a/345558

    get_latest_upstream_tag
    forelement_repos git log --pretty=format:"- %s" "sc" "^$latest_upstream_tag" "^master" \
        | printf '%s\n' "$(cat)" \
        | sed "s|Merge tag '\\(.*\\)' into sc.*|Update codebase to Element \1|" \
        | sed "s|Merge tag '\\(.*\\)' into merge.*|Update codebase to Element \1|"

    get_current_mxsdk_tags

    pushd "matrix-js-sdk" > /dev/null
    git log --pretty=format:"- %s" "sc" "^$current_mxjssdk_tag" "^master" \
        | printf '%s\n' "$(cat)" \
        | grep -v "Merge .*tag"
    popd > /dev/null

    pushd "matrix-react-sdk" > /dev/null
    git log --pretty=format:"- %s" "sc" "^$current_mxreactsdk_tag" "^master" \
        | printf '%s\n' "$(cat)" \
        | grep -v "Merge .*tag"
    popd > /dev/null
) \
    | grep -v "Automatic i18n reversion" \
    | grep -v "Automatic package.json reversion" \
    | grep -v "Merge .*branch" \
    | grep -v "Automatic theme update" \
    | grep -v "Automatic package.json adjustment" \
    | grep -v "Automatic i18n adjustment" \
    | grep -v "Update version to .*-sc\\..*" \
    | grep -v "\\.sh" \
    | grep -v "\\.md" \
    | grep -v "Added translation using Weblate" \
    | grep -v "Translated using Weblate" \
    | grep -v "weblate/sc" \
    | grep -v "\\[.*merge.*\\]" \
    | awk '!seen[$0]++' `# https://stackoverflow.com/a/1444448` \
    || echo "No significant changes since the last stable release"

popd > /dev/null
