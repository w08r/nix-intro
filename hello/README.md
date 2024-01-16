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
