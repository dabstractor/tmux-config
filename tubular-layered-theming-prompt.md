# Task: make tubular.tmux a "theme provides colors, user provides text" status line

You are working on **tubular-tmux**, a tmux status-line theming plugin, located at
`~/.config/tmux/plugins/tubular-tmux/`. The single source file is `tubular.tmux`
(a bash script that sets tmux options at load time). There are no render-time
scripts — everything in the draw path is a tmux **format string**.

Read `tubular.tmux` in full before starting. This document gives you the design,
the constraints, and the exact tmux mechanics you need — but the code is truth.

---

## The goal

Today the plugin **overwrites** the user's status-line content. On load it sets
`status-left`, `status-right`, `window-status-separator`, `window-status-format`,
and `window-status-current-format` from `@tubular_*` options (see `tubular.tmux`
lines ~125, ~154–167). A user who has their own `status-left` gets it clobbered.

The desired model: **tubular owns all the COLOR, the user owns the TEXT.**

- Tubular keeps setting every `*-style` option (`status-style`, `window-status-style`,
  etc.) to the live mode colors. This is the base layer that makes the whole bar
  light up pink (prefix) / white-ish (copy) / blue (zoom) / dark (normal).
- Tubular stops force-owning the *content* options. The user's native
  `status-left` / `status-right` / windows render, and — because they inherit the
  `*-style` base — they automatically pick up the mode colors.
- For users who DO want custom-colored segments, tubular exposes a small, clean,
  documented set of **color reference variables** so their custom bits can snap
  back to the theme and stay seamless across mode changes.

