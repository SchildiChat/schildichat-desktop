#!/bin/bash

set -e
set -x

DEPLOY_ROOT="$(dirname "$(realpath "$0")")"

version="$1"
debpath="$2"

repopath="$DEPLOY_ROOT/repos/flathub"
repourl="git@github.com:flathub/chat.schildi.desktop.git"

downloadurl="https://github.com/SchildiChat/schildichat-desktop/releases/download/v${version}/schildichat-desktop_${version}_amd64.deb"
sha256sum=($(sha256sum $debpath))
debsize=($(wc -c $debpath))
debdate=$(date +%Y-%m-%d -r $debpath)

[ -d "$repopath" ] || git clone $repourl $repopath

pushd "$repopath" > /dev/null

git fetch
git reset --hard origin/master

jsonFile="chat.schildi.desktop.json"
jsonString=$(jq -r "." $jsonFile)

xmlFile="chat.schildi.desktop.appdata.xml"

jsonString=$(echo $jsonString | jq -r ".modules[]? |= ((select(.name?==\"schildichat\") | .sources[0].url = \"${downloadurl}\") // .)")
jsonString=$(echo $jsonString | jq -r ".modules[]? |= ((select(.name?==\"schildichat\") | .sources[0].sha256 = \"${sha256sum}\") // .)")
jsonString=$(echo $jsonString | jq -r ".modules[]? |= ((select(.name?==\"schildichat\") | .sources[0].size = ${debsize}) // .)")

echo $jsonString | jq --indent 4 "." > $jsonFile

sed -i "s|^\s\s<releases>$|  <releases>\n    <release version=\"$version\" date=\"$debdate\"/>|" $xmlFile

git add $jsonFile $xmlFile
git commit -m "Bump version to v$version"

#git push

popd > /dev/null
