#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

rsync -a "$repo_dir/home/ncho/" /home/ncho/
sudo rsync -a "$repo_dir/etc/systemd/system/" /etc/systemd/system/
sudo rsync -a "$repo_dir/usr/local/share/wayland-sessions/" /usr/local/share/wayland-sessions/

sudo systemctl daemon-reload
sudo systemctl set-default multi-user.target
sudo systemctl disable sddm.service || true
sudo systemctl enable getty@tty3.service chvt-tty3.service

printf 'Applied tty3 Hyprland desktop config.\n'
