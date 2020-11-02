#!/bin/bash

set -e

portable_exe=$1
dest_name=$2
release_dir=$3
version=$4

dest_path=$release_dir/$dest_name/SchildiChat

mkdir -p $dest_path/app
cp "$portable_exe" $dest_path/app/dontclick.exe

cat >$dest_path/SchildiChat_Portable.bat <<EOL
REM -- Adapted from: https://superuser.com/a/1226026

REM -- Path to the directory of this script (make sure to remove ending slash)
set CURRENT_DIR=%~dp0
REM -- Great example from Strawberry Perl's portable shell launcher:
if not "" == "%CURRENT_DIR%" if #%CURRENT_DIR:~-1%# == #\# set CURRENT_DIR=%CURRENT_DIR:~0,-1%

REM -- Path to data directory
set DATA_DIR=%CURRENT_DIR%\data

REM -- Ensure directories exists
if not exist %DATA_DIR%\AppData\Roaming mkdir %DATA_DIR%\AppData\Roaming

REM -- OVERRIDE the user environment variable to point to a portable directory
set USERPROFILE=%DATA_DIR%

REM -- (Optional) Some programs do not use these environment variables
set APPDATA=%DATA_DIR%\AppData\Roaming>nul
set ALLUSERSPROFILE=%DATA_DIR%\AppData\Roaming>nul
set PROGRAMDATA=%DATA_DIR%\AppData\Roaming>nul

REM -- Start the application
start "" /D"%CURRENT_DIR%\app" "dontclick.exe"
EOL

cat >$dest_path/README.txt <<EOL
Just extract this zip file to a folder of your choice (e.g. on a USB-Stick).
The .\app\dontclick.exe file is the real portable executable.
SchildiChat_Portable.bat is a batch script to run this executable but with the data in the .\data folder instead of the system's %APPDATA%.
Thus you can move your data along with this portable app.
To update just extract the new zip file to the same folder as the previous version whilst merging folders and overwriting files.
EOL

# if $version looks like semver with leading v, strip it before writing to file
if [[ ${version} =~ ^v[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]+(-.+)?$ ]]; then
    echo ${version:1} > $dest_path/app/version
else
    echo ${version} > $dest_path/app/version
fi

pushd $dest_path/..
zip -r ../$dest_name.zip *
popd

rm -r $release_dir/$dest_name

echo
echo "Packaged $release_dir/$dest_name.zip"
