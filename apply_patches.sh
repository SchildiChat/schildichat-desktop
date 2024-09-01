#!/bin/bash

set -e

mydir="$(dirname "$(realpath "$0")")"

pushd "$mydir" > /dev/null

source ./merge_helpers.sh

# Apply our patches
apply_patches matrix-js-sdk
apply_patches matrix-react-sdk
#apply_patches element-web
apply_patches element-desktop

# Automatic adjustments
#automatic_i18n_adjustment
automatic_packagejson_adjustment

# Automatic theme and icon update
./theme.sh y
./graphics/icon_gen.sh

popd > /dev/null
