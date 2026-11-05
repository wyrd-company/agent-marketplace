# git-operator

A session-start hook for Claude Code and Codex in shared Wyrd workspaces. It tells the agent
which human operator its T3 Code thread commits as, or asks it to have the user register one,
so plain `git`, scripts and hooks commit and push as the right person.

The registration lives in the workspace git shim and `git operator` command from
[workspace-dotfiles](https://github.com/wyrd-company/workspace-dotfiles). This plugin only puts
the registration in front of the agent at the start of a session, after a resume and after a
compaction. It prints nothing outside a T3 Code thread, or where `git operator` is not installed.

## Install

Claude Code:

```bash
claude plugin marketplace add wyrd-company/agent-marketplace
claude plugin install git-operator@wyrd-company
```

Codex:

```bash
codex plugin marketplace add wyrd-company/agent-marketplace
codex plugin add git-operator@wyrd-company
```

Codex does not run a plugin's hooks until you review and trust them, and it skips untrusted hooks
without a message. Trust the `git-operator` hook after installing it, and again after an update
that changes the script.

## Provides

| Element | Harnesses | What it does |
| --- | --- | --- |
| `SessionStart` hook | Claude Code, Codex | Adds the thread's operator, or the instruction to register one, to the model's context. |

## Layout

One folder serves every harness: each harness has its own manifest, and the hook and script are
shared.

```text
git-operator/
├── .claude-plugin/plugin.json   # Claude Code
├── .codex-plugin/plugin.json    # Codex
├── hooks/hooks.json             # SessionStart, same format in both harnesses
└── scripts/session-start.sh     # the logic
```
