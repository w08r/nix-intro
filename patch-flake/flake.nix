{
  description = "A very basic flake patchs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.hello-flake.url = "github:w08r/nix-intro?dir=hello-flake";
  inputs.patch-flake.url = "github:jfgr27/nix-intro?dir=patch-flake&ref=patch-flake";

  outputs = { self, nixpkgs, flake-utils, hello-flake, patch-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        hello-flake-patch = pkgs.stdenv.mkDerivation {
            name = "hello-flake-patch";
            src = hello-flake;
            patches = [ "${patch-flake}/hello-patch" ];
            system = system;
          };
      in
        {
          devShells = rec {
            default = pkgs.mkShell {
              packages = [
                hello-flake-patch
              ];
            };
          };
        }
    );
}
