# Hello (Flake)!

You can follow along with this tutorial in the docker container we
started in the previous section, or on the nix host of your choice.

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
error: flake 'git+file:///me/nix-intro?dir=hello-flake' does not provide attribute 'apps.aarch64-darwin.default', 'defaultApp.aarch64-darwin', 'packages.aarch64-darwin.default' or 'defaultPackage.aarch64-darwin'
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

## A builder

Let's make some adjustments to our flake and add a tiny bit of source
code to compile as part of the flake build.

Change the `flake.nix` file to look like this, adjusting `sys` to
match your local system:

```
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
```

Add a hello world c file, e.g.

```
#include <stdio.h>

int main() {
  printf("Hello, (flake)!\n");
  return 0;
}
```

Then run `nix build`:

```
$ nix build

$ ./result/bin/hello-flake 
Hello, (flake)!
```

If we want to inspect the derivation, we can see it matches closely

the input in the flake:

```
$ nix derivation show  
{
  "/nix/store/an1hih9z3rj1lyzc084vnkcsmfqfnjnj-hello.drv": {
    "args": [
      "-c",
      "/nix/store/rnyx460h4nyc9gfh6w1ba0nijj17n1x8-coreutils-9.4/bin/mkdir -p $out/bin;\n/nix/store/a2ab91yd6r460ff62rck2id46vgfnzzr-gcc-wrapper-12.3.0/bin/gcc -o $out/bin/hello-flake /nix/store/pbh3a4x4vhxz90fm8fv9vx82lrwssz8h-hello-flake.c\n"
    ],
    "builder": "/nix/store/lv74m20f3z7pa60mxm3zsvxldq031qph-bash-5.2-p21/bin/bash",
    "env": {
      "builder": "/nix/store/lv74m20f3z7pa60mxm3zsvxldq031qph-bash-5.2-p21/bin/bash",
      "name": "hello",
      "out": "/nix/store/axs6h57bkwa2r137m8gh93psvbb99m1k-hello",
      "system": "aarch64-darwin"
    },
    "inputDrvs": {
      "/nix/store/ggpn3ridnikxwci1413h5am424ak8jnn-bash-5.2-p21.drv": [
        "out"
      ],
      "/nix/store/kcj3kjlmm3g4rzj9f343fr9xh4ppfdnb-coreutils-9.4.drv": [
        "out"
      ],
      "/nix/store/q6imw7bn5zn5mgd8kl8ng3z941l6mhp9-gcc-wrapper-12.3.0.drv": [
        "out"
      ]
    },
    "inputSrcs": [
      "/nix/store/pbh3a4x4vhxz90fm8fv9vx82lrwssz8h-hello-flake.c"
    ],
    "name": "hello",
    "outputs": {
      "out": {
        "path": "/nix/store/axs6h57bkwa2r137m8gh93psvbb99m1k-hello"
      }
    },
    "system": "aarch64-darwin"
  }
}
```

We can also install the flake into the local profile:

```
$ nix profile install  

$ which hello-flake
/me/.nix-profile/bin/hello-flake

$ nix profile list | rg hello-flake
32 git+file:///me/nix-intro?dir=hello-flake#packages.aarch64-darwin.default git+file:///me/nix-intro?dir=hello-flake#packages.aarch64-darwin.default /nix/store/axs6h57bkwa2r137m8gh93psvbb99m1k-hello
```
