# Hello

This minimal nix install in a docker serves to provide a simple and
harmeless local playground for learning intial nix mechanics.

```
docker build -t hello .
```

```
$ docker run --rm --entrypoint bash -it hello
$ nix profile install nixpkgs#cowsay
...
$ cowsay moo
 _____ 
< moo >
 ----- 
        \   ^__^
         \  (oo)\_______
            (__)\       )\/\
                ||----w |
                ||     ||

```

## Registry

What happened there?  We asked nix to install, into our current
profile, the package `cowsay` from the `nixpkgs` flake.

What version was installed?

Let's take a look:

```
user@40a4bcde2962:/$ cowsay -h
.cowsay-wrapped version 3.7.0
...
```

The version installed in determined by the version of the `nixpkgs`
flake used.  In this case, the `nixpkgs` flake, referenced on the
above command line, is resolved to a repo using the nix registry and
installed from there.  We'll cover some of the details of that
installation later.  For now lets make a small adjustment to the
registry and reinstall the tool.

```
# remove the 1st package from our profile
$ nix profile remove 1
removing 'flake:nixpkgs#legacyPackages.aarch64-linux.cowsay'

# update the registry to point to an older nix version
$ nix registry add nixpkgs github:NixOS/nixpkgs/22.05

# reinstall cowsay, having updated the registry
$ nix profile install nixpkgs#cowsay

# run the usage again, note the different version
$ cowsay -h
cow{say,think} version 3.03, (c) 1999 Tony Monroe
```

## History

Let's take a look at the current history of our profile:

```
$ nix profile history
Version 1 (2024-01-15):
  nix: ∅ -> 2.19.2

Version 2 (2024-01-16) <- 1:
  flake:nixpkgs#legacyPackages.aarch64-linux.cowsay: ∅ -> 3.7.0, 3.7.0-man

Version 3 (2024-01-16) <- 2:
  flake:nixpkgs#legacyPackages.aarch64-linux.cowsay: 3.7.0, 3.7.0-man -> ∅

Version 4 (2024-01-16) <- 3:
  flake:nixpkgs#legacyPackages.aarch64-linux.cowsay: ∅ -> 3.04, 3.04-man

```

We can see that the record of different states over time matches our
behaviour in this tutorial.  Moreover, it is possible to jump to any
of those points in history, e.g.

```
$ nix profile rollback --to 2
switching profile from version 4 to 2

$ cowsay -h
.cowsay-wrapped version 3.7.0
```

Notice that switching between increments in time is super fast.  All
the necessary data is already stored locally in the nix store.
Switching is just a case of re-ppointing the latest profile link to a
different version.

## Store

Let's take a look at what the profile is:

```
$ ls -l ~/.nix-profile
lrwxrwxrwx 1 user nogroup 44 Jan 16 13:46 /home/user/.nix-profile -> /home/user/.local/state/nix/profiles/profile

$ ls -l /home/user/.local/state/nix/profiles/profile
lrwxrwxrwx 1 user user 14 Jan 16 14:38 /home/user/.local/state/nix/profiles/profile -> profile-2-link

$ ls -l /home/user/.local/state/nix/profiles/profile-2-link
lrwxrwxrwx 1 user user 51 Jan 16 14:38 /home/user/.local/state/nix/profiles/profile-2-link -> /nix/store/nwz02v3d71383p0ja5hkizbm92pg4myb-profile

$ ls -l /nix/store/nwz02v3d71383p0ja5hkizbm92pg4myb-profile
total 16
dr-xr-xr-x 2 user user 4096 Jan  1  1970 bin
lrwxrwxrwx 1 user user   58 Jan  1  1970 etc -> /nix/store/761hq0abn07nrydrf6mls61bscx2vz2i-nix-2.19.2/etc
lrwxrwxrwx 1 user user   58 Jan  1  1970 lib -> /nix/store/761hq0abn07nrydrf6mls61bscx2vz2i-nix-2.19.2/lib
lrwxrwxrwx 1 user user   62 Jan  1  1970 libexec -> /nix/store/761hq0abn07nrydrf6mls61bscx2vz2i-nix-2.19.2/libexec
-r--r--r-- 1 user user  457 Jan  1  1970 manifest.json
dr-xr-xr-x 3 user user 4096 Jan  1  1970 share
```

As can be seen above.  The profile is essentially a tree formed with
symbolic links and, eventually, some actual files located in the
directory tree under `/nix/store`.

Let's take a look at `cowsay`:

```
$ ls -l $(which cowsay)
lrwxrwxrwx 1 user user 67 Jan  1  1970 /home/user/.nix-profile/bin/cowsay -> /nix/store/fsana1m00f7j3prz6w24zj2gfr7f6slw-cowsay-3.7.0/bin/cowsay

$ ls -l /nix/store/fsana1m00f7j3prz6w24zj2gfr7f6slw-cowsay-3.7.0/bin/cowsay
-r-xr-xr-x 1 user user 479 Jan  1  1970 /nix/store/fsana1m00f7j3prz6w24zj2gfr7f6slw-cowsay-3.7.0/bin/cowsay
```

The `cowsay` found on the path (in `~/.nix-profile/bin`) is also a
symbolic link to a file found in the nix store.

