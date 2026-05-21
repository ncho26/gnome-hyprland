#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
    echo "Run with root privileges: sudo $0 [backup-dir]" >&2
    exit 1
fi

backup_dir="${1:-}"
if [[ -z "$backup_dir" ]]; then
    backup_dir="$(find /etc/greetd -maxdepth 1 -type d -name 'backup-session-split-*' | sort | tail -n 1)"
fi

if [[ -z "$backup_dir" || ! -d "$backup_dir" ]]; then
    echo "No greetd session-split backup found." >&2
    exit 1
fi

if [[ -f "$backup_dir/config.toml" ]]; then
    cp -a "$backup_dir/config.toml" /etc/greetd/config.toml
else
    echo "Backup has no config.toml: $backup_dir" >&2
    exit 1
fi

if [[ -d "$backup_dir/sessions" ]]; then
    rm -rf /etc/greetd/sessions
    cp -a "$backup_dir/sessions" /etc/greetd/sessions
fi

echo "Restored greetd config from: $backup_dir"
echo "Reboot or restart greetd from a safe TTY to apply it."
