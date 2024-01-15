FROM ubuntu:latest AS base
FROM base AS nix-base

RUN apt update --fix-missing                                                                && \
    apt install -y curl xz-utils sudo                                                       && \
    echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers                                     && \
    adduser user --disabled-password                                                        && \
    su - user -c 'bash <(curl -L https://nixos.org/nix/install) --no-daemon --yes'          && \
    echo '. /home/user/.nix-profile/etc/profile.d/nix.sh' >> /home/user/.bashrc             && \
    SUDO_FORCE_REMOVE=yes apt remove -y curl xz-utils sudo                                  && \
    mkdir -p /home/user/.config/nix                                                         && \
    chown -R user:nogroup /home/user                                                        && \
    echo 'experimental-features = nix-command flakes' > /home/user/.config/nix/nix.conf     && \
    apt-get clean                                                                           && \
    rm -rf /var/cache/apt/lists

FROM nix-base
USER user
ENV USER=user
