#!/bin/bash

set -e
set -x

DEPLOY_ROOT="$(dirname "$(realpath "$0")")"

version="$1"
releasepath="$2"

find "$releasepath" -type f | while read p; do
    echo "Uploading $p ..."
    $DEPLOY_ROOT/upload-github-release-asset.sh github_api_token=$GITHUB_TOKEN owner=SchildiChat repo=schildichat-desktop tag=v$version filename=$p
done