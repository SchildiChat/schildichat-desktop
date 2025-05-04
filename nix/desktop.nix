{ inputs, pkgs, useWayland ? false }:

let
  packageJSON = inputs.desktop + "/package.json";
  yarnLock = inputs.desktop + "/yarn.lock";

  schildichat-web = pkgs.callPackage ./web.nix { inherit inputs pkgs; };
  package = builtins.fromJSON (builtins.readFile packageJSON);

  pname = "schildichat-desktop";
  version = package.version;

  electron_exec = if pkgs.stdenv.isDarwin 
    then "${pkgs.electron}/Applications/Electron.app/Contents/MacOS/Electron"
    else "${pkgs.electron}/bin/electron";
in pkgs.mkYarnPackage rec {
  inherit (pkgs.element-desktop) seshat keytar;
  inherit pname version packageJSON;

  src = inputs.desktop;
  nativeBuildInputs = with pkgs; [ makeWrapper ];

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
    ln -s "${builtins.elemAt desktopItems 0}/share/applications" "$out/share/applications"

    # executable wrapper
    makeWrapper '${electron_exec}' "$out/bin/${pname}" \
      --add-flags "$out/share/element/electron${pkgs.lib.optionalString useWayland " --enable-features=UseOzonePlatform --ozone-platform=wayland"}"

    runHook postInstall
  '';

  distPhase = "true";
  desktopItems = [
    (pkgs.makeDesktopItem {
      name = "schildichat-desktop";
      exec = "${pname} %u";
      icon = "schildichat";
      desktopName = "SchildiChat";
      genericName = "Matrix Client";
      categories = ["Network" "InstantMessaging" "Chat"];
      extraConfig = {
        StartupWMClass = "schildichat";
        MimeType = "x-scheme-handler/element";
      };
    })
  ];
}