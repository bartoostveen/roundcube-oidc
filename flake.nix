{
  description = "roundcube-oidc development tree";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

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
      { withSystem, ... }:

      {
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];

        imports = [
          inputs.treefmt-nix.flakeModule
        ];

        flake.overlays.default = _: prev: {
          roundcube-oidc = withSystem prev.stdenv.hostPlatform.system (
            { self', ... }: self'.packages.default
          );
        };

        perSystem =
          {
            self',
            pkgs,
            system,
            lib,
            ...
          }:

          let
            inherit (lib) getExe;
            inherit (pkgs.python314Packages) towncrier;

            composerVersion = (./composer.json |> builtins.readFile |> builtins.fromJSON).version;
            version = "${composerVersion}-${self.shortRev or self.dirtyShortRev or "dirty-norev"}";
          in
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                self.overlays.default
                (final: _: { php = final.php85; })
              ];
            };

            treefmt = {
              programs.nixfmt.enable = true;
              programs.deadnix.enable = true;
              programs.php-cs-fixer.enable = true;
              settings.phpstan = {
                command = getExe pkgs.phpstan;
                options = [
                  "--memory-limit=1024M"
                  "--fix"
                ];
                includes = [ "**/*.php" ];
              };
            };

            packages = {
              default = (pkgs.callPackage ./package.nix { }).overrideAttrs {
                inherit version;
                __intentionallyOverridingVersion = true;
              };
              towncrier-build = pkgs.writeShellApplication {
                name = "towncrier-build";
                runtimeInputs = [ towncrier ];
                text = ''
                  towncrier build --version "${composerVersion}" --yes "$@"
                '';
              };
              tag-release = pkgs.writeShellApplication {
                name = "tag-release";
                runtimeInputs = [
                  pkgs.git
                  pkgs.nix-update
                  self'.packages.towncrier-build
                ];
                text = ''
                  towncrier-build
                  nix-update default -F --version=skip
                  git add .
                  git commit -m "chore: Release ${composerVersion}"
                  git tag "v${composerVersion}" -m "Release ${composerVersion}"
                  git show
                '';
              };
            };

            devShells.default = pkgs.mkShell {
              packages = with pkgs; [
                php
                phpPackages.composer
                towncrier
                self'.packages.towncrier-build
                self'.packages.tag-release
              ];
            };

            checks.nixos = import ./check.nix |> pkgs.testers.runNixOSTest;
          };
      }
    );
}
