#!/bin/sh
# PostToolUse hook: applies the plain-writing gate to prose files written through Bash.
#
# The shipped gate is registered on Write|Edit|NotebookEdit|Artifact. A document created with
# a heredoc, sed -i, tee or a Ruby script never passes through those tools, so it is never
# checked. This hook closes that path. It does not reimplement the guide: it detects which
# prose files a Bash command just wrote and replays each one through the same gate.rb, so the
# device routing, the page pointer and the once-per-session cache all behave identically.
#
# Fails open everywhere. Missing jq, missing gate, unreadable payload: exit 0, say nothing.

# Resolve the directory this script lives in, through symlinks, the same way run-hook.sh does, so an
# installed link in ~/.claude/hooks keeps finding the skill it points into.
target="$0"
while [ -L "$target" ]; do
  link=$(readlink "$target")
  case "$link" in
    /*) target="$link" ;;
    *) target="$(dirname "$target")/$link" ;;
  esac
done
HOOK_DIR=$(cd "$(dirname "$target")" && pwd) || exit 0

INPUT=$(cat)
[ -n "$INPUT" ] || exit 0
command -v jq >/dev/null 2>&1 || exit 0

GATE="$HOOK_DIR/gate.rb"
[ -f "$GATE" ] || exit 0
command -v ruby >/dev/null 2>&1 || exit 0

TOOL=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null) || exit 0
[ "$TOOL" = "Bash" ] || exit 0

# Subagents are skipped, matching the shipped gate.
AGENT=$(printf '%s' "$INPUT" | jq -r '.agent_id // ""' 2>/dev/null)
[ -z "$AGENT" ] || exit 0

CMD=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
[ -n "$CMD" ] || exit 0

# Fast path: most commands touch no prose at all. A command that runs a script still passes,
# because the script writes paths that never appear on the command line.
printf '%s' "$CMD" | grep -qE '\.(md|markdown|html|htm|txt|rst|adoc|rb|sh)\b' || exit 0

SESSION=$(printf '%s' "$INPUT" | jq -r '.session_id // ""' 2>/dev/null)
CWD=$(printf '%s' "$INPUT" | jq -r '.cwd // ""' 2>/dev/null)
[ -n "$CWD" ] || CWD=$(pwd)

# Candidate paths: every prose-looking token in the command, plus the same from any Ruby or
# shell script the command runs, since a script writes paths that never appear on the line.
scan() {
  grep -oE "[A-Za-z0-9_./~@-]+\.(md|markdown|html|htm|txt|rst|adoc)\b" 2>/dev/null
}

CANDIDATES=$(printf '%s\n' "$CMD" | scan)
for s in $(printf '%s\n' "$CMD" | grep -oE '[A-Za-z0-9_./-]+\.(rb|sh)\b' 2>/dev/null); do
  case "$s" in /*) p="$s" ;; *) p="$CWD/$s" ;; esac
  [ -f "$p" ] && CANDIDATES="$CANDIDATES
$(scan < "$p")"
done

CONTEXT=""
CHECKED=""
for c in $CANDIDATES; do
  case "$c" in
    /*) f="$c" ;;
    "~/"*) f="$HOME/${c#~/}" ;;
    *) f="$CWD/$c" ;;
  esac
  [ -f "$f" ] || continue
  # Only files this command actually touched: modified within the last two minutes.
  [ -n "$(find "$f" -mmin -2 2>/dev/null)" ] || continue
  # Skip anything too large to be a document.
  [ "$(wc -c < "$f" 2>/dev/null || echo 0)" -lt 2000000 ] || continue
  case "
$CHECKED" in *"
$f"*) continue ;; esac
  CHECKED="$CHECKED
$f"

  OUT=$(printf '%s' "$INPUT" | jq --arg p "$f" --arg s "$SESSION" \
    '{tool_name:"Write", tool_input:{file_path:$p}, session_id:$s, cwd:(.cwd // "")}' 2>/dev/null \
    | env -u RUBYOPT ruby "$GATE" 2>/dev/null \
    | jq -r '.hookSpecificOutput.additionalContext // ""' 2>/dev/null)

  [ -n "$OUT" ] || continue
  CONTEXT="$CONTEXT$OUT

"
done

[ -n "$CONTEXT" ] || exit 0

printf '%s' "$CONTEXT" | jq -Rs '{hookSpecificOutput:{hookEventName:"PostToolUse", additionalContext:.}}'
exit 0
