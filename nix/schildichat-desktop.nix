{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, makeDesktopItem
, mkYarnPackage
, electron
, element-desktop # for native modules
, schildichat-web
, callPackage
, Security
, AppKit
, CoreServices

, useWayland ? false

, cleanSchildichatDesktopSource
, schildichat-desktop-src ? ../.
}:

let
  packageJSON = schildichat-desktop-src + "/element-desktop/package.json";
  yarnLock = schildichat-desktop-src + "/element-desktop/yarn.lock";

  package = builtins.fromJSON (builtins.readFile packageJSON);

  pname = "schildichat-desktop";
  version = package.version;

  executableName = pname;

  electron_exec = if stdenv.isDarwin then "${electron}/Applications/Electron.app/Contents/MacOS/Electron" else "${electron}/bin/electron";

in mkYarnPackage rec {
  inherit pname version packageJSON;

  src = cleanSchildichatDesktopSource (schildichat-desktop-src + "/element-desktop");

  nativeBuildInputs = [ makeWrapper ];

  inherit (element-desktop) seshat keytar;

  buildPhase = ''
    runHook preBuild

    export HOME=$(mktemp -d)
    pushd deps/schildichat-desktop/
    npx tsc
    yarn run i18n
    node ./scripts/copy-res.js
    popd
    rm -rf node_modules/matrix-seshat node_modules/keytar
    ln -s $keytar node_modules/keytar
    ln -s $seshat node_modules/matrix-seshat

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    # resources
    mkdir -p "$out/share/element"
    ln -s '${schildichat-web}' "$out/share/element/webapp"
    cp -r './deps/schildichat-desktop' "$out/share/element/electron"
    cp -r './deps/schildichat-desktop/res/img' "$out/share/element"
    rm "$out/share/element/electron/node_modules"
    cp -r './node_modules' "$out/share/element/electron"
    cp $out/share/element/electron/lib/i18n/strings/en_EN.json $out/share/element/electron/lib/i18n/strings/en-us.json
    ln -s $out/share/element/electron/lib/i18n/strings/en{-us,}.json

    # icons
    for icon in $out/share/element/electron/build/icons/*.png; do
      mkdir -p "$out/share/icons/hicolor/$(basename $icon .png)/apps"
      ln -s "$icon" "$out/share/icons/hicolor/$(basename $icon .png)/apps/element.png"
    done

    # desktop item
    mkdir -p "$out/share"
    ln -s "${desktopItem}/share/applications" "$out/share/applications"

    # executable wrapper
    makeWrapper '${electron_exec}' "$out/bin/${executableName}" \
      --add-flags "$out/share/element/electron${lib.optionalString useWayland " --enable-features=UseOzonePlatform --ozone-platform=wayland"}"

    runHook postInstall
  '';

  # Do not attempt generating a tarball for element-web again.
  # note: `doDist = false;` does not work.
  distPhase = ''
    true
  '';

  # The desktop item properties should be kept in sync with data from upstream:
  # https://github.com/vector-im/element-desktop/blob/develop/package.json
  desktopItem = makeDesktopItem {
    name = "schildichat-desktop";
    exec = "${executableName} %u";
    icon = "schildichat";
    desktopName = "SchildiChat";
    genericName = "Matrix Client";
    categories = "Network;InstantMessaging;Chat;";
    extraEntries = ''
      StartupWMClass=schildichat
      MimeType=x-scheme-handler/element;
    '';
  };
}
