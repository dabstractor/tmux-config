# Layout 04 — tmux-prefix-highlight (a small, very popular WIDGET plugin),
# DYNAMICALLY themed. It does NOT take over the status line: it substitutes
# a #{prefix_highlight} placeholder into the CURRENT status-left at its load
# time — so the content must be set BEFORE the plugin runs (the natural TPM
# order). The widget's block colors are filled from the resolved tubular
# palette with `set -gF` (bakes the current #{@_tubular_*} values), using the
# CROSS accent per mode — the copy color for the prefix block, the prefix
# color for the copy block — so the block always pops against tubular's
# mode-colored bar behind it.
set -g @prefix_highlight_output_prefix " "
set -g @prefix_highlight_output_suffix " "
set -gF @prefix_highlight_fg "#{@_tubular_bg}"                                  # text on the lit block
set -gF @prefix_highlight_bg "#{@_tubular_copy_color}"                          # block while prefix held (bar is prefix-colored)
set -g @prefix_highlight_show_copy_mode on
set -gF @prefix_highlight_copy_mode_attr "fg=#{@_tubular_bg},bg=#{@_tubular_prefix_color}"
set -g @prefix_highlight_prefix_prompt "PREFIX"    # explicit: tubular sets
set -g @prefix_highlight_copy_prompt   "COPY"        # `prefix None`, so the
set -g @prefix_highlight_empty_prompt  ""            # plugin can't read it back
set -g status-left-length 60
set -g status-left " #S #{prefix_highlight}#W "
set -g status-right " %H:%M "
set -g window-status-format          " #I:#W "
set -g window-status-current-format  " #I:#W "
set -g window-status-separator "  "

# substitute the placeholder now; tubular (running after) only adds color
run-shell ~/.config/tmux/plugins/tmux-prefix-highlight/prefix_highlight.tmux
