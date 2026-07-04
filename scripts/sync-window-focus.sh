#!/bin/sh

# Keep focus-aware apps (e.g. lazygit) in sync with *window* switches.
#
# tmux's `focus-events` option only synthesizes focus-out / focus-in when the
# *active pane* changes (e.g. switching panes within a window). It does NOT
# synthesize them when the *active window* changes, so apps that pause work on
# focus-out (lazygit's background fetch/refresh) keep running while their whole
# window is hidden.
#
# This hook bridges the gap: on every window switch in the current session, send
# focus-in (ESC [ I) to the now-active window's pane, and focus-out (ESC [ O)
# to the active pane of every other window in the session. Apps are
# idempotent; but shells are NOT a no-op — zsh's line editor beeps on the
# unbound \e[O sequence, and that beep writes \a, tripping tmux's bell
# monitor — so shells are skipped below.
#
# Wire it up in tmux.conf:
#   set-hook -g session-window-changed "run-shell -b ~/.config/tmux/scripts/sync-window-focus.sh"
#
# Copy-mode safety: sending \e[O into a pane that's sitting in copy/view mode
# (e.g. a shell you've scrolled up) cancels the mode and loses the scroll
# position. Skip any pane in a mode — a scrolled shell isn't a focus-aware
# app, so withholding the byte is both harmless and exactly what preserves
# its state across window switches.
#
# Shell safety: a plain shell (zsh/bash/...) has no use for focus events, and
# zsh's zle beeps on the unbound \e[O — that beep writes \a and flags the
# window as belled. Skip shells; only focus-aware TUIs (lazygit, etc.) get
# the bytes.

tmux list-windows -F '#{window_active} #{pane_id} #{pane_in_mode} #{pane_current_command}' 2>/dev/null |
while read -r active pane in_mode cmd; do
	[ "$in_mode" = "1" ] && continue
	case "$cmd" in
		zsh|bash|sh|fish|ksh|csh|tcsh) continue ;;
	esac
	if [ "$active" = "1" ]; then
		tmux send-keys -t "$pane" -l "$(printf '\033[I')"
	else
		tmux send-keys -t "$pane" -l "$(printf '\033[O')"
	fi
done
