# Nix Graphql Rust Demo

This is a small demo of a rust graphql server written for the purposes
of demoing some of the extensions to the standard nix ecosystem,
namely cargo2nix and dockertools.  Direnv integration is also provided.

## Basic usage

If direnv and nix (flakes) are available on your system, entry into
the current working directory should activate a build environment from
which you can start the server in development mode:

```
$ cargo run
    Finished dev [unoptimized + debuginfo] target(s) in 0.07s
     Running `target/debug/nix-gql-rs`
```

## Updating dependencies

To update the Cargo.nix file, run the following:

```
just cargo2nix
```

This will pin the locked dependencies from `Cargo.lock` into
`Cargo.nix` meaning that the nix store caching approach will apply to
crates.

## Building docker image

Run the following to build a docker image using nix docker tools:

```
just build
```

This will result in `demo:latest` being loaded into your current
docker registry, after which you can do the following:

```
docker run -it --rm --entrypoint /bin/nix-gql-rs -p 8000:8000 demo:latest
```

There is a just command (`just run`) which will both build and run the
docker image.

Go to http://localhost:8000 to view the graphiql page.  The following query should work:

```
{
  howdy 
}
```

## Github Actions

The github action workflow for this sub project highlights the
simplicity of caching nix dependencies.  Whilst the dependencies for
the flake herein span the rust toolchain, side tooling and the crate
dependencies themselves, all the compilation pre-requisites are
declared and pinned as part of the flake config and lock file.  That
means that caching the nix store after a build is all that needs to be
done to provide speedy incremental compilation of the whole project.
At time of writing, the non-cached build takes around 5 minutes and
the cached one takes about 1 minute which is a nice improve for a tiny
hello world app.
