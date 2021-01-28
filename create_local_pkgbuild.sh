#!/bin/sh

set -e

mydir="$(dirname "$(realpath "$0")")"
cd "$mydir"

version="$1"
appName="$2"
productName="$3"
debOut="$4"

template_dir="local-pkgbuild-template"
out_dir="local-pkgbuild"

if [ -z "$version" ] || [ -z "$appName" ] || [ -z "$productName" ] || [ -z "$debOut" ]; then
    echo "Usage: $0 version appName productName debOut"
    exit 1
fi

debName="$(basename "$debOut")"

rm -rf "$out_dir"
mkdir "$out_dir"

setup_file() {
    local file="$1"
    local outfile="$2"
    if [ -z "$outfile" ]; then
        local outfile="$file"
    fi
    cat "$template_dir/$file" \
        | sed "s|---version---|$version|g" \
        | sed "s|---appName---|$appName|g" \
        | sed "s|---productName---|$productName|g" \
        | sed "s|---debName---|$debName|g" \
        > "$out_dir/$outfile"
}

setup_file PKGBUILD
setup_file schildichat-desktop.sh "$appName.sh"
ln -r -s "$debOut" "$out_dir/$debName"
