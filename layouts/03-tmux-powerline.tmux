# Layout 3 — erikw/tmux-powerline (the real plugin you named).
# Cloned to plugins/tmux-powerline/. It runs out-of-the-box with its default
# theme. Internals: main.tmux sets status-left/status-right to
#   #(~/.../powerline.sh left|right)
# i.e. shell-executed per render, AND it overrides status-style itself.
# This is the HEAVIEST integration: a foreign plugin that re-asserts
# status-style + fills every segment with explicit #[bg=colourNNN]. Tubular's
# mode coloring is effectively overwritten wherever tmux-powerline paints
# (which is everywhere). Reports the "full takeover" compatibility case.
source-file ~/.config/tmux/layouts/_tubular-colors.tmux
run-shell  ~/.config/tmux/plugins/tubular-tmux/tubular.tmux

# Use the default theme (no ~/.tmux-powerline config needed).
# main.tmux reads TMUX_POWERLINE_DIR_HOME from BASH_SOURCE, so run it directly.
run-shell ~/.config/tmux/plugins/tmux-powerline/main.tmux
