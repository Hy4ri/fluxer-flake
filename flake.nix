{
  description = "Fluxer Nix Flake - Desktop messaging client";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "x86_64-linux"
      "aarch64-linux"
    ];

    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    nixpkgsFor = forAllSystems (system:
      import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      });
  in {
    packages = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
    in {
      fluxer = pkgs.callPackage ./fluxer.nix {};
      fluxer-canary = pkgs.callPackage ./fluxer-canary.nix {};
      default = self.packages.${system}.fluxer;
    });

    overlays = {
      fluxer = final: prev: {
        fluxer = final.callPackage ./fluxer.nix {};
      };

      fluxer-canary = final: prev: {
        fluxer-canary = final.callPackage ./fluxer-canary.nix {};
      };

      default = final: prev:
        self.overlays.fluxer final prev
        // self.overlays.fluxer-canary final prev;
    };
  };
}
