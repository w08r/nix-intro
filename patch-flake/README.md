# Patch a flake

`git` patches can be applied to derivations in flakes. These will patch the src part of the derivation with the diff you supplied before building the derivation.

This is particularly useful if one of your packages has a known issue and you can't wait until the fix to be released. 


Following on [hello-nix](../hello-nix/README.md), we can patch remote`../hello-nix` flake and provide the following patch:

```nix
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
```
provided `./hello.patch`

```git
diff --git a/hello-flake.c b/hello-flake.c
--- a/hello-flake.c
+++ b/hello-flake.c
@@ -1,6 +1,6 @@
 #include <stdio.h>
 
 int main() {
-  printf("Hello, (flake)!\n");
+  printf("Hello, (flake patched)!\n");
   return 0;
 }

```

This will patch the flake according to the `git diff`. This results in 

```bash
nix develop

# inside nix shell
User1:patch-flake user1$ hello-flake
Hello, (flake patched)!
```



