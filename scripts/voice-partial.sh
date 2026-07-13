#!/bin/sh
# tmux status-right segment for voice-typing live partials.
#
# Wraps voice-typing/voice_typing/status.sh, which prints "" when the daemon is
# idle and "🎤 <partial>" (<=60 chars) while listening. We append a tubular-style
# double-space separator ONLY when something is showing, so the right-side of
# the status line is visually identical to before when no one is talking.
#
# Called every status-interval (1s) via tmux's #(...) substitution. POSIX sh
# only; no `set -e` so a dead daemon yields "" rather than an error string.
out="$(/home/dustin/projects/voice-typing/voice_typing/status.sh)"
[ -n "$out" ] && printf '%s  ' "$out"
