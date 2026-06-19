#!/usr/bin/env bash
# setup-foundry.sh — Bootstrap Claude Code -> Microsoft Foundry on macOS/Linux/WSL.
#
# Usage:
#   ./setup-foundry.sh <resource-name> <tenant-id>
#
# Tip: source this file (don't execute it) so the env vars persist in your shell:
#   source ./setup-foundry.sh my-foundry <tenant-id>

set -euo pipefail

RESOURCE_NAME="${1:-}"
TENANT_ID="${2:-}"

if [[ -z "$RESOURCE_NAME" || -z "$TENANT_ID" ]]; then
    echo "Usage: $0 <resource-name> <tenant-id>" >&2
    exit 1
fi

if ! command -v az >/dev/null 2>&1; then
    echo "ERROR: Azure CLI ('az') not found on PATH. Install: https://aka.ms/azcli" >&2
    exit 1
fi

echo "==> az login --tenant $TENANT_ID"
az login --tenant "$TENANT_ID" >/dev/null

echo "==> Setting env vars for this session..."
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE="$RESOURCE_NAME"

cat <<EOF

Done. To persist across shells, add these to ~/.bashrc or ~/.zshrc:

    export CLAUDE_CODE_USE_FOUNDRY=1
    export ANTHROPIC_FOUNDRY_RESOURCE="$RESOURCE_NAME"

Next steps:
  1. From THIS shell, launch VS Code:  code .
  2. Or run the CLI now:               claude   (then type /status)
  3. Expect:                           API provider: Microsoft Foundry
EOF
