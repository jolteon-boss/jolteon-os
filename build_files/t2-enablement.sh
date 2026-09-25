#!/bin/bash
set -ouex pipefail

# T2 Macs need a patched kernel and the associated userspace support. This is
# the same enablement source used by the maintained T2-Atomic Bazzite variant.
dnf5 -y install dnf5-plugins python3-jsonschema
dnf5 -y copr enable sharpenedblade/t2linux

dnf5 -y remove \
  kmod-framework-laptop kmod-openrazer kmod-xone \
  kernel-modules-akmods kmod-v4l2loopback kernel-headers

grep -q 'layout=ostree' /usr/lib/kernel/install.conf || \
  echo 'layout=ostree' >> /usr/lib/kernel/install.conf

rpm-ostree cliwrap install-to-root /
rpm-ostree override replace --experimental --freeze \
  --from repo=copr:copr.fedorainfracloud.org:sharpenedblade:t2linux \
  kernel-uki-virt kernel kernel-core kernel-modules kernel-modules-core \
  kernel-modules-extra kernel-devel kernel-devel-matched \
  kernel-tools kernel-tools-libs

dnf5 -y install t2fanrd t2linux-release
rm -f /usr/share/pipewire/pipewire.conf.d/raop.conf

# Remove firmware for hardware absent from Macs; this avoids shipping unrelated
# firmware while retaining the Intel, AMD, and Broadcom firmware they need.
dnf5 -y remove tiwilink-firmware nxpwireless-firmware nvidia-gpu-firmware \
  mt7xxx-firmware iwlegacy-firmware iwlwifi-dvm-firmware \
  iwlwifi-mvm-firmware qcom-wwan-firmware
dnf5 -y copr disable sharpenedblade/t2linux

dnf5 -y install lm_sensors sg3_utils wodim xorriso radeontop \
  libinput libinput-utils

# iwd is generally more reliable than wpa_supplicant on T2 Macs.
dnf5 -y swap wpa_supplicant iwd
mkdir -p /etc/NetworkManager/conf.d
cat >> /etc/NetworkManager/conf.d/iwd.conf <<'EOF'
[device]
wifi.backend=iwd
EOF

mkdir -p /lib/firmware/brcm
tar -xf /ctx/common/radio.tar -C /lib/firmware/brcm

systemctl mask suspend.target
systemctl enable t2fanrd.service
dnf5 -y install fedora-release-ostree-desktop
dnf clean all
