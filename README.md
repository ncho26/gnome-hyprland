# ncho desktop config

Current Arch desktop snapshot after reverting to a tty3-first Hyprland setup.

## Current boot flow

- Default systemd target: `multi-user.target`
- Display manager: `sddm` disabled
- Login path: `getty@tty3` autologin as `ncho`
- Desktop path: `~/.bash_profile` starts `~/.local/bin/start-hyprland-isolated` on tty3
- Shell: Hyprland + Caelestia quickshell
- Launcher: `vicinae server`, triggered by `vicinae toggle`

## Layout

- `home/ncho/.config/hypr`: Hyprland, hyprlock, monitor, workspace config
- `home/ncho/.config/caelestia`: Caelestia shell config
- `home/ncho/.config/quickshell`: local Quickshell configs
- `home/ncho/.config/desktop-profiles/hyprland`: GTK profile files
- `home/ncho/.local/bin`: local scripts used by the session
- `etc/systemd/system`: tty3 autologin and VT switch units
- `usr/local/share/wayland-sessions`: local Hyprland desktop entry
- `metadata`: package and service state snapshots

## Restore sketch

Review files before applying them on another machine.

```sh
rsync -a home/ncho/ /home/ncho/
sudo rsync -a etc/systemd/system/ /etc/systemd/system/
sudo rsync -a usr/local/share/wayland-sessions/ /usr/local/share/wayland-sessions/
sudo systemctl daemon-reload
sudo systemctl set-default multi-user.target
sudo systemctl disable sddm.service
sudo systemctl enable getty@tty3.service chvt-tty3.service
```

This repo intentionally excludes browser profiles, SSH keys, tokens, cache directories, and GNOME custom profile files.
