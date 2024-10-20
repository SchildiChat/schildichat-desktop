#!/usr/bin/env bash
#
# Based upon https://hinty.io/ivictbor/publish-and-upload-release-to-github-with-bash-and-curl/
# and https://gist.github.com/stefanbuck/ce788fee19ab6eb0b4447a85fc99f447
#

set -e
# set -x

version="$1"
releasepath="$2"

if [ -z "$version" ] || [ -z "$releasepath" ]; then
    echo "Usage: $0 <version> <releasepath>"
    exit 1
fi

if [ -z "$GITHUB_API_TOKEN" ]; then
    github_api_token=`cat ~/githubtoken`
else
    github_api_token="$GITHUB_API_TOKEN"
fi
release_notes_file="/tmp/scrn.md"

owner=SchildiChat
repo=schildichat-desktop
target=lite

# Define variables
GH_API="https://api.github.com"
GH_REPO="$GH_API/repos/$owner/$repo"
AUTH="Authorization: token $github_api_token"

# Validate token
curl -o /dev/null -sH "$AUTH" $GH_REPO || { echo "Error: Invalid repo, token or network issue!";  exit 1; }

# Get release notes
$EDITOR "$release_notes_file"
release_notes=`cat "$release_notes_file"`

# Create draft release
echo "Create GitHub draft release ..."
json_string=`jq -n --arg tag "v$version" --arg target "$target" --arg body "$release_notes" '{
  tag_name: $tag,
  target_commitish: $target,
  name: $tag,
  body: $body,
  draft: true,
  prerelease: true
}'`
# echo "$json_string"
res=`echo "$json_string" | curl -sH "$AUTH" $GH_REPO/releases -d @-`
# echo "$res" | jq "."

# Get release id
id=`echo $res | jq ".id"`
# echo "id: $id"

# Upload assets
find "$releasepath" -type f | while read filename; do
    echo ""
    echo "Uploading $filename ..."

    # Construct url
    GH_ASSET="https://uploads.github.com/repos/$owner/$repo/releases/$id/assets?name=$(basename $filename)"

    # Upload
    res=`curl --progress-bar --data-binary @"$filename" -H "$AUTH" -H "Content-Type: application/octet-stream" $GH_ASSET`
    state=`echo $res | jq ".state"`
    if [ "$state" == "\"uploaded\"" ]; then
        echo "Success!"
    else
        echo "Error:"
        echo $res | jq "."
        exit -1
    fi
done

# Publish draft
res=`curl -sH "$AUTH" $GH_REPO/releases/$id -d '{"draft": false}'`
draft=`echo $res | jq ".draft"`
echo ""
if [ "$draft" == "false" ]; then
    echo "Release v$version published on GitHub!"
else
    echo "Error:"
    echo $res | jq "."
    exit -1
fi
