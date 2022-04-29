{
  description = "nix-deno example";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    flake-utils.url = "github:numtide/flake-utils";
    nix-deno.url = "path:../";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, nix-deno }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        deno = nix-deno.lib.makeDenoPlatform pkgs;
      in
      rec {
        packages = {
          example = deno.mkDenoDrv {
            name = "example";
            src = builtins.path {
              path = ./.;
              name = "example";
            };
            lockfile = ./lockfile.json;
            entrypoint = "fetch.ts";
            denoFlags = [ "--allow-net" "--allow-write" ];
          };
        };

        defaultPackage = packages.example;
        defaultApp = packages.example;
      }
    );
}
