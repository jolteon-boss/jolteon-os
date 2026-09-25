# Jolteon OS

Jolteon OS is an experimental Bazzite image recipe with the T2 Linux kernel and
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

### Jolteon Storm

![Jolteon Storm wallpaper](wallpapers/JolteonOS-Jolteon/contents/images/1586x992.png)

### Meta Knight Moonrise

![Meta Knight Moonrise wallpaper](wallpapers/JolteonOS-MetaKnight/contents/images/1586x992.png)

## Installation from macOS

### Current availability

This repository currently contains the image recipe, but it does not yet have
a published Jolteon OS image or an installer ISO. A Mac cannot install this
recipe directly from the GitHub repository. The steps below describe the
planned installation flow. Until a Jolteon OS image is published, use the
local-build path below to create the image on the Mac after installing Bazzite.

The first installation stage uses a standard Bazzite KDE ISO. Its live
installer does not include the T2 kernel, so the built-in keyboard, trackpad,
Wi-Fi, and Bluetooth may not work yet. Have a wired USB keyboard and mouse, a
USB-C adapter or hub, and preferably wired Ethernet available. Keep the
external keyboard connected through the first Jolteon OS boot, especially if
you enable disk encryption. This matches the current [T2 Atomic installation
guidance](https://github.com/kansei-os/t2-atomic#t2-atomic-bootc).

### 1. Prepare and back up macOS

1. Back up macOS and personal files to a separate disk or Time Machine. Keep
   the FileVault recovery key and macOS account credentials available.
2. In **Apple menu → About This Mac → System Report**, confirm the model
   identifier. This recipe targets 2018 15-inch T2 MacBook Pros; common
   identifiers include `MacBookPro15,1` and `MacBookPro15,3`.
3. Decide whether Linux will go on a dedicated external SSD or share the
   internal drive. A dedicated external SSD is the preferred first trial
   because it avoids resizing the macOS APFS container. If installing beside
   macOS on the internal drive, first create a separate Linux partition in
   macOS Disk Utility, then follow the T2 Linux [pre-install
   guide](https://wiki.t2linux.org/guides/preinstall/). Do not choose an
   installer option that erases the whole internal disk if macOS must be
   retained.

### 2. Make a Bazzite installer USB

1. From macOS, download the **KDE Desktop** Bazzite ISO from the [Bazzite
   download page](https://bazzite.gg/). Choose a desktop image, not the
   Steam Gaming Mode / Deck image, and avoid an NVIDIA-specific image. The
   2018 15-inch model has Intel and AMD graphics.
2. Use [Fedora Media Writer](https://fedoraproject.org/workstation/download/)
   or another Bazzite-supported imaging tool to write the ISO to a USB drive
   (16 GB or larger). Writing the ISO erases that USB drive.

### 3. Allow the Mac to boot Linux media

1. Shut down the Mac. Turn it on while holding **Command-R** to enter macOS
   Recovery.
2. In the menu bar, open **Utilities → Startup Security Utility** and
   authenticate as a macOS administrator.
3. Set **Secure Boot** to **No Security** and **Allowed Boot Media** to
   **Allow booting from external or removable media**. These settings are
   required by the current T2 Linux boot guidance; they reduce the Mac's
   startup security. See Apple's [Startup Security Utility guide for T2
   Macs](https://support.apple.com/en-ca/102522) and the T2 Linux
   [pre-install guide](https://wiki.t2linux.org/guides/preinstall/).

### 4. Boot and install Bazzite

1. Connect the installer USB, external keyboard and mouse, and Ethernet if
   available.
2. Restart while holding **Option (⌥)** to open Startup Manager. Select the
   orange **EFI Boot** entry for the installer USB.
3. Start the Bazzite installer. Select the intended target disk carefully.
   For the first trial, install to a dedicated external SSD. For an internal
   dual-boot setup, use manual partitioning based on the T2 Linux guide and
   select only the Linux partition created earlier. Bazzite documents that
   manual partitioning may require its [legacy
   ISO](https://docs.bazzite.gg/General/Installation_Guide/install-guide/);
   do not assume automatic partitioning preserves macOS.
4. Complete the installation and create the Linux user. If you enable disk
   encryption, use the external keyboard to enter the unlock passphrase on
   subsequent boots until the T2 image is installed.
5. Restart into Bazzite, keeping the external input devices connected.

The Bazzite [installation guide](https://docs.bazzite.gg/General/Installation_Guide/install-guide/)
covers preparing and installing its standard ISO. The T2 Linux guide adds
Mac-specific boot and partitioning cautions.

### 5. Switch the Bazzite system to Jolteon OS

After logging in to Bazzite, open Konsole. When a Jolteon OS image is
published, the intended switch will look like this:

```bash
sudo bootc switch ghcr.io/jolteon-boss/jolteon-os:latest
systemctl reboot
```

The image switch downloads the T2-enabled system and stages it as the next
boot deployment. Keep the external keyboard attached during the switch and
reboot. On the first boot, check the built-in keyboard, trackpad, Wi-Fi,
Bluetooth, speakers, microphone, and fan behavior before removing the
external devices.

At present, the GitHub repository has no image build/release workflow, so the
registry command above is not usable yet. To build locally on the installed
Bazzite system instead, clone the repository and build into rootful Podman's
image store:

```bash
git clone https://github.com/jolteon-boss/jolteon-os.git
cd jolteon-os
sudo podman build --security-opt label=disable \
  -t localhost/jolteon-os:latest \
  -f Containerfile .
sudo bootc switch --transport containers-storage localhost/jolteon-os:latest
systemctl reboot
```

### After installation and recovery

- The current recipe masks system suspend and ignores lid-close sleep events.
  Plan to shut down or leave the Mac awake when carrying it; closing the lid
  will not put it to sleep.
- To choose macOS or Linux at startup, restart while holding **Option (⌥)**
  and select the desired startup disk.
- After confirming Linux boots reliably, you may revisit the external-media
  policy in Startup Security Utility. Do not re-enable Secure Boot unless you
  have confirmed that the selected boot chain supports it.
- If Linux does not boot, hold **Option (⌥)** and select the macOS startup
  disk. **Command-R** opens macOS Recovery for startup-security changes or
  macOS recovery tasks.
- Do not erase macOS or remove the external keyboard until the new image has
  booted successfully and you have verified access to your files.

This is experimental hardware enablement. A successful image build does not
prove every model identifier, graphics mode, audio path, or power state works.