North star (the plugin author's words): *"people should be able to leave their
configs as-is, add the package, and get the extra color effects."*

---

## Honest scope / difficulty

- **The background layering is easy and already proven.** With only `status-style`
  set to a mode color and a plain native `status-left`, the entire bar renders in
  that color with the native text showing through. Verified. This part is nearly
  free — it falls out of how tmux styles work.
- **The color-reference API for custom user segments is the real work.** It is not
  hard, but it is fiddly and full of tmux-specific traps (below). Budget your care
  here: naming, the `#{E:...}` expansion requirement, the `#[default]` reset
  behavior, per-segment style bases, and color bleed. This is where the feature
  lives or dies.

---

## tmux mechanics you MUST understand (non-obvious, learned the hard way)

1. **`status-style` is the base layer.** Every status segment inherits its
   segment-specific `*-style` option, which defaults to `status-style`. The
   relevant per-segment style options are:
   `status-left-style`, `status-right-style`, `window-status-style`,
   `window-status-current-style`, `window-status-activity-style`,
   `window-status-last-style`, `window-status-bell-style`.
   Set these to the mode colors and any content that doesn't declare its own
   `#[fg=/bg=]` gets the mode colors automatically.

2. **`#[default]` resets to the segment's `*-style`** — i.e. back to the mode
   colors. This is the cleanest "return to theme" primitive for users. A user who
   writes `#[fg=red]ALERT#[default] rest` gets red ALERT, then `rest` snaps back to
   the current mode colors, dynamically, with no variable reference at all.
   Make sure every segment's `*-style` is set to the mode colors so `#[default]`
   does the right thing everywhere.

3. **The exposed color variables are FORMAT STRINGS, not literal colors.** The
   dynamic ones (e.g. `@tubular_mode_bg`) hold a conditional like
   `#{?client_prefix,#fffef7,#{?...}}`. To USE one you must force re-expansion:
   - `#{E:@tubular_mode_bg}` → evaluates to the actual color (CORRECT)
   - `#{@tubular_mode_bg}`  → yields the raw conditional text (WRONG / garbage)
   Static palette colors (e.g. `@tubular_prefix_color`) are literal `#rrggbb` and
   do NOT need `E:`. This distinction MUST be crystal clear in the docs — it is the
   #1 thing users will get wrong.

4. **Legacy `status-bg` / `status-fg` silently override `status-style`.** If either
   is set to a non-`default` value, it pins the corresponding half of the bar and
   defeats the mode coloring. The plugin already unsets them (`set-option -gu
   status-bg` / `status-fg`). Keep that. Do not reintroduce them.

5. **`pane-border-lines` cannot be a format** — the line style (single/heavy/
   double) is static, chosen at load. Only border colors/bold change per mode.

6. **No shell in the render path — ever.** Earlier versions shelled out for
   centering and mode detection; it caused visible async jank against tmux's
   synchronous format expansion. Everything drawn must be a pure tmux format.
   `run-shell`/`#(...)` in a status format is banned.

7. **Mode detection from any format context** uses a window-list scan so a tab
   being rendered can read the *active* window's state:
   - copy mode:  `#{==:#{W:#{?window_active,#{pane_in_mode},}},1}`
   - zoom:       `#{m:*Z*,#{W:#{?window_active,#{window_flags},}}}`
   These already exist in `tubular.tmux` as the `mode_bg` / `mode_fg` builders.
   Priority order is **prefix > copy > zoom > normal**. Do not change it.

8. **Prefix highlighting requires the explicit option `@tubular_prefix_key`.**
   Auto-detecting the prefix was tried and abandoned: the plugin sets `prefix
   None` and rebinds the key to force a border repaint, and once nulled the
   original prefix can't be read back on reload. Leave the explicit-key design
   alone. It is out of scope for this task.

---

## Current exposed variables (inconsistent — rationalize them)

Three naming conventions are live today:

- **Dynamic (mode-reactive) formats:** `@tubular_mode_bg`, `@tubular_mode_fg`,
  `@tubular_pill_bg`, `@tubular_pill_fg`, `@tubular_icon_fg`, and legacy aliases
  `@tubular_status_bg` / `@tubular_status_fg` (= mode_bg/fg).
- **Static palette, underscore-prefixed "internal":** `@_tubular_bg`,
  `@_tubular_bg_max`, `@_tubular_bg_min`, `@_tubular_fg`, `@_tubular_fg_active`,
  `@_tubular_fg_focus`, `@_tubular_neutral_visible`, `@_tubular_neutral_hidden`,
  `@_tubular_prefix_color`, `@_tubular_copy_color`, `@_tubular_zoom_color`,
  `@_tubular_active_color`.
- **User INPUT options** (the user sets these): `@tubular_bg`, `@tubular_fg`,
  `@tubular_prefix_color`, `@tubular_copy_color`, `@tubular_zoom_color`,
  `@tubular_active_color`, etc.

### Proposed public API (confirm naming with the author — see Open Decisions)

- **Dynamic, reference with `E:`** — the current mode's colors:
  - `@tubular_mode_bg`, `@tubular_mode_fg`
- **Static palette** — users reference their own input options directly, no `E:`:
  - `@tubular_prefix_color`, `@tubular_copy_color`, `@tubular_zoom_color`,
    `@tubular_active_color`, `@tubular_bg`, `@tubular_fg`, and the neutrals.
- Keep the `@_tubular_*` duplicates as INTERNAL only (used inside the plugin's own
  format strings); do not document them as public. Optionally keep
  `@tubular_status_bg/fg` as documented aliases of `mode_bg/fg`, or drop them.

The deliverable includes a **documented, stable "Theme Color Reference" section**
in `README.md` listing exactly the public variables, whether each needs `E:`, and
copy-paste examples of a custom status-left segment that stays seamless.

---

## Open decisions — GET THE AUTHOR TO CONFIRM BEFORE CODING

1. **Does managing content default ON or OFF?** tmux always has a default
   `status-left`, so "did the user customize it?" is not reliably detectable. Use a
   master switch, e.g. `@tubular_manage_content`:
   - `on`  → tubular sets its own pretty content (pills, caps, icons) = today's
     out-of-box look.
   - `off` → tubular sets only colors/styles; the user's native content shows.
   Recommendation: the author's north star ("leave configs as-is") argues for
   **default `off`**, but that changes the out-of-box appearance and existing
   screenshots. Default `on` preserves first impressions and makes BYO opt-in.
   **This is a product call — ask.**

2. **Per-option granularity vs one switch?** Alternative to the master switch:
   only overwrite each content option when its `@tubular_*_text` is explicitly set
   (e.g. only own `status-left` if `@tubular_status_left_text` is set). More
   flexible, but the "is it set?" test must distinguish unset from empty-string.
   Ask whether the author wants the coarse switch or per-option opt-in.

3. **Final public variable names** (section above) — confirm before renaming, since
   it's a stable API surface for a plugin about to be released.

---

## Concrete tasks (once decisions are locked)

1. Ensure **all** per-segment `*-style` options are set to the mode colors, so
   inheritance + `#[default]` work uniformly across left, right, and window lists.
2. Gate the content-owning `set-option` calls (`status-left`, `status-right`,
   `window-status-separator`, `window-status-format`,
   `window-status-current-format`) behind the chosen switch / opt-in logic. When
   not managing content, leave the native values untouched (do NOT set them to
   empty — unset/skip).
3. Rationalize the exposed color variables into the confirmed public API. Keep the
   plugin's internal formats working.
4. Verify `status-bg`/`status-fg` remain unset and legacy machinery stays cleaned.
5. Update `README.md`: new "Theme Color Reference" section (variables, `E:` rule,
   `#[default]` tip, seamless custom-segment example) and a "Bring your own status
   line" section explaining the switch.

---

## Testing — REQUIRED, and detached sessions do NOT render the status bar

Use a **nested attached client** and capture escape codes. A detached session
won't render the status line, so you must attach a real client:

```bash
PLUGIN=~/.config/tmux/plugins/tubular-tmux/tubular.tmux
tmux -L inner -f /path/to/test.conf new-session -d -s t -x 130 -y 30 'zsh -f'
tmux -L outer -f /dev/null new-session -d -x 140 -y 35
tmux -L outer send-keys -t 0 "TERM=xterm-256color tmux -L inner attach -t t" Enter
sleep 1
# capture WITH escapes, inspect backgrounds:
tmux -L outer capture-pane -e -p -t 0 | sed -n 1p | grep -o '48;2;[0-9;]*m' | sort -u
```

Color references: `#d27e99`=`210;126;153` (old pink), prefix now `#fffef7`, copy
`#fffef7`, zoom `#627d9a`, active `#dfc5a4`. Confirm current defaults from
`tubular.tmux` before asserting expected values.

Test the full matrix — for each of: **content-managed ON** and **content-managed
OFF (native status-left/right/windows)**:
- normal / prefix / copy / zoom each color the WHOLE bar (one background spans it,
  including separators and padding);
- a **custom user segment** like `status-left "#[fg=red]X#[default] #S "` shows red
  X then snaps back to the mode color, and the snap-back TRACKS the mode (re-check
  after entering prefix — the `rest` should now be on the prefix color);
- a segment using `#[fg=#{E:@tubular_mode_fg}]` renders the correct dynamic color,
  and the same without `E:` renders garbage (proves the docs' warning);
- mode transitions still repaint (prefix entry + Escape exit revert cleanly).

Do not claim success from a fresh scratch server alone — the author's real server
carries legacy option state that fresh servers lack (this bit us before). If you
touch the live server, test via a throwaway helper session, and restore state.

## Acceptance criteria
- With `@tubular_manage_content` off (or no content opts set), a user's native
  `status-left`/`status-right`/window list render unchanged in text, fully colored
  by the current mode, across all four modes.
- With it on, today's pill/caps/icon look is byte-for-byte preserved.
- A documented public color API exists; `#{E:...}` vs literal is explained; a
  copy-paste custom segment stays seamless and mode-reactive.
- No shell in the render path; no `status-bg`/`status-fg`; prefix behavior
  unchanged.
```
