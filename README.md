# Agent Marketplace

Wyrd Company's coding harness plugin marketplaces, for Claude Code and Codex.

## Codex Marketplace

**Install:**

```bash
codex plugin marketplace add wyrd-company/agent-marketplace
```

### Plugins

- [async-claude-agentsdk-mcp](https://github.com/wyrd-company/async-claude-agentsdk-mcp): run Claude Agent SDK sessions as asynchronous Codex sub-agents with status, todo, and continuation tools.
- [git-operator](plugins/git-operator): keep each T3 Code thread's git commits attributed to the human operator it works for.

## Claude Marketplace

**Install:**

```bash
claude plugin marketplace add wyrd-company/agent-marketplace
```

### Plugins

- [async-codex-mcp](https://github.com/wyrd-company/async-codex-mcp): [`codex mcp-server`](https://developers.openai.com/codex/guides/agents-sdk) wrapped in async tools with Claude [channels](https://code.claude.com/docs/en/channels-reference) support.
- [git-operator](plugins/git-operator): keep each T3 Code thread's git commits attributed to the human operator it works for.

## Repository layout

```text
.claude-plugin/marketplace.json     # Claude Code marketplace
.agents/plugins/marketplace.json    # Codex marketplace
plugins/<name>/                     # one folder per plugin, shared by every harness
├── .claude-plugin/plugin.json      # Claude Code manifest
├── .codex-plugin/plugin.json       # Codex manifest
├── hooks/, skills/, .mcp.json ...  # plugin elements, shared where the formats agree
├── scripts/                        # shared logic that hooks and adapters call
└── README.md
docs/user/docs.yml                  # wyrd.foo product entries for the plugins in this repo
docs/user/<name>/                   # each plugin's public docs unit
.intentional/config.yml             # one release unit and one docs unit per plugin
scripts/check-plugins.py            # marketplaces and manifests agree
```

- **A plugin is one folder.** Each harness has its own manifest in that folder, and the plugin elements are shared.
  Harnesses copy a plugin's folder into their cache, so a plugin cannot use files outside it.
  Claude Code and Codex use the same `hooks/hooks.json` format, and Codex also sets `CLAUDE_PLUGIN_ROOT`.
- **Each marketplace lists only plugins with a manifest for its harness.** Codex reads `.claude-plugin/` files when its own are missing.
  A Codex-only plugin has only `.codex-plugin/`; a Claude-only one has only `.claude-plugin/`.
- **Plugins with their own repo stay there.** This repo only lists them in the marketplaces, and their docs publish from their own repo.
  A plugin's source lives here only when it has no other home.
- **Harnesses with code plugins (opencode, pi) get a thin adapter in the plugin's folder.** The adapter calls the same `scripts/`.
  It is distributed the way that harness expects.
- **Versions come from intentional.** Each plugin is a release unit at `plugins/<name>`, projected into every harness manifest and `docs/user/docs.yml`.
  Its public docs are the docs unit `<name>-docs` at `docs/user/<name>/`, published to [wyrd.foo](https://wyrd.foo).
