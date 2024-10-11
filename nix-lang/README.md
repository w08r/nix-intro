# The Nix Language

## Lexicon
- A piece of Nix code is an *expression*
- Evaluating a Nix expression produces a Nix *value*.

## The REPL Revisited

```sh
# enter nix repl
nix repl

```

Inside REPL
```sh
# quit repl
:q
# 
```

## General Notes
- In Nix, linebreaks, indentations and additional spaces are for reader's convinience.
  ```nix
  let
   x = 1;
   y = 1;
  in x + y
  
  # equivalent to 
  let x=1; y=1; in x + y
  ```

## Basic Types

Attributes
```nix
{
  string = "hello";
  integer = 1;
  float = 3.141;
  bool = true;
  null = null;
  list = [ 1 "two" false ];
  attribute-set = {
    a = "hello";
    b = 2;
    c = 2.718;
    d = false;
  }; # comments are supported
}
```
Notes:
- Lists are separated by spaces.

Recursive Attributes
```nix
rec {
  one = 1;
  two = one + 1;
  three = two + 1;
}
```
Notes:
- Order does not matter.
- `rec` is required if recursive attribute.


`let ... in ...`
```nix
let
  b = a + 1;
  a = 1;
in
a + b
```
Notes:
- Allows for repeated usage of values.
- Order does not matter `let a=1;b=a-1 ...` is equivalent to `let b=a-1;a=1 ...`.

Attribute Access
```nix
# access
let
  attrset = { a = { b = { c = 1; }; }; };
in
attrset.a.b.c

# assignment
{ a.b.c = 1; } # output { a = { b = { c = 1; }; }; }
```

`with ...; ...`
```nix
let
  a = {
    x = 1;
    y = 2;
    z = 3;
  };
in
with a; [ x y z ]
# output [ 1 2 3 ]
```
Notes:
- Allows access to attributes without repeating reference to parent attribute set.

`inherit ...`

```
let
  x = 1;
  y = 2;
in
{
  inherit x y; # equivalent to x = x; y = y;
}

# more complex example with attribute set
let
  a = { x = 1; y = 2; };
in
{
  inherit (a) x y; # equivalent to x = a.x; y = a.y;
}
```
Notes: 
- Assigning value from existing scope in nested scope

String interpolation
```nix
let
  a = "no";
  c = "foo";
in
{
  d = ${c};
  "${a + " ${a + " ${a}"}"}" # output no no no
}

# indend and string
''
  one
   two
    three
''

"multi\nline\nstring\n"

```

File System Paths
```nix
<nixpkgs> # lookup path (equivalent to /nix/var/nix/profiles/per-user/root/channels/nixpkgs)
```
Notes:
- Points to revision onf Nixpkgs on filesystem.

## Data Structures

## Functions
Functions take exactly 1 argument.
Function and body are separated by `:`.

```nix
x: x + 1 # returns a lambda
# multiple arguments
x: y: x + y # uses nesting
# attribute set with default
{ a, b ? 0 }: a + b
# args@{ a, b, ... }: a + b + args.c
```

Calling Function
```nix
let
  f = x: x.a;
in
f { a = 1; }
```


Since function and argument are separated by white space, sometimes parentheses `(` `)`xs are required to achieve the desired result.
*Caution*
```nix
let
 f = x: x + 1;
 a = 1;
in [ (f a) ]

# different to 
let
 f = x: x + 1;
 a = 1;
in [ f a ]
```

```nix
Since function and argument are separated by white space, sometimes parentheses `(` `)`xs are required to achieve the desired result.
*Caution*
```nix
let
 f = x: x + 1;
 a = 1;
in [ (f a) ]

# different to 
let
 f = x: x + 1;
 a = 1;
in [ f a ]
```

```nix
let
  f = {a, b ? 0}: a + b;
in
f { a = 1; } # ok since defaultable b
```

Libraries
- `builtins` - basic functions (e.g. `builtins.toString`) built in C++.
- `import` - top level to import a `.nix` file.
- `pkgs.lib` - useful functions built in Nix.

## Modified the Context

## Working with External Data

Fetchers
`builtins.fetchurl`, `builtins.fetchTarball`, ..., `builtins.fetchGit`
- Evaluate a filesystem path to a Nix store.

## Derivations
Derivations are at the core of Nix:
- Nix language is used to describe derivations.
- Nix runs derivations to produce built results.
- Built results can be used for other derivations.

`stend.Derivation` - creates a derivation that Nix will eventually build.


## Full example
```nix
{ pkgs ? import <nixpkgs> {} }:
let
  message = "hello world";
in
pkgs.mkShell {
  buildInputs = with pkgs; [ cowsay ];
  shellHook = ''
    cowsay ${message}
  '';
}
```
Notes
- Nix expression is a function.
