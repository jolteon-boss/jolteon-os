# Jolteon OS

Jolteon OS is a local experiment: Bazzite with the T2 Linux kernel and
hardware enablement for the 2018 15-inch MacBook Pro with an Apple T2 chip.
Common model identifiers for this generation include `MacBookPro15,1` and
`MacBookPro15,3`; check the identifier under macOS System Information before
assuming a particular configuration.

This project is an experimental, community-maintained image recipe.

## Why this is a separate image

The T2 keyboard, trackpad, bridge controller, wireless hardware, audio, and
fan control require more than layered desktop packages. The image replaces
Bazzite's kernel with the T2 kernel from the `sharpenedblade/t2linux` COPR and
installs `t2linux-release` and `t2fanrd`.

The recipe follows the current direct bootc approach used by
[kansei-os/t2-atomic](https://github.com/kansei-os/t2-atomic), rather than the
older BlueBuild recipe model. The T2 enablement script, configuration, and
Broadcom radio firmware payload are based on that project's current Bazzite
variant. Adapted materials are covered by the upstream Apache-2.0 license;
see [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md). The radio firmware is
included in the upstream project; verify its redistribution terms before
publishing built images.

The current hardware guidance documents hybrid graphics support for
`MacBookPro15,1` and says the similar `MacBookPro15,3` should work. Graphics
power behavior varies by model; the AMD GPU in `MacBookPro15,1` does not
support runtime power management in the same way as newer variants. The image
masks system suspend because suspend/resume is unreliable on T2 Macs.

## Wallpapers

The image includes two generated, original fan-art wallpapers in KDE's
wallpaper chooser: **Jolteon Storm** and **Meta Knight Moonrise**. Jolteon Storm
is applied the first time Plasma starts for a user. A per-user marker prevents
later logins from replacing a wallpaper the user selects afterward.

The generated fan art depicts characters owned by Nintendo / HAL Laboratory.

## Local build

Requirements: Podman with Dockerfile/Containerfile support and sufficient
storage for a Bazzite image.

```bash
podman build --security-opt label=disable \
  -t localhost/jolteon-os:latest \
  -f Containerfile .
```

Before installing, verify the target Mac is supported by the current T2 Linux
project and keep an external USB keyboard and mouse available. The first
installation/rebase may require them, especially when disk encryption is
enabled.

For a local test rebase from an existing bootc system:

```bash
sudo bootc switch --transport containers-storage localhost/jolteon-os:latest
systemctl reboot
```

This is experimental hardware enablement. A build succeeding does not by
itself prove that every 2018 MacBook Pro model identifier, GPU mode, audio
path, or suspend behavior works.
