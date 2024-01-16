# Hello (Flake)!

## A very basic flake

To bootstrap a flake, you can run `nix flake init`.  You'll be served
up a `flake.nix` that looks something like this:

```
{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello = nixpkgs.legacyPackages.x86_64-linux.hello;

    packages.x86_64-linux.default = self.packages.x86_64-linux.hello;

  };
}
```

Running `nix run` you may or may not get some sensible output.  Running on an m1 I get the following:

```
error: flake 'git+file:///Users/wob/src/tmp/nix-intro?dir=hello-flake' does not provide attribute 'apps.aarch64-darwin.default', 'defaultApp.aarch64-darwin', 'packages.aarch64-darwin.default' or 'defaultPackage.aarch64-darwin'
```

Making a small adjustment to the `flake.nix` file and setting the
content to the following will help:

```
{
  description = "A very basic flake";

  outputs = { self, nixpkgs }: {

    packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.hello;

  };
}
```

Then running `nix run` will yield the correct output:

```
Hello, world!
```
