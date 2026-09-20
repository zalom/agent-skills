#!/bin/sh
# Shared entry point for the plain-writing hooks. Claude Code registers this one file per
# event and names the hook as the first argument:
#
#   SessionStart   .../plain-writing session-start
#   PreToolUse     .../plain-writing gate
#   PostToolUse    .../plain-writing bash-gate
#
# The shim resolves its own directory through any symlinks, so an installed link in
# ~/.claude/hooks keeps finding the skill it points into. It fails open everywhere: a
# missing Ruby, a missing hook body, or an unknown name all exit 0 and the session or the
# tool call proceeds untouched.

target="$0"
while [ -L "$target" ]; do
  link=$(readlink "$target")
  case "$link" in
    /*) target="$link" ;;
    *) target="$(dirname "$target")/$link" ;;
  esac
done
hook_dir=$(cd "$(dirname "$target")" && pwd) || exit 0

name="$1"
[ -n "$name" ] || exit 0
shift

case "$name" in
  *[!a-z-]*) exit 0 ;;
esac

# A shell hook wins over a Ruby one of the same name, so a hook can be ported to shell
# without changing how it is registered.
if [ -f "$hook_dir/$name.sh" ]; then
  exec sh "$hook_dir/$name.sh" "$@"
fi

script="$hook_dir/$name.rb"
[ -f "$script" ] || exit 0
command -v ruby >/dev/null 2>&1 || exit 0

exec env -u RUBYOPT ruby "$script" "$@"
