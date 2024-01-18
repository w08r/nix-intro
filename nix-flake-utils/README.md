# Nix and Flake Utils

## Nix

Let's go back to basics.  It's probably a good timet to delve a bit
into the nix language.

```
$ nix repl

Welcome to Nix 2.15.1. Type :? for help.

nix-repl> 
```

The nix repl (read-eval-print-loop) provides us with a ground to play
around a little with some of the constructs we've already been using.

Let's look at some of the standard data types and operations:

```
nix-repl> 1
1

nix-repl> 1 + 2
3

nix-repl> "a" + "b"
"ab"

nix-repl> a/b
/me/nix-intro/nix-flake-utils/a/b
```

What the ... !!

Remeber, nix is designed for providing a build and development
environment.  Whilst it's a fully fledged functional programming
language, it's also rather domain specific and there are some
subtletities that make it convenient for purpose but possibly
surprising when treated as a generic programming language.

We've already used some records, e.g.

```
nix-repl> rec { a = 1; b = a; }
{ a = 1; b = 1; }

```

And we've used functions:

```
nix-repl> a = arg: arg*2

nix-repl> a(5)           
10
```

## Flake utils

Let's look at that nifty function from the flake utils that gives us a
convenient way to produce data for any system on which we might be
running:

```
nix-repl> f = builtins.getFlake "github:numtide/flake-utils" 

nix-repl> f.lib.eachDefaultSystem                            
«lambda @ /nix/store/qkig73szmrhgp0qhncxy5vb36lw2g3jj-source/lib.nix:31:25»
```

Let's see how it works:

```
nix-repl> f.lib.eachDefaultSystem(s: { a = 1; } )     
{ a = { ... }; }

nix-repl> (f.lib.eachDefaultSystem(s: { a = 1; } )).a 
{ aarch64-darwin = 1; aarch64-linux = 1; x86_64-darwin = 1; x86_64-linux = 1; }
```

It performs this intriguing twist, s.t. that the records provided as
input are kinda convolved around a list of platforms provided by the
library function.  Turns out to work pretty sweetly in system-generic
flake definitions.
