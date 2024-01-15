build:
    nix build
    rm -rf target
    docker load < result

run: build
    docker run --rm -it -p 8000:8000 demo:latest

dev:
    nix develop

cargo2nix:
    nix run github:cargo2nix/cargo2nix

lock: cargo2nix
    nix flake lock
