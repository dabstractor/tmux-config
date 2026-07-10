#!/usr/bin/env bash
# ~/.config/tmux/scripts/scroll.sh
#
# Interactive-app detector for the rotary-encoder Up binding. Exits 0 if an app
# that should receive the arrow keys is running anywhere under the given pane
# pid; exits 1 otherwise. The binding then passes the key through, else enters
# copy-mode (scrollback).
#
# Three situations this catches (all are an app nested under the pane's shell,
# invisible to tmux's own signals):
#   - inline pickers: fzf/sk/gum/fzy/peco in --height / Ctrl-R / tab mode, which
#     tmux misreports as the shell (cmd=zsh, alt=0).
#   - editors launched by another app: e.g. claude's Ctrl+G opens nvim, but tmux
#     still reports the pane as claude (cmd=claude, alt=1) -- so without this
#     check, claude's alt-screen exception would force copy-mode over the editor.
#   - pagers that don't grab the alt screen: `git diff`/`git log`/`git show`/`git
#     blame` (paged via `delta` -> `less` here), `man`, etc. run in the normal
#     screen buffer (alt=0), so without this check Up would enter copy-mode
#     instead of scrolling the pager.
#
# Why /proc/<pid>/task/<pid>/children instead of pstree: the kernel maintains
# that file, so we walk only this pane's subtree instead of scanning all of
# /proc -- ~5ms vs ~200ms for pstree on a busy system.
#
# Usage: scroll.sh <pane_pid> [raw_detect]
#   raw_detect=1 -> after the explicit `case` below misses, ALSO pass Up through
#   when the pane's tty is in raw mode (ICANON off), i.e. any app actively reading
#   keystrokes. Only the non-alt-screen branch passes this; the alt-screen/
#   claude branch omits it on purpose (claude is itself raw, and we want
#   copy-mode over its UI unless a nested editor/picker matched above).
# Add more apps to the `case` below.
pid="${1:?}"
raw_detect="${2:-}"   # =1 enables raw-mode fallback (non-alt-screen branch only)
stack="$pid"
while [ -n "$stack" ]; do
    node="${stack%% *}"; stack="${stack#"$node"}"; stack="${stack# }"
    case "$(cat /proc/"$node"/comm 2>/dev/null)" in
        # inline pickers
        fzf|sk|gum|fzy|peco) exit 0 ;;
        # editors (e.g. launched under claude via Ctrl+G)
        nvim|vim|vi|helix|hx|emacs|micro|nano|code) exit 0 ;;
        # pagers: git diff/log/show/blame (delta->less), man, etc.
        less|more|most|moar|bat|batcat|delta) exit 0 ;;
    esac
    children="$(cat /proc/"$node"/task/"$node"/children 2>/dev/null)"
    [ -n "$children" ] && stack="$children $stack"
done

# 2nd line of defense (non-alt-screen branch, opt-in via 2nd arg == 1): if no
# known app matched above, pass Up through when the pane's tty is in raw mode
# (ICANON off) -- i.e. any app actively reading keystrokes (vim, less, fzf,
# htop, tig, ssh -> remote vim, ...). Prompts / builds / streaming logs keep the
# tty canonical, so they still fall through to copy-mode. CAVEAT: full non-alt
# TUIs like `pi` are ALSO raw and run under the shell just like `less`, so this
# can't tell them apart -- it steals pi's Up and breaks its copy-mode scrollback.
# Hence @scroll_raw_detect defaults to 0. Opening the slave pty only does a
# non-destructive TCGETS (read termios), so it won't disturb the app.
if [ "$raw_detect" = 1 ]; then
    tty=$(readlink /proc/"$pid"/fd/0 2>/dev/null)
    if [ -c "$tty" ] && stty -a < "$tty" 2>/dev/null | grep -qiE '(^| )-icanon( |$)'; then
        exit 0
    fi
fi
exit 1
