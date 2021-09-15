{
  description = "The SchildiChat Matrix client";

  inputs.nixpkgs.url = github:NixOS/nixpkgs;

  outputs = { self, nixpkgs }: let
    systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);

    overlay = import ./nix/overlay.nix;

    # Memoize nixpkgs for different platforms for efficiency.
    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        overlays = [ overlay ];
      });
  in {
    inherit overlay;

    packages = builtins.mapAttrs (system: pkgs: {
      inherit (pkgs)
        schildichat-web
        schildichat-desktop
        schildichat-desktop-wayland
      ;
    }) nixpkgsFor;

    defaultPackage = forAllSystems (system: self.packages.${system}.schildichat-desktop);

    apps = forAllSystems(system: {
      schildichat-desktop = {
        type = "app";
        program = "${self.packages.${system}.schildichat-desktop}/bin/schildichat-desktop";
      };
      schildichat-desktop-wayland = {
        type = "app";
        program = "${self.packages.${system}.schildichat-desktop-wayland}/bin/schildichat-desktop";
      };
    });

    defaultApp = forAllSystems (system: self.apps.${system}.schildichat-desktop);
  };
}
