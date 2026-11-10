#!/bin/sh
# Start the mnemonic MCP server (https://github.com/danielmarbach/mnemonic) on stdio, for Claude Code
# (this plugin's .mcp.json) and Codex (an [mcp_servers.mnemonic] entry in /etc/codex/config.toml,
# workspace-ansible, that runs this script from the marketplace checkout).
#
# mnemonic reads its embedding key from EMBED_API_KEY, and the key is kept neither in a config file
# nor in the environment. envconsul reads it from Vault and sets it only for the server. Everything
# workspace-specific is in /etc/mnemonic/config.hcl (workspace-ansible): the secret path and the
# server's other EMBED_* and VAULT_PATH variables. The Vault address is VAULT_ADDR.
#
# -once: read the secret at start and do not watch it. Watching would restart the server when the
# key changes, which cuts the harness's MCP session; a new key takes effect in the next session.
#
# The package has no `mnemonic-mcp` binary, so `npx @danielmarbach/mnemonic-mcp` fails with
# "could not determine executable to run"; name the package and the `mnemonic` binary.

config=/etc/mnemonic/config.hcl

if ! command -v envconsul >/dev/null 2>&1; then
  echo "mnemonic: envconsul is not on PATH" >&2
  exit 1
fi
if [ ! -r "$config" ]; then
  echo "mnemonic: $config is missing; workspace-ansible installs it" >&2
  exit 1
fi

exec envconsul -config="$config" -once \
  npx --yes --package=@danielmarbach/mnemonic-mcp@1.0.0 mnemonic
