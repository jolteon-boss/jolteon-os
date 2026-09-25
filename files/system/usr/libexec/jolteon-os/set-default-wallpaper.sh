#!/usr/bin/bash
set -euo pipefail

config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
marker="${config_home}/jolteon-os/default-wallpaper-applied"

# Apply the Jolteon OS default once per user. Don't overwrite later choices.
if [[ -e "${marker}" ]]; then
  exit 0
fi

/usr/bin/plasma-apply-wallpaperimage \
  /usr/share/wallpapers/JolteonOS-Jolteon/contents/images/1586x992.png

mkdir -p "$(dirname "${marker}")"
touch "${marker}"
