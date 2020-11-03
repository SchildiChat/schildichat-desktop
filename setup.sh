#!/bin/bash

set -e

yarn=yarnpkg

pushd matrix-js-sdk
$yarn unlink &>/dev/null || true
$yarn link
$yarn install
popd

pushd matrix-react-sdk
$yarn link matrix-js-sdk
$yarn unlink &>/dev/null || true
$yarn link
$yarn install
popd

pushd element-web
$yarn link matrix-js-sdk
$yarn link matrix-react-sdk
$yarn install
popd

pushd element-desktop
$yarn install
ln -s ../element-web/webapp ./ || true
popd
