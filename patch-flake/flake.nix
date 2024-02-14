{
  description = "A very basic flake patchs";

  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.hello-flake.url = "github:w08r/nix-intro?dir=hello-flake";

  outputs = { self, nixpkgs, flake-utils, hello-flake }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};


        hello-flake-patch = pkgs.stdenv.mkDerivation {
            name = "hello-flake-patch";
            src = "${hello-flake}/hello-flake.tar";
            patches = [ ./hello.patch ];
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
