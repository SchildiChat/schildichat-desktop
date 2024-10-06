#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"

print_section() {
    local msg="$1"
    echo "##############################################################"
    echo "# $msg"
    echo "##############################################################"
}

pushd "$mydir" > /dev/null

source ./merge_helpers.sh

# Apply our patches
print_section "Apply patches to matrix-js-sdk"
apply_patches matrix-js-sdk
print_section "Apply patches to matrix-react-sdk"
apply_patches matrix-react-sdk
#print_section "Apply patches to element-web"
#apply_patches element-web
print_section "Apply patches to element-desktop"
apply_patches element-desktop

# Automatic adjustments
#print_section "Apply i18n"
#automatic_i18n_adjustment
print_section "Apply automatic package adjustments"
automatic_packagejson_adjustment

# Automatic theme and icon update
print_section "Apply automatic theme updates"
./theme.sh y
print_section "Generate icons"
./graphics/icon_gen.sh y

popd > /dev/null
