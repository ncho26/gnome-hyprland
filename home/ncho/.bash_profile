#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Hermes Agent - ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

# Start the Hyprland desktop from the tty3 login session.
current_tty="$(tty 2>/dev/null || true)"
if [ -z "$WAYLAND_DISPLAY" ] \
    && [ -z "$DISPLAY" ] \
    && [ -z "${NCHO_SESSION_MENU_BYPASS:-}" ] \
    && { [ "${XDG_VTNR:-}" = "3" ] || [ "$current_tty" = "/dev/tty3" ]; }; then
    if command -v Hyprland >/dev/null 2>&1; then
        exec "$HOME/.local/bin/start-hyprland-isolated"
    fi
fi
