FROM ubuntu:latest AS base
FROM base AS nix-base

RUN apt update && apt install -y curl xz-utils sudo
RUN echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN adduser user --disabled-password
USER user
ENV USER=user
RUN bash -c 'bash <(curl -L https://nixos.org/nix/install) --no-daemon --yes'

FROM nix-base

