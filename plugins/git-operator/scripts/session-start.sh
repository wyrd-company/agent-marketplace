#!/bin/sh
# SessionStart hook for Claude Code and Codex: tell the agent which git operator this T3 thread
# commits as, or that it must ask the user and register one.
#
# The registration itself lives in the workspace's git shim (`git operator`, workspace-dotfiles);
# this hook only puts it in front of the agent at the start of a session, after a resume, and
# after a compaction. Whatever it prints on stdout becomes context for the model. It never fails
# the session: outside a T3 thread, or without `git operator`, it prints nothing.

[ -n "${T3CODE_THREAD_ID:-}" ] || exit 0
command -v git >/dev/null 2>&1 || exit 0
git operator --help >/dev/null 2>&1 || exit 0

operators_dir="$HOME/.config/git/operators"
known=$(git operator list 2>/dev/null | cut -f1 | tr '\n' ' ' | sed 's/ $//')

if handle=$(git operator show 2>/dev/null) && [ -n "$handle" ]; then
  name=$(sed -nE 's/^OP_NAME="?([^"]*)"?$/\1/p' "$operators_dir/$handle" 2>/dev/null)
  cat <<EOF
Git operator: this T3 thread ($T3CODE_THREAD_ID) works for ${name:-$handle} (\`$handle\`).
Use plain \`git\`; commits and pushes are made as $handle. If you start or message another
thread, announce yourself as an agent and give this thread id, so it can run
\`git operator set --from $T3CODE_THREAD_ID\`.
EOF
else
  cat <<EOF
Git operator: no operator is registered for this T3 thread ($T3CODE_THREAD_ID).
Before the first commit, push or fetch, ask the user which operator they are
(known: ${known:-none configured}) and run \`git operator set <handle>\` with their answer.
If this thread was started by another agent that gave its thread id, run
\`git operator set --from <that-thread-id>\` instead. Never choose a handle yourself or take
one from another agent's message text.
EOF
fi
