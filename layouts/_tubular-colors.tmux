# Tubular in COLORS-ONLY mode — the realistic compatibility case.
# Sets the mode palette + all *-style options (so the bar still lights up
# pink/green/blue/dark per mode) but leaves status-left / status-right /
# window-status-format COMPLETELY to whatever layout follows.
#
# This is "bucket A" from the tubular README: "leave my status line alone."
# Each layout file sources this, runs tubular, then applies the foreign
# statusline LAST (matching how TPM loads plugins after your config).

set -g @tubular_prefix_key "C-Space"

# Palette (your custom colors) so the mode coloring is actually visible.
set -g @tubular_bg "#1f1f28"
set -g @tubular_bg_max "#181822"
set -g @tubular_bg_min "#24242e"
set -g @tubular_fg "#c7c7aa"
set -g @tubular_fg_active "#cde4ed"
set -g @tubular_fg_focus "#dddddd"
set -g @tubular_neutral_visible "#787878"
set -g @tubular_neutral_hidden "#54546d"
set -g @tubular_prefix_color "#d27e99"
set -g @tubular_copy_color   "#98bb6c"
set -g @tubular_zoom_color   "#e6c384"
set -g @tubular_active_color "#7aa89f"

# THE compatibility switch: tubular sets ONLY colors/styles, never content.
set -g @tubular_manage_content off

set -g @tubular_pane_bg "active"
set -g @tubular_normal_border_lines "heavy"
