#!/bin/bash

set -e
# set -x

DEPLOY_ROOT="$(dirname "$(realpath "$0")")"

version="$1"
debpath="$2"

repopath="$DEPLOY_ROOT/repos/aur-bin"
repourl="ssh://aur@aur.archlinux.org/schildichat-desktop-bin.git"

sha256sum=($(sha256sum $debpath))

[ -d "$repopath" ] || git clone $repourl $repopath

pushd "$repopath" > /dev/null

git fetch
git reset --hard origin/master

sed -i "s|^pkgver=.*$|pkgver=$version|" PKGBUILD
sed -i "s|^sha256sums=('.*'$|sha256sums=('$sha256sum'|" PKGBUILD

makepkg --printsrcinfo > .SRCINFO

git add .SRCINFO PKGBUILD
git commit -m "Bump version to v$version"

git push

popd > /dev/null

echo "Release v$version published on AUR!"
