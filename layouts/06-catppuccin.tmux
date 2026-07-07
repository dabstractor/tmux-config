# Layout 06 — catppuccin/tmux (a full theme PLUGIN), DYNAMICALLY re-themed.
# The plugin defines its palette as @thm_* options with `set -ogq` (only if
# unset) and bakes them into its formats with -F at load time. So: pre-seed
# every @thm_* slot from the resolved tubular palette (`set -gF` bakes the
# current #{@_tubular_*} values) BEFORE the plugin runs, and catppuccin
# renders its entire layout — pills, separators, modules — in the active
# tubular theme's colors. Cycling themes re-runs this file via the applier,
# which also wipes @thm_*/@_ctp_* so nothing ghosts. The accent mapping is
# coarse (14 catppuccin accents → 4 tubular roles), but that's the point of
# the demo: a foreign theme plugin following the carousel.
set -g @catppuccin_flavour "mocha"        # base flavor (fully overridden below)
set -g @catppuccin_window_status_style "rounded"

# background family
set -gF @thm_bg        "#{@_tubular_bg}"
set -gF @thm_mantle    "#{@_tubular_bg_max}"
set -gF @thm_crust     "#{@_tubular_bg_max}"
set -gF @thm_surface_0 "#{@_tubular_bg_min}"
set -gF @thm_surface_1 "#{@_tubular_neutral_hidden}"
set -gF @thm_surface_2 "#{@_tubular_neutral_hidden}"
set -gF @thm_overlay_0 "#{@_tubular_neutral_visible}"
set -gF @thm_overlay_1 "#{@_tubular_neutral_visible}"
set -gF @thm_overlay_2 "#{@_tubular_neutral_visible}"
# text family
set -gF @thm_fg        "#{@_tubular_fg}"
set -gF @thm_subtext_0 "#{@_tubular_fg}"
set -gF @thm_subtext_1 "#{@_tubular_fg_active}"
# accents → tubular roles: warm pinks/reds→prefix, yellows→zoom,
# greens→copy, blues/teals→active
set -gF @thm_rosewater "#{@_tubular_prefix_color}"
set -gF @thm_flamingo  "#{@_tubular_prefix_color}"
set -gF @thm_pink      "#{@_tubular_prefix_color}"
set -gF @thm_mauve     "#{@_tubular_prefix_color}"
set -gF @thm_red       "#{@_tubular_prefix_color}"
set -gF @thm_maroon    "#{@_tubular_prefix_color}"
set -gF @thm_peach     "#{@_tubular_zoom_color}"
set -gF @thm_yellow    "#{@_tubular_zoom_color}"
set -gF @thm_green     "#{@_tubular_copy_color}"
set -gF @thm_teal      "#{@_tubular_active_color}"
set -gF @thm_sky       "#{@_tubular_active_color}"
set -gF @thm_sapphire  "#{@_tubular_active_color}"
set -gF @thm_blue      "#{@_tubular_active_color}"
set -gF @thm_lavender  "#{@_tubular_active_color}"

run-shell ~/.config/tmux/plugins/catppuccin-tmux/catppuccin.tmux
