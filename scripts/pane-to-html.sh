#!/usr/bin/env bash
# Capture a tmux pane to a standalone HTML file, preserving colors, via
# `tmux capture-pane -e` piped through term2html.
#
#   pane-to-html.sh [pane-id]
#
# Bound to <prefix>+H by default. Designed to run from a tmux keybinding
# (run-shell), where there is NO controlling terminal: so term2html is handed
# the pane's exact dimensions with --cols/--rows (it cannot query /dev/tty) and
# uses its built-in palette via --default-theme.
#
# Captures the VISIBLE pane. To include scrollback, set TMUX_HTML_HISTORY to a
# number of lines, e.g. `TMUX_HTML_HISTORY=500` -> `capture-pane -S -500`.
set -euo pipefail

PANE="${1:-${TMUX_PANE:-}}"
TERM2HTML="${TERM2HTML:-term2html}"

fail() { tmux display-message "pane-to-html: $*"; exit 1; }

[[ -n "$PANE" ]] || fail "no target pane"
command -v "$TERM2HTML" >/dev/null 2>&1 || fail "term2html not found on PATH"

# Pane geometry + identity.
cols=$(tmux display -p -t "$PANE" '#{pane_width}')
rows=$(tmux display -p -t "$PANE" '#{pane_height}')
session=$(tmux display -p -t "$PANE" '#{session_name}')
ts=$(date +%Y%m%d-%H%M%S)

# Line range: visible pane, unless TMUX_HTML_HISTORY requests scrollback.
S=(-E -)   # -E "-" = end of visible pane
if [[ -n "${TMUX_HTML_HISTORY:-}" ]]; then
    S=(-S "-${TMUX_HTML_HISTORY}" -E -)
fi

outdir="${TMUX_HTML_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/tmux-html}"
mkdir -p "$outdir"
safe=${session//[^A-Za-z0-9_.-]/_}
out="$outdir/${safe}-${ts}.html"

# -e: include escape sequences (colors/attributes); -p: stdout; -J: join
# soft-wrapped rows into logical lines. cols/rows match the pane so term2html
# reflows identically to how the pane rendered.
tmux capture-pane -e -J -p -t "$PANE" "${S[@]}" \
    | "$TERM2HTML" --cols "$cols" --rows "$rows" --default-theme > "$out"

bytes=$(wc -c < "$out")
tmux display-message "HTML saved ($bytes B): $(basename "$out")"

# Open in the default browser, fully detached so run-shell returns at once.
( command -v xdg-open >/dev/null 2>&1 && xdg-open "$out" >/dev/null 2>&1 & ) || true
