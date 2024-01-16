{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.hello;

  };
}
