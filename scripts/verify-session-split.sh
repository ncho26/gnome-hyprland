#!/usr/bin/env bash
set -euo pipefail

echo "== greetd =="
systemctl status greetd --no-pager | sed -n '1,40p'

echo
echo "== greetd config =="
sed -n '1,120p' /etc/greetd/config.toml

echo
echo "== chooser sessions =="
find /etc/greetd/sessions -maxdepth 1 -type f -name '*.desktop' -print -exec sed -n '1,80p' {} \;

echo
echo "== installed session binaries =="
command -v tuigreet || true
command -v gnome-session || true
command -v gnome-shell || true
command -v start-hyprland || true

echo
echo "== current session env =="
systemctl --user show-environment | sort | grep -E 'XDG_CURRENT_DESKTOP|XDG_SESSION_DESKTOP|XDG_SESSION_TYPE|DESKTOP_SESSION|GNOME|HYPR|QT_|GTK_|XMODIFIERS|SDL_|MOZ_ENABLE_WAYLAND|PATH' || true
