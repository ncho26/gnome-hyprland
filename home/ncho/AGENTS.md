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
