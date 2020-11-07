#!/bin/bash
# Convert app to a different package with different icon and name,
# to allow multiple installations on the same device
# (different colors for different account :D).

package_add="$1"
name_add="$2"
mydir="$(dirname "$(realpath "$0")")"

if [ -z "$package_add" ] || [ -z "$name_add" ]; then
    echo "Usage: $0 <cmd_add> <name_add>"
    exit 1
fi

pushd "$mydir" > /dev/null

web_dir="element-web"
desktop_dir="element-desktop"
package_file="$desktop_dir/package.json"

if grep -q "schildichat-desktop-$package_add" "$package_file"; then
    echo "Abort, $package_add already active"
    exit 0
fi

# Analog to SchildiChat-Android's alternative_package.sh
logo_replace_color() {
    local file="$1"
    local color_shell="$2"
    local color_shell_dark="$3"
    local color_bg="$4"
    # shell color
    sed -i "s|#8BC34A|$color_shell|gi" "$file"
    sed -i "s|#33691E|$color_shell_dark|gi" "$file"
    # bg color
    sed -i "s|#e2f0d2|$color_bg|gi" "$file"
}

logo_alternative() {
    for f in "$web_dir"/graphics/*.svg; do
        logo_replace_color "$f" "$@"
    done
    for f in "$desktop_dir"/graphics/*.svg; do
        logo_replace_color "$f" "$@"
    done
    "$web_dir/graphics/icon_gen.sh"
    "$desktop_dir/graphics/icon_gen.sh"
}

# Analog to SchildiChat-Android's alternative_package.sh
case "$package_add" in
"a")
    # blue
    logo_alternative "#2196F3" "#0D47A1" "#BBDEFB"
    ;;
"b")
    # orange: 900 color recuded in value
    logo_alternative "#FB8C00" "#7f2c00" "#FFE0B2"
    ;;
"c")
    # red: 900 color reduced in value
    logo_alternative "#E53935" "#4c0b0b" "#FFCDD2"
    ;;
"d")
    # purple
    logo_alternative "#5E35B1" "#311B92" "#D1C4E9"
    ;;
"e")
    # pink
    logo_alternative "#D81B60" "#880E4F" "#F8BBD0"
    ;;
"x")
    # cyan
    logo_alternative "#00ACC1" "#006064" "#B2EBF2"
    ;;
"z")
    # white
    logo_alternative "#ffffff" "#000000" "#eeeeee"
    ;;
esac

sed -i "s|SchildiChat|SchildiChat.$name_add|g" "$package_file"
sed -i "s|schildichat-desktop|schildichat-desktop-$package_add|g" "$package_file"
