# Layout 4 — tmux-prefix-highlight (a small, very popular WIDGET plugin).
# Cloned to plugins/tmux-prefix-highlight/. Unlike the powerline plugins it
# does NOT take over your status line: it gives you a #{prefix_highlight}
# placeholder you embed wherever you want. Here it sits in a plain
# tubular-colored status-left. Compatibility is HIGH — tubular's mode color
# fills everything except the widget's own bg block.
#
# LOAD ORDER MATTERS: the plugin substitutes #{prefix_highlight} into the
# CURRENT status-left at its load time, so the content must be set BEFORE the
# plugin runs (that's the natural TPM order: your tmux.conf sets status-left,
# TPM loads the plugin last). Tubular runs last and only sets *-style colors.
source-file ~/.config/tmux/layouts/_tubular-colors.tmux

# Style the widget: bright block while prefix is held, dim otherwise.
set -g @prefix_highlight_output_prefix " "
set -g @prefix_highlight_output_suffix " "
set -g @prefix_highlight_fg "colour234"        # text on the lit block
set -g @prefix_highlight_bg "colour148"        # the lit block color
set -g @prefix_highlight_show_copy_mode on
set -g @prefix_highlight_copy_mode_attr "fg=colour234,bg=colour39"
set -g @prefix_highlight_prefix_prompt "PREFIX"    # explicit: tubular sets
set -g @prefix_highlight_copy_prompt   "COPY"        # `prefix None`, so the
set -g @prefix_highlight_empty_prompt  ""            # plugin can't read it back
set -g status-left-length 60
set -g status-left " #S #{prefix_highlight}#W "
set -g status-right " %H:%M "
set -g window-status-format          " #I:#W "
set -g window-status-current-format  " #I:#W "
set -g window-status-separator "  "

# substitute the placeholder, then let tubular wrap it in mode colors
run-shell ~/.config/tmux/plugins/tmux-prefix-highlight/prefix_highlight.tmux
run-shell ~/.config/tmux/plugins/tubular-tmux/tubular.tmux
