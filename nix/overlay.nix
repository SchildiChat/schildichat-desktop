final: prev: {
  cleanSchildichatDesktopSource = src: with final.lib; cleanSourceWith {
    filter = name: type: cleanSourceFilter name type
      && !(hasInfix "/node_modules/" name)
      && !(hasInfix "/nix/" name && hasSuffix ".nix" name)
    ;
    inherit src;
  };
  schildichat-web = final.callPackage ./schildichat-web.nix {};
  schildichat-desktop = final.callPackage ./schildichat-desktop.nix {
    inherit (final.darwin.apple_sdk.frameworks) Security AppKit CoreServices;
  };
  schildichat-desktop-wayland = final.callPackage ./schildichat-desktop.nix {
    inherit (final.darwin.apple_sdk.frameworks) Security AppKit CoreServices;
    useWayland = true;
  };
}
