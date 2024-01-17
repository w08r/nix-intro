{
  description = "A very basic builder flake";

  outputs = { self, nixpkgs }:
    let
      sys = "aarch64-darwin";
    in
      {
        packages."${sys}".default = derivation {
          name = "hello";
          system = sys;
          builder = ''${nixpkgs.legacyPackages."${sys}".bash}/bin/bash'';
          args = ["-c" ''
                         ${nixpkgs.legacyPackages."${sys}".coreutils.out}/bin/mkdir -p $out/bin;
                         ${nixpkgs.legacyPackages."${sys}".gcc}/bin/gcc -o $out/bin/hello-flake ${./hello-flake.c}
                  '' ];
        };
      };
}
