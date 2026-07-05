# Layout 0 — YOUR config (restore point).
# Sources your real tubular.conf (content + palette) and runs the plugin, so
# cycling back here returns your status line to exactly how it was.
source-file ~/.config/tmux/tubular.conf
run-shell ~/.config/tmux/plugins/tubular-tmux/tubular.tmux
