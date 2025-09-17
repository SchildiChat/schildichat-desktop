#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"
automatic_commit="$1"

SCHILDI_ROOT="$mydir/.."
source "$SCHILDI_ROOT/merge_helpers.sh"

if [[ "$automatic_commit" == [Yy]* ]]; then
    forelement_repos check_clean_git
fi


export_rect() {
    w="$1"
    h="$2"
    in="$3"
    out="$4"
    inkscape -w "$w" -h "$h" --export-filename="$out" -C "$in"
}
export_square() {
    size="$1"
    in="$2"
    out="$3"
    export_rect "$1" "$size" "$in" "$out"
    if [[ "$out" == *.png ]]; then
        pngcrush -ow "$out"
    fi
}

repo_dir="$SCHILDI_ROOT/element-web"
base_out="$repo_dir/res/vector-icons"

for i in 1024 120 150 152 180 24 300 44 48 50 76 88; do
    export_square "$i" "$mydir/ic_launcher_sc.svg" "$base_out/$i.png"
done

for i in 114 120 144 152 180 57 60 72 76; do
    export_square "$i" "$mydir/store_icon.svg" "$base_out/apple-touch-icon-$i.png"
done

for i in 150 310 70; do
    export_square "$i" "$mydir/store_icon.svg" "$base_out/mstile-$i.png"
done

# TODO fix measures of input to have correct measures for export here again
export_rect 1024 500 "$mydir/feature_image_transparent.svg" "$base_out/1240x600.png"
export_rect 512 250 "$mydir/feature_image_transparent.svg" "$base_out/620x300.png"
export_rect 256 125 "$mydir/feature_image.svg" "$base_out/mstile-310x150.png"

magick "$base_out/48.png" "$base_out/favicon.ico"
rm "$base_out/48.png" # this was only created for favicon.ico


cp "$mydir/ic_launcher_sc.svg" "$repo_dir/res/themes/element/img/logos/element-logo.svg"

export_square 320 "$mydir/ic_launcher_sc.svg" "$repo_dir/res/themes/element/img/logos/element-app-logo.png"


repo_dir="$SCHILDI_ROOT/element-desktop"
base_out="$repo_dir/build"

export_square 512 "$mydir/ic_launcher_sc.svg" "$base_out/icon.png"
export_square 256 "$mydir/ic_launcher_sc.svg" "$base_out/icon256_tmp.png"
magick "$base_out/icon256_tmp.png" "$base_out/icon.ico"
rm "$base_out/icon256_tmp.png"
export_square 1024 "$mydir/ic_launcher_sc.svg" "$base_out/icon1024_tmp.png"
magick "$base_out/icon1024_tmp.png" "$base_out/icon.icns"
rm "$base_out/icon1024_tmp.png"


if [[ "$automatic_commit" == [Yy]* ]]; then
    forelement_repos commit_if_dirty "Automatic icon update"
fi
