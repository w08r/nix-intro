{
  description = "A simple unix program";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        p = nixpkgs.legacyPackages.${system};
      in
        {
          packages = {
            default = p.stdenv.mkDerivation {
              name = "hello-flake";
              src = ./hello-flake.tar;
            };
          };
        }
    );
}
