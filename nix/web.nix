{ inputs, pkgs }:

let
  packageJSON = inputs.web + "/package.json";
  yarnLock = inputs.web + "/yarn.lock";

  package = builtins.fromJSON (builtins.readFile packageJSON);

  pname = "schildichat-web";
  version = package.version;

  modules = pkgs.mkYarnModules {
    name = "${pname}-modules-${version}";
    inherit pname version packageJSON yarnLock;
  };
in pkgs.stdenv.mkDerivation {
  inherit pname version;

  src = inputs.web;
  buildInputs = with pkgs; [ nodejs ];

  postPatch = ''
    patchShebangs .
  '';

  configurePhase = ''
    runHook preConfigure

    # TODO: find a way to copy default configuration
    # cp configs/sc/config.json element-web/
    cp -r ${modules}/node_modules .

    chmod u+rwX -R node_modules
    rm -rf element-web
    mkdir element-web
    
    cp -r ${inputs.web}/* element-web
    ln -s $PWD/node_modules element-web/

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild

    pushd element-web
    node scripts/copy-res.js
    node_modules/.bin/webpack --progress --mode production
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r element-web/webapp $out

    runHook postInstall
  '';

  passthru = { inherit modules; };
}