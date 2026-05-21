#!/usr/bin/env bash
set -euo pipefail

target_user="${SUDO_USER:-ncho}"
target_home="$(getent passwd "$target_user" | cut -d: -f6)"
if [[ -z "$target_home" || ! -d "$target_home" ]]; then
    echo "Cannot resolve home for user: $target_user" >&2
    exit 1
fi

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run with root privileges: sudo $0" >&2
    exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "${script_dir}/.." && pwd)"

timestamp="$(date +%Y%m%d-%H%M%S)"
backup_dir="/etc/greetd/backup-session-split-${timestamp}"
install -d -m 755 "$backup_dir"

if [[ -f /etc/greetd/config.toml ]]; then
    cp -a /etc/greetd/config.toml "$backup_dir/config.toml"
fi
if [[ -d /etc/greetd/sessions ]]; then
    cp -a /etc/greetd/sessions "$backup_dir/sessions"
fi

pacman -S --needed greetd greetd-tuigreet gnome-session gnome-shell mutter \
    gnome-control-center nautilus gnome-terminal gnome-keyring \
    xdg-desktop-portal xdg-desktop-portal-gnome xdg-desktop-portal-gtk \
    xdg-desktop-portal-hyprland

if getent passwd greeter >/dev/null 2>&1; then
    install -d -m 755 -o greeter -g greeter /var/cache/tuigreet
else
    install -d -m 755 /var/cache/tuigreet
fi

install -d -m 755 -o "$target_user" -g "$target_user" "$target_home/.local/bin"
install -d -m 755 -o "$target_user" -g "$target_user" "$target_home/.config/xdg-desktop-portal"

if [[ -f "${repo_dir}/bin/session-hyprland-isolated" ]]; then
    install -m 755 -o "$target_user" -g "$target_user" \
        "${repo_dir}/bin/session-hyprland-isolated" \
        "$target_home/.local/bin/session-hyprland-isolated"
fi
if [[ -f "${repo_dir}/bin/session-gnome-isolated" ]]; then
    install -m 755 -o "$target_user" -g "$target_user" \
        "${repo_dir}/bin/session-gnome-isolated" \
        "$target_home/.local/bin/session-gnome-isolated"
fi
if [[ -f "${repo_dir}/xdg-desktop-portal/hyprland-portals.conf" ]]; then
    install -m 644 -o "$target_user" -g "$target_user" \
        "${repo_dir}/xdg-desktop-portal/hyprland-portals.conf" \
        "$target_home/.config/xdg-desktop-portal/hyprland-portals.conf"
fi
if [[ -f "${repo_dir}/xdg-desktop-portal/gnome-portals.conf" ]]; then
    install -m 644 -o "$target_user" -g "$target_user" \
        "${repo_dir}/xdg-desktop-portal/gnome-portals.conf" \
        "$target_home/.config/xdg-desktop-portal/gnome-portals.conf"
fi

install -d -m 755 /etc/greetd/sessions
find /etc/greetd/sessions -maxdepth 1 -type f -name '*.desktop' -exec mv -t "$backup_dir" {} +

cat > /etc/greetd/config.toml <<EOF
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --remember-user-session --asterisks --sessions /etc/greetd/sessions --cmd ${target_home}/.local/bin/session-hyprland-isolated"
user = "greeter"
EOF

cat > /etc/greetd/sessions/hyprland-isolated.desktop <<EOF
[Desktop Entry]
Name=Hyprland
Comment=Isolated Hyprland/Caelestia session
Exec=${target_home}/.local/bin/session-hyprland-isolated
TryExec=/usr/bin/start-hyprland
Type=Application
Keywords=tiling;wayland;compositor;
EOF

cat > /etc/greetd/sessions/gnome-isolated.desktop <<EOF
[Desktop Entry]
Name=GNOME
Comment=Isolated GNOME Wayland session
Exec=${target_home}/.local/bin/session-gnome-isolated
TryExec=/usr/bin/gnome-session
Type=Application
X-GDM-SessionRegisters=true
EOF

if command -v desktop-file-validate >/dev/null 2>&1; then
    desktop-file-validate /etc/greetd/sessions/hyprland-isolated.desktop
    desktop-file-validate /etc/greetd/sessions/gnome-isolated.desktop
fi

chown "$target_user:$target_user" \
    "$target_home/.local/bin/session-hyprland-isolated" \
    "$target_home/.local/bin/session-gnome-isolated" \
    "$target_home/.config/xdg-desktop-portal/hyprland-portals.conf" \
    "$target_home/.config/xdg-desktop-portal/gnome-portals.conf"
chmod 755 \
    "$target_home/.local/bin/session-hyprland-isolated" \
    "$target_home/.local/bin/session-gnome-isolated"

# Keep Hyprland-only helpers out of GNOME's generic graphical-session target.
if [[ -d "/run/user/$(id -u "$target_user")" ]]; then
    runuser -u "$target_user" -- env XDG_RUNTIME_DIR="/run/user/$(id -u "$target_user")" \
        systemctl --user disable cliphist.service mpris-proxy.service xdg-desktop-portal-rewrite-launchers.service >/dev/null 2>&1 || true
fi

systemctl enable greetd.service
systemctl disable sddm.service gdm.service lightdm.service >/dev/null 2>&1 || true

echo "Configured greetd chooser with isolated Hyprland and GNOME sessions."
echo "Backup: $backup_dir"
echo "Reboot or log out to reach the chooser."
