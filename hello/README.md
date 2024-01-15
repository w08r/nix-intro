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
