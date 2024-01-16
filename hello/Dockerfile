FROM ubuntu:latest AS base
FROM base AS nix-base

# Start by installing curl and xz to enable download of the nix
# installer and sudo to enable its operation.
RUN apt update --fix-missing
RUN apt install -y curl xz-utils sudo
RUN echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# We'll create a non-root user from where to run the nix installer
RUN adduser user --disabled-password

# Run the nix installer as non-root, using no-daemon.  This will
# install in single user mode.  Ensure the nix profile is set up
# when running a container from this image.
RUN su - user -c 'bash <(curl -L https://nixos.org/nix/install) --no-daemon --yes'
RUN echo '. /home/user/.nix-profile/etc/profile.d/nix.sh' >> /home/user/.bashrc

# Set up nix flakes.
RUN mkdir -p /home/user/.config/nix
RUN chown -R user:nogroup /home/user
RUN echo 'experimental-features = nix-command flakes' > /home/user/.config/nix/nix.conf

# Clean up the os stuff needed for installation.
RUN SUDO_FORCE_REMOVE=yes apt remove -y curl xz-utils sudo
RUN apt-get clean
RUN rm -rf /var/cache/apt/lists

FROM nix-base
USER user
ENV USER=user
