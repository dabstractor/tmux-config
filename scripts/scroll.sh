#!/usr/bin/env bash
# ~/.config/tmux/scripts/scroll.sh
#
# Interactive-app detector for the rotary-encoder Up binding. Exits 0 if an app
# that should receive the arrow keys is running anywhere under the given pane
# pid; exits 1 otherwise. The binding then passes the key through, else enters
# copy-mode (scrollback).
#
# Two situations this catches (both are an app nested under the pane's shell,
# invisible to tmux's own signals):
#   - inline pickers: fzf/sk/gum/fzy/peco in --height / Ctrl-R / tab mode, which
#     tmux misreports as the shell (cmd=zsh, alt=0).
#   - editors launched by another app: e.g. claude's Ctrl+G opens nvim, but tmux
#     still reports the pane as claude (cmd=claude, alt=1) -- so without this
#     check, claude's alt-screen exception would force copy-mode over the editor.
#
# Why /proc/<pid>/task/<pid>/children instead of pstree: the kernel maintains
# that file, so we walk only this pane's subtree instead of scanning all of
# /proc -- ~5ms vs ~200ms for pstree on a busy system.
#
# Usage: scroll.sh <pane_pid>
# Add more apps to the `case` below.
pid="${1:?}"
stack="$pid"
while [ -n "$stack" ]; do
    node="${stack%% *}"; stack="${stack#"$node"}"; stack="${stack# }"
    case "$(cat /proc/"$node"/comm 2>/dev/null)" in
        # inline pickers
        fzf|sk|gum|fzy|peco) exit 0 ;;
        # editors (e.g. launched under claude via Ctrl+G)
        nvim|vim|vi|helix|hx|emacs|micro|nano|code) exit 0 ;;
    esac
    children="$(cat /proc/"$node"/task/"$node"/children 2>/dev/null)"
    [ -n "$children" ] && stack="$children $stack"
done
exit 1
