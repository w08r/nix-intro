{
  description = "A development environment";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        p = nixpkgs.legacyPackages.${system};
      in
        {
          devShells = rec {
            default = nixpkgs.legacyPackages.${system}.mkShell {
              packages = [
                p.python3
              ];
            };
          };
        }
    );
}
