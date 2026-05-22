# Repository Agent Instructions

This repository stores ncho's desktop and system configuration snapshot.

Before changing any live desktop, login, session, window manager, shell, launcher, systemd, display manager, or related configuration, first run:

```sh
/home/ncho/desktop-config-git/scripts/save-desktop-config-snapshot.sh "pre-change snapshot: <short description>"
```

If that commit or push fails, stop before editing the live configuration and report the blocker.

After changing configuration, run:

```sh
/home/ncho/desktop-config-git/scripts/save-desktop-config-snapshot.sh "update config: <short description>"
```

Report the pushed branch and commit hash.
