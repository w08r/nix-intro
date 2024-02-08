# Patch a flake

`git` patches can be applied to derivations in flakes. These will patch the src part of the derivation with the diff you supplied before building the derivation.

This is particularly useful if one of your packages has a known issue and you can't wait until the fix to be released. 


Following on [hello-nix](../hello-nix/README.md), we can import `../hello-nix/flake.nix` and provide the following patch

```nix
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

```
