#!/usr/bin/env bash
set -euo pipefail

repo_dir="${DESKTOP_CONFIG_REPO:-/home/ncho/desktop-config-git}"
message="${1:-snapshot desktop config}"

copy_file() {
    local src="$1"
    local dst="$repo_dir/$2"

    if [ -e "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        cp -a "$src" "$dst"
    else
        rm -f "$dst"
    fi
}

copy_dir() {
    local src="$1"
    local dst="$repo_dir/$2"

    if [ -d "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        rsync -a --delete "$src/" "$dst/"
    else
        rm -rf "$dst"
    fi
}

if [ ! -d "$repo_dir/.git" ]; then
    printf 'Not a git repository: %s\n' "$repo_dir" >&2
    exit 1
fi

copy_file /home/ncho/AGENTS.md home/ncho/AGENTS.md
copy_file /home/ncho/.bash_profile home/ncho/.bash_profile

copy_dir /home/ncho/.config/hypr home/ncho/.config/hypr
copy_dir /home/ncho/.config/caelestia home/ncho/.config/caelestia
copy_dir /home/ncho/.config/quickshell home/ncho/.config/quickshell
copy_dir /home/ncho/.config/uwsm home/ncho/.config/uwsm
copy_dir /home/ncho/.config/desktop-profiles/hyprland home/ncho/.config/desktop-profiles/hyprland

copy_file /home/ncho/.local/bin/start-hyprland-isolated home/ncho/.local/bin/start-hyprland-isolated
copy_file /home/ncho/.local/bin/desktop-profile home/ncho/.local/bin/desktop-profile
copy_file /home/ncho/.local/bin/wayland-exit-menu home/ncho/.local/bin/wayland-exit-menu
copy_file /home/ncho/.local/bin/hypr-island home/ncho/.local/bin/hypr-island
copy_file /home/ncho/.local/bin/hypr-wallpaper-engine home/ncho/.local/bin/hypr-wallpaper-engine
copy_file /home/ncho/.local/bin/hypr-taskbar home/ncho/.local/bin/hypr-taskbar

copy_file /etc/systemd/system/chvt-tty3.service etc/systemd/system/chvt-tty3.service
copy_dir /etc/systemd/system/getty@tty3.service.d etc/systemd/system/getty@tty3.service.d
copy_file /usr/local/share/wayland-sessions/hyprland.desktop usr/local/share/wayland-sessions/hyprland.desktop

mkdir -p "$repo_dir/metadata"
pacman -Qqe > "$repo_dir/metadata/pacman-explicit.txt"
pacman -Qqm > "$repo_dir/metadata/aur-foreign.txt" 2>/dev/null || true
systemctl list-unit-files > "$repo_dir/metadata/systemd-unit-files.txt" || true
systemctl --user list-unit-files > "$repo_dir/metadata/user-systemd-unit-files.txt" 2>/dev/null || true

git -C "$repo_dir" add -A

if git -C "$repo_dir" diff --cached --quiet; then
    printf 'No snapshot changes to commit.\n'
else
    git -C "$repo_dir" commit -m "$message"
fi

branch="$(git -C "$repo_dir" branch --show-current)"
if [ -z "$branch" ]; then
    printf 'No current git branch in %s\n' "$repo_dir" >&2
    exit 1
fi

git -C "$repo_dir" push -u origin "$branch"
printf 'Pushed %s at %s\n' "$branch" "$(git -C "$repo_dir" rev-parse --short HEAD)"
