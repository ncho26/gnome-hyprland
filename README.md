# GNOME / Hyprland Session Split

This repository stores the Arch Linux `greetd` session chooser setup prepared for `/home/ncho`.

It removes the forced `tty1 -> start-hyprland` autologin path and replaces it with a `tuigreet` login chooser that can start either:

- `Hyprland` through `bin/session-hyprland-isolated`
- `GNOME` through `bin/session-gnome-isolated`

The two wrapper scripts set their own desktop/session environment so GNOME and Hyprland do not inherit each other's compositor-specific variables.

## Apply

```bash
sudo ./scripts/apply-session-chooser.sh
```

After applying, reboot or log out. The first TTY login screen should show `tuigreet`. Hyprland is the default command; press `F3` to pick either `Hyprland` or `GNOME`.

## Verify

```bash
./scripts/verify-session-split.sh
```

## Roll Back

```bash
sudo ./scripts/rollback-session-chooser.sh
```

The apply script backs up the previous greetd config and session files under:

```text
/etc/greetd/backup-session-split-YYYYMMDD-HHMMSS
```

## Files

- `scripts/apply-session-chooser.sh`: installs GNOME/tuigreet dependencies, rewrites `/etc/greetd/config.toml`, and creates isolated session entries.
- `scripts/verify-session-split.sh`: checks greetd config, chooser entries, installed session binaries, and current session environment.
- `scripts/rollback-session-chooser.sh`: restores the newest greetd backup created by the apply script.
- `bin/session-hyprland-isolated`: starts the current Hyprland/Caelestia session with Hyprland-owned environment.
- `bin/session-gnome-isolated`: starts GNOME Wayland with Hyprland variables cleared.
- `xdg-desktop-portal/*.conf`: per-desktop portal preference files.
