# mnemonic

The [mnemonic](https://github.com/danielmarbach/mnemonic) memory MCP server for Claude Code and
Codex in Wyrd workspaces. Notes are markdown in git: a private main vault, and a `.mnemonic/`
vault in each project repository.

mnemonic embeds notes through Xolotl and needs the workspace's Xolotl key in `EMBED_API_KEY`.
Workspaces keep that key in Vault only, never in a config file or a global environment variable,
so the server starts under [envconsul](https://github.com/hashicorp/envconsul): envconsul reads
the key through the workspace's Vault socket and sets it for the server process alone.

## Requirements

- `envconsul` and `npx` on `PATH`, and `VAULT_ADDR` set to the workspace's Vault socket.
- `/etc/mnemonic/config.hcl`, installed by
  [workspace-ansible](https://github.com/wyrd-company/workspace-ansible). It holds the secret
  path of the workspace's Xolotl key and sets the server's other variables: `VAULT_PATH`,
  `EMBED_PROVIDER`, `EMBED_BASE_URL`, `EMBED_MODEL` and `EMBED_DIMENSIONS`.

Without either, the server exits at start with a message on stderr.

## Install

Workspaces enable it for every user: Claude Code through `enabledPlugins` in the managed
settings, and Codex through an `[mcp_servers.mnemonic]` entry in `/etc/codex/config.toml` that
runs `scripts/mnemonic-mcp.sh` from the marketplace checkout. Codex passes MCP servers only a few
environment variables, so that entry forwards the ones the git shim needs to commit as the
thread's operator.

Elsewhere, with the requirements in place:

```bash
claude plugin marketplace add wyrd-company/agent-marketplace
claude plugin install mnemonic@wyrd-company
```

## Provides

| Element | Harnesses | What it does |
| --- | --- | --- |
| `mnemonic` MCP server | Claude Code, Codex | mnemonic's memory tools: `recall`, `remember`, `update`, `relate`, `sync` and the rest. |

## Layout

```text
mnemonic/
├── .claude-plugin/plugin.json   # Claude Code
├── .mcp.json                    # the MCP server, started by the script
└── scripts/mnemonic-mcp.sh      # envconsul and the pinned mnemonic package
```

The mnemonic version is pinned in `scripts/mnemonic-mcp.sh`.
