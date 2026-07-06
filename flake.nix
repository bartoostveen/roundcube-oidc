{
  description = "roundcube-oidc development tree";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs =
    inputs@{ self, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:

      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        imports = [
          inputs.treefmt-nix.flakeModule
        ];

        perSystem =
          {
            pkgs,
            ...
          }:

          {
            treefmt = {
              programs.nixfmt.enable = true;
              programs.deadnix.enable = true;
            };

            packages = {
              default = (pkgs.callPackage ./package.nix { }).overrideAttrs {
                version = self.shortRev or self.dirtyShortRev or "dirty-norev";
                __intentionallyOverridingVersion = true;
              };
            };

            devShells.default = pkgs.mkShell {
              packages = with pkgs; [
                php
                phpPackages.composer
              ];
            };
          };
      }
    );
}
