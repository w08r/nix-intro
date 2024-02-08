{
  description = "A very basic flake patch using hello-flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs }:
    let
      sys = "aarch64-darwin";
    in
      {
        hello-flake = import ../hello-flake/flake.nix;

        hello-flake-outputs = hello-flake.outputs {
          inherit nixpkgs;
        };

        foo = foo-outputs.packages.${system}.default;

        packages."${sys}".default = derivation {
          hello_flake
        ];
        };
      };
}
