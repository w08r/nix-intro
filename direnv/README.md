# Nix and Direnv

`direnv` is an extension for your shell. It augments existing shells
with a new feature that can load and unload environment variables
depending on the current directory. (from https://direnv.net/).

`direnv` knows about nix flakes already.  Let's take a look at what
happens in this directory if you have `direnv` installed.  When first
entering it, you may see something like this:

```
direnv: error /me/nix-intro/direnv/.envrc is blocked. Run `direnv allow` to approve its content
```

Running `direnv allow` we see the following:

```
$ direnv allow
... prints a dissappearing message from nix ...
$ which python
/nix/store/al81jk4wz596q8if684x6a9mqlv7vc3z-python3-3.11.7/bin/python
```

As if by magic, you know have a very specific version of python at the
front of your path.  This is pinned to place by the `flake.lock`.

There's not a lot of magic currently in the `.envrc` within this
directory, though there's a lot more it can do which we'll come back
to.

From this point on, we'll use direnv within tutorials to further
demonstrate some of its capabilities.
