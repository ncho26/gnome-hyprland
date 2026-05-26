---
name: desktop-harness
description: Use when ncho asks to inspect, optimize, modernize, validate, or modify the Hyprland desktop/session stack, including window manager, shell, launcher, input method, locale, autostart, systemd user services, workspace policy, and trend-driven updates from GitHub or Reddit. Enforces pre/post desktop snapshots, role-based agent review, and desktop-harness-check verification.
metadata:
  short-description: Safely evolve ncho's Hyprland desktop
---

# Desktop Harness

Use this skill for ncho's live Hyprland desktop and adjacent machine configuration.

## Hard Guardrails

- Before any live desktop, session, launcher, shell, input, locale, systemd, or window-manager edit, run:

```sh
/home/ncho/desktop-config-git/scripts/save-desktop-config-snapshot.sh "pre-change snapshot: <short description>"
```

- If the pre-change commit or push fails, stop before editing.
- After edits and validation, run:

```sh
/home/ncho/desktop-config-git/scripts/save-desktop-config-snapshot.sh "update config: <short description>"
```

- Report the pushed branch and commit hash.
- Do not let trend-discovery output directly modify the desktop. Discovery produces evidence; implementation happens only after evaluation.

## Agent Pipeline

For nontrivial work, route the task through these roles:

1. `desktop-architect`: infer ncho's workflow, decide the target shape, and keep the daily-driver path stable.
2. `github-reddit-searcher`: discovery-only role for current GitHub, Reddit, release-note, and issue-tracker signals. It must cite links, dates, activity, and risk.
3. `uptodate-engineer`: turns discoveries into practical update plans for the current stack. It classifies items as `apply now`, `experimental profile`, `monitor later`, or `reject`.
4. `desktop-implementer`: applies only approved minimal changes after the pre-change snapshot.
5. `desktop-qa`: runs deterministic checks and reports residual warnings before the post-change snapshot.

Read `references/agents.md` when defining, changing, or using the agent team.

## Current Stack

Assume the primary stack is:

- Hyprland on Wayland, single DP-1 high-refresh monitor
- Caelestia shell and QuickShell components
- Vicinae launcher
- kitty, fish, Nautilus/Thunar/Yazi mix
- fcitx5 with Korean input
- swaync notifications
- awww wallpaper daemon
- `hypr-island` scratch/special workspace helper
- Hermes user services for assistant-facing workflows

Verify live state instead of trusting static files.

## Workflow

1. Inventory static config and live state:

```sh
hyprctl -j monitors
hyprctl -j workspaces
hyprctl -j clients
systemctl --user list-units --type=service --state=running --no-pager
```

2. For up-to-date recommendations, browse/search before claiming "latest" or "current". Prefer primary sources: project repos, releases, docs, and issue trackers. Reddit is useful for trend signals, not as final authority.
3. Evaluate against ncho's actual daily-driver constraints: Korean input, high-refresh monitor, research/writing workflow, scratch workspace behavior, and stable rollback.
4. Edit narrowly. Prefer existing patterns and scripts.
5. Run:

```sh
/home/ncho/.local/bin/desktop-harness-check
```

6. Explain warnings distinctly from failures.

## Design Bias

- Preserve Caelestia/Vicinae/fcitx5 unless there is clear evidence to replace them.
- Prefer systemd user services for long-running daemons, but avoid service churn unless it solves a real reliability problem.
- Keep experimental tools isolated from the stable Hyprland session.
- Treat monitor-mode mismatch, missing binaries, broken input-method environment, and stale autostart rules as harness findings.
