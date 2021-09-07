{ stdenv
, mkYarnModules
, nodejs
, cleanSchildichatDesktopSource
, schildichat-desktop-src ? ../.
, ...
}:

let
  packageJSON = schildichat-desktop-src + "/element-web/package.json";
  yarnLock = schildichat-desktop-src + "/element-web/yarn.lock";

  package = builtins.fromJSON (builtins.readFile packageJSON);

  pname = "schildichat-web";
  version = package.version;

  modules = mkYarnModules {
    name = "${pname}-modules-${version}";
    inherit pname version packageJSON yarnLock;
  };

in stdenv.mkDerivation {
  inherit pname version;

  src = cleanSchildichatDesktopSource schildichat-desktop-src;

  buildInputs = [ nodejs ];

  postPatch = ''
    patchShebangs .
  '';

  configurePhase = ''
    runHook preConfigure

    cp configs/sc/config.json element-web/
    cp -r ${modules}/node_modules node_modules
    chmod u+rwX -R node_modules
    rm -rf node_modules/matrix-react-sdk
    ln -s $PWD/matrix-react-sdk node_modules/
    ln -s $PWD/node_modules matrix-react-sdk/
    ln -s $PWD/node_modules element-web/

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    pushd matrix-react-sdk
    node_modules/.bin/reskindex -h ../element-web/src/header
    popd

    pushd element-web
    node scripts/copy-res.js
    node_modules/.bin/reskindex -h ../element-web/src/header
    node_modules/.bin/webpack --progress --mode production
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r element-web/webapp $out

    runHook postInstall
  '';

  passthru = {
    inherit modules;
  };
}
