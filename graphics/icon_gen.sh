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

for f in "$base_out"/*.png; do
    pngcrush -ow "$f"
done


cp "$mydir/ic_launcher_sc.svg" "$repo_dir/res/themes/element/img/logos/element-logo.svg"


repo_dir="$SCHILDI_ROOT/element-desktop"
base_out="$repo_dir/res/img"

export_square 256 "$mydir/ic_launcher_sc.svg" "$base_out/element.png"
magick "$base_out/element.png" "$base_out/element.ico"

# TODO monochrome icon? Unless https://github.com/element-hq/element-desktop/pull/1934 is what we'll end with
export_square 256 "$mydir/ic_launcher_sc.svg" "$base_out/monochrome.png"
magick "$base_out/element.png" "$base_out/monochrome.ico"

for f in "$base_out"/*.png; do
    pngcrush -ow "$f"
done




base_out="$repo_dir/build"

for i in 16 24 48 64 96 128 256 512 1024; do
    export_square "$i" "$mydir/ic_launcher_sc.svg" "$base_out/icons/$i"x"$i.png"
done

export_square "320" "$mydir/ic_launcher_sc.svg" "$base_out/install-spinner.png"
pngcrush "$base_out/install-spinner.png"
magick "$base_out/install-spinner.png" "$base_out/install-spinner.gif"
rm  "$base_out/install-spinner.png"

magick "$base_out/icons/256x256.png" "$base_out/icon.ico"
magick "$base_out/icons/1024x1024.png" "$base_out/icon.icns"
rm "$base_out/icons/1024x1024.png"

for f in "$base_out/icons"/*.png; do
    pngcrush -ow "$f"
done


if [[ "$automatic_commit" == [Yy]* ]]; then
    forelement_repos commit_if_dirty "Automatic icon update"
fi
