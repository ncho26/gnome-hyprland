# Local Agent Instructions

## Desktop And System Configuration Changes

When ncho asks to modify desktop, login, session, window manager, shell, launcher, systemd, display manager, or other machine configuration files, save the current configuration to Git before editing anything.

Required pre-change step:

```sh
/home/ncho/desktop-config-git/scripts/save-desktop-config-snapshot.sh "pre-change snapshot: <short description>"
```

If the commit or push fails, stop before making the configuration change and report the blocker to ncho.

Required post-change step:

```sh
/home/ncho/desktop-config-git/scripts/save-desktop-config-snapshot.sh "update config: <short description>"
```

Report the pushed branch and commit hash after the change.

## Desktop Harness

When ncho asks to inspect, optimize, modernize, validate, or modify the Hyprland desktop/session stack, use the local `desktop-harness` skill if available.

Required verification before the post-change snapshot:

```sh
/home/ncho/.local/bin/desktop-harness-check
```

Trend-discovery roles such as `github-reddit-searcher` are read-only. They may gather current GitHub, Reddit, release-note, and issue data, but an implementation role must evaluate that evidence before any live desktop file is changed.
