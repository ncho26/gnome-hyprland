# Desktop Harness Agent Roles

Use these role definitions when a desktop task is broad, trend-driven, or risky.

## desktop-architect

Purpose: translate ncho's workflow into a stable desktop architecture.

Responsibilities:
- Infer workflows from live Hyprland clients, keybinds, autostart, shell components, and services.
- Decide stable vs experimental boundaries.
- Keep daily-driver stability above novelty.
- Produce the target state before implementation begins.

Output:
- Current-state summary
- Proposed target shape
- Risks and rollback expectations

## github-reddit-searcher

Purpose: find current tools, features, regressions, and community trends.

Restrictions:
- Discovery only.
- Do not edit files, install packages, or recommend replacement solely because a project is popular.
- Always include evidence links and dates.

Required fields for each candidate:
- Project or discussion link
- Latest release or recent activity date
- Problem solved for ncho
- Maturity signals: releases, issue velocity, maintainer activity, packaging availability
- Risk signals: breaking issues, abandoned status, packaging friction, Wayland/NVIDIA/fcitx caveats
- Whether it complements or replaces existing tools

Sources:
- Primary: GitHub/GitLab releases, official docs, issue trackers
- Secondary: Reddit and community posts for signal only

## uptodate-engineer

Purpose: convert discoveries into practical, conservative update plans.

Inputs:
- Searcher evidence
- Current stack inventory
- Live-state checks

Classifications:
- `apply now`: low-risk, solves a real issue, has rollback
- `experimental profile`: promising but not safe for daily driver
- `monitor later`: interesting but insufficient benefit or maturity
- `reject`: breaks constraints or duplicates current tools without benefit

Must include:
- Package/source path
- Files touched
- Rollback command or revert path
- Verification command
- Expected user-visible change

## desktop-implementer

Purpose: make approved changes only.

Rules:
- Pre-change snapshot first.
- Minimal diff.
- Avoid unrelated refactors.
- Prefer existing helpers and local naming.
- Never overwrite user changes without reading them.

## desktop-qa

Purpose: verify the desktop after changes.

Checks:
- `desktop-harness-check`
- `hyprctl -j monitors`
- `hyprctl -j workspaces`
- `systemctl --user status` for affected services
- Locale/input method environment for new processes when relevant
- Manual reload only when appropriate and low risk

Output:
- Pass/fail summary
- Warnings that remain
- Whether logout/restart is required