## Derivations

The data in the nix store is the output of derivations, which are one
of the key ideas underlying nix.  A derivation describes how to build
something; it can be composed of other derivations, has inputs and
outputs.  We can examine the `cowsay` derivation like this:

```
$ nix derivation show nixpkgs#cowsay
{
  "/nix/store/gncy6jhm8kv4v3d9xindj9n8v6xjdg86-cowsay-3.04.drv": {
    "args": [
      "-e",
      "/nix/store/9krlzvny65gdc8s7kpb6lkx8cd02c25b-default-builder.sh"

  ...
```

The beady-eyed observer will note that this refers to version 3.04 of
`cowsay` and not `3.7.0`.  This is because our registry is still
pointing us at the `nixpkgs` version `22.05`.  We could examine the
local-2 version using, for example, the following command: 

```
$ nix derivation show /home/user/.local/state/nix/profiles/profile-2-link/bin/cowsay 
{
  "/nix/store/jsf28v3hg3bywhb6yawlml4c9hjcd5dv-cowsay-3.7.0.drv": {
    "args": [
      "-e",
      "/nix/store/v6x3cs394jgqfbi0a42pam708flxaphh-default-builder.sh"
    ],
    "builder": "/nix/store/rapsfvcigspigw56szsb9gdl2iv6007x-bash-5.2-p21/bin/bash",
    "env": {
      "__structuredAttrs": "",
      "buildInputs": "/nix/store/711bj8pn6mjzqldyp6inalzmzw2y4b4g-perl-5.38.2",
      "builder": "/nix/store/rapsfvcigspigw56szsb9gdl2iv6007x-bash-5.2-p21/bin/bash",
      "cmakeFlags": "",
      "configureFlags": "",
      "depsBuildBuild": "",
      "depsBuildBuildPropagated": "",
      "depsBuildTarget": "",
      "depsBuildTargetPropagated": "",
      "depsHostHost": "",
      "depsHostHostPropagated": "",
      "depsTargetTarget": "",
      "depsTargetTargetPropagated": "",
      "doCheck": "",
      "doInstallCheck": "",
      "makeFlags": "prefix=/1rz4g4znpzjwh1xymhjpm42vipw92pr73vdgl6xs1hycac8kf2n9",
      "man": "/nix/store/hsa9qfla6946d4yl71bi1pkxbb3kjc1j-cowsay-3.7.0-man",
      "mesonFlags": "",
      "name": "cowsay-3.7.0",
      "nativeBuildInputs": "/nix/store/bfw3j7pl0hdx34c8zd5mf5s27pyhbp09-make-shell-wrapper-hook",
      "out": "/nix/store/fsana1m00f7j3prz6w24zj2gfr7f6slw-cowsay-3.7.0",
      "outputs": "out man",
      "patches": "/nix/store/2ph6g2p2r82ha64axqpw0pbclg5rq68m-9e129fa0933cf1837672c97f5ae5ad4a1a10ec11.patch",
      "pname": "cowsay",
      "postInstall": "wrapProgram $out/bin/cowsay \\\n  --suffix COWPATH : $out/share/cowsay/cows\n",
      "propagatedBuildInputs": "",
      "propagatedNativeBuildInputs": "",
      "src": "/nix/store/njxi0sclvggsdw89kr861q1bd8w7l902-source",
      "stdenv": "/nix/store/m1c1464albqrb8wphbv2g76wi1vk6482-stdenv-linux",
      "strictDeps": "",
      "system": "aarch64-linux",
      "version": "3.7.0"
    },
    "inputDrvs": {
      "/nix/store/6iaydg7sw66arfhddq5ypk418yphljy0-source.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      },
      "/nix/store/dzgqcj3aqdf8663gcslkcqs26f2y40k2-9e129fa0933cf1837672c97f5ae5ad4a1a10ec11.patch.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      },
      "/nix/store/igrw9h6x8c0g86qvgljc5k5rs3x1zmgd-stdenv-linux.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      },
      "/nix/store/is1amsny8ja64knxvzrynliylyy9yd57-make-shell-wrapper-hook.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      },
      "/nix/store/mwliv79nidfji7cacwyfqv11vhkni8zn-perl-5.38.2.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      },
      "/nix/store/qkc79fsjcp3acn70hsr84f8r4jqxwjxy-bash-5.2-p21.drv": {
        "dynamicOutputs": {},
        "outputs": [
          "out"
        ]
      }
    },
    "inputSrcs": [
      "/nix/store/v6x3cs394jgqfbi0a42pam708flxaphh-default-builder.sh"
    ],
    "name": "cowsay-3.7.0",
    "outputs": {
      "man": {
        "path": "/nix/store/hsa9qfla6946d4yl71bi1pkxbb3kjc1j-cowsay-3.7.0-man"
      },
      "out": {
        "path": "/nix/store/fsana1m00f7j3prz6w24zj2gfr7f6slw-cowsay-3.7.0"
      }
    },
    "system": "aarch64-linux"
  }
}
```

Examining the above, we can see that the references output in the last
few lines of the derivation description matches the location of the
actual `cowsay` script that we uncovered by following the symlinks.
We'll come to derivations in more detail in a later section.
