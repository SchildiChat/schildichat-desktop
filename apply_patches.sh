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

# Automatic theme update
#pushd "matrix-react-sdk" > /dev/null
#./theme.sh y
#popd > /dev/null

popd > /dev/null
