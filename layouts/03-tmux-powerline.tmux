# Layout 03 — erikw/tmux-powerline (a real foreign statusline plugin),
# DYNAMICALLY themed. tubular-powerline-theme-gen.sh converts the resolved
# tubular palette (@_tubular_*, populated by the applier before this file is
# sourced) into a generated tmux-powerline theme (~/.config/tmux-powerline/,
# marker-guarded). Powerline re-sources its theme on every render, so cycling
# tubular themes repaints powerline's segments live. main.tmux reads
# TMUX_POWERLINE_DIR_HOME from BASH_SOURCE, so run it directly.
run-shell ~/.config/tmux/scripts/tubular-powerline-theme-gen.sh
run-shell ~/.config/tmux/plugins/tmux-powerline/main.tmux
