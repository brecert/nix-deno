{
  description = "utilities for working with deno";

  outputs = { self }:
    {
      lib.makeDenoPlatform = pkgs: {
        mkDenoDrv = { name, src, lockfile, entrypoint, denoFlags ? [ ] }@args:
          let
            inherit (builtins) split hashString toJSON;
            inherit (pkgs) lib fetchurl linkFarm writeText runCommand deno;
            inherit (pkgs.lib) elemAt flatten mapAttrsToList importJSON;
            inherit (pkgs.stdenv) mkDerivation;

            urlPart = url: elemAt (flatten (split "://([a-z0-9\.]*)" url));
            artifactPath = url: "${urlPart url 0}/${urlPart url 1}/${hashString "sha256" (urlPart url 2)}";

            dep = url: sha256: [
              {
                name = artifactPath url;
                path = fetchurl { inherit url sha256; };
              }
              {
                name = (artifactPath url) + ".metadata.json";
                path = writeText "metadata.json" (toJSON {
                  inherit url;
                  headers = { };
                });
              }
            ];

            deps = linkFarm "deps" (flatten (mapAttrsToList dep (importJSON lockfile)));
          in
          mkDerivation
            ({
              buildPhase = ''
                export DENO_DIR=`mktemp -d`
                ln -s "${deps}" "$DENO_DIR/deps"

                ${deno}/bin/deno compile $denoFlags --lock="$lockfile" --cached-only -o "$name" "$entrypoint"
              '';

              installPhase = ''
                mkdir -p "$out/bin"
                mv "$name" "$out/bin/"
              '';

              # disable stripping, which was removing the scripts from the binary 
              fixupPhase = ":";
            } // args);
      };

      overlay = final: pkgs: self.lib.makeDenoPlatform pkgs;
    };
}
