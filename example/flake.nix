{
  description = "nix-deno example";

  inputs = {
    nixpkgs.url = github:nixos/nixpkgs/nixpkgs-unstable;
    utils.url = "github:gytis-ivaskevicius/flake-utils-plus";
    nix-deno.url = "path:../";
  };

  outputs = inputs@{ self, nixpkgs, utils, nix-deno }:
    utils.lib.mkFlake {
      inherit self inputs;

      sharedOverlays = [ nix-deno.overlay ];

      outputsBuilder = channels:
        let pkgs = channels.nixpkgs; in
        rec {
          packages = {
            example = pkgs.mkDenoDrv {
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
        };
    };
}
