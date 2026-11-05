#!/usr/bin/env python3
"""Check that the marketplaces and plugin manifests agree.

- Every local source in a marketplace exists and names a plugin directory.
- A plugin's harness manifests (.claude-plugin/plugin.json, .codex-plugin/plugin.json) agree on
  name, version and description, and the name matches the directory.
- Every plugin directory is listed in at least one marketplace.
- A Claude marketplace entry for a local plugin has a Claude manifest, and a Codex entry a Codex
  manifest, because Codex falls back to the Claude manifest and would install the wrong thing.

Run from the repository root: scripts/check-plugins.py
"""
import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MARKETPLACES = {
    "claude": (ROOT / ".claude-plugin/marketplace.json", ".claude-plugin/plugin.json"),
    "codex": (ROOT / ".agents/plugins/marketplace.json", ".codex-plugin/plugin.json"),
}
SHARED_FIELDS = ("name", "version", "description")

errors = []


def local_path(source):
    if isinstance(source, str):
        return source if source.startswith("./") else None
    if isinstance(source, dict) and source.get("source") == "local":
        return source.get("path")
    return None


listed = set()
for harness, (marketplace, manifest_name) in MARKETPLACES.items():
    if not marketplace.exists():
        errors.append(f"{marketplace.relative_to(ROOT)}: missing")
        continue
    data = json.loads(marketplace.read_text())
    for entry in data.get("plugins", []):
        path = local_path(entry.get("source"))
        if path is None:
            continue
        plugin_dir = (ROOT / path).resolve()
        where = f"{marketplace.relative_to(ROOT)}: {entry.get('name')}"
        if not plugin_dir.is_dir():
            errors.append(f"{where}: source {path} does not exist")
            continue
        listed.add(plugin_dir)
        if entry.get("name") != plugin_dir.name:
            errors.append(f"{where}: entry name differs from directory {plugin_dir.name}")
        if not (plugin_dir / manifest_name).exists():
            errors.append(f"{where}: {path} has no {manifest_name}")

for plugin_dir in sorted(p for p in (ROOT / "plugins").iterdir() if p.is_dir()):
    rel = plugin_dir.relative_to(ROOT)
    if plugin_dir.resolve() not in listed:
        errors.append(f"{rel}: not listed in any marketplace")
    manifests = {}
    for _, manifest_name in MARKETPLACES.values():
        manifest = plugin_dir / manifest_name
        if manifest.exists():
            manifests[manifest_name] = json.loads(manifest.read_text())
    for manifest_name, data in manifests.items():
        if data.get("name") != plugin_dir.name:
            errors.append(f"{rel}/{manifest_name}: name {data.get('name')!r} differs from directory")
    if len(manifests) > 1:
        for field in SHARED_FIELDS:
            values = {name: data.get(field) for name, data in manifests.items()}
            if len(set(map(json.dumps, values.values()))) > 1:
                errors.append(f"{rel}: manifests disagree on {field}: {values}")

for error in errors:
    print(f"error: {error}", file=sys.stderr)
sys.exit(1 if errors else 0)
