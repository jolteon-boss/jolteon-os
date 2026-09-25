# Jolteon OS: Bazzite with T2 Mac hardware enablement.
# The T2 kernel must replace Bazzite's kernel; user-space packages alone are
# insufficient for the internal keyboard, trackpad, Wi-Fi, audio, and fans.

FROM scratch AS ctx
COPY build_files /

FROM ghcr.io/ublue-os/bazzite:stable

COPY variants/common/etc/ /etc/
COPY files/system/ /
COPY wallpapers/ /usr/share/wallpapers/

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/var \
    /ctx/t2-enablement.sh && \
    rm -rf /tmp/* /var/tmp/*

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/ublue-packages.sh

RUN bootc container lint

LABEL containers.bootc="1" \
      ostree.bootable="1" \
      org.opencontainers.image.title="Jolteon OS" \
      org.opencontainers.image.description="Bazzite with T2 Mac hardware enablement"
