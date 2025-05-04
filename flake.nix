{
  description = "The SchildiChat Matrix client";

  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs;

    desktop = {
      url = github:SchildiChat/element-desktop;
      flake = false;
    };

    web = {
      url = github:SchildiChat/element-web;
      flake = false;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: let
    systems = [ "x86_64-linux" "i686-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
  in {
    packages = forAllSystems(system: let pkgs = import nixpkgs {
      inherit system;
    }; in {
      schildichat-desktop = pkgs.callPackage ./nix/desktop.nix { inherit inputs pkgs; };
      schildichat-web = pkgs.callPackage ./nix/web.nix { inherit inputs pkgs; };

      schildichat-desktop-wayland = self.packages.${system}.schildichat-desktop.override { useWayland = true; };
    });
  };
}
