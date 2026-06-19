#!/usr/bin/env bash
# verify-setup.sh — Verify the Claude Code -> Microsoft Foundry setup.

set -uo pipefail

fail=0
pass() { printf '  \033[32m[PASS]\033[0m %s\n' "$1"; }
err()  { printf '  \033[31m[FAIL]\033[0m %s\n' "$1"; fail=1; }

echo "Verifying Claude Code -> Microsoft Foundry setup..."
echo

echo "Env vars:"
if [[ "${CLAUDE_CODE_USE_FOUNDRY:-}" == "1" ]]; then
    pass "CLAUDE_CODE_USE_FOUNDRY=1"
else
    err "CLAUDE_CODE_USE_FOUNDRY not set to 1 (got: '${CLAUDE_CODE_USE_FOUNDRY:-}')"
fi

if [[ -n "${ANTHROPIC_FOUNDRY_RESOURCE:-}" ]]; then
    pass "ANTHROPIC_FOUNDRY_RESOURCE=${ANTHROPIC_FOUNDRY_RESOURCE}"
else
    err "ANTHROPIC_FOUNDRY_RESOURCE is empty"
fi

if [[ -n "${ANTHROPIC_BASE_URL:-}" ]]; then
    err "ANTHROPIC_BASE_URL is set (${ANTHROPIC_BASE_URL}) — conflicts with Foundry routing. Unset it."
else
    pass "ANTHROPIC_BASE_URL is unset (good)"
fi

echo
echo "Azure CLI:"
if command -v az >/dev/null 2>&1; then
    pass "az on PATH"
    if acct=$(az account show --only-show-errors -o json 2>/dev/null); then
        tenant=$(echo "$acct" | sed -n 's/.*"tenantId": *"\([^"]*\)".*/\1/p' | head -n1)
        sub=$(echo "$acct"    | sed -n 's/.*"name": *"\([^"]*\)".*/\1/p'     | head -n1)
        pass "az account: tenant=$tenant, sub=$sub"
    else
        err "az account show failed — run: az login --tenant <foundry-tenant>"
    fi
else
    err "az not on PATH"
fi

echo
echo "Claude Code CLI:"
if command -v claude >/dev/null 2>&1; then
    pass "claude on PATH"
else
    err "claude not on PATH — install: curl -fsSL https://claude.ai/install.sh | sh"
fi

echo
if [[ $fail -ne 0 ]]; then
    printf '\033[31mOne or more checks failed. See docs/troubleshooting.md\033[0m\n'
    exit 1
else
    printf '\033[32mAll checks passed. Run "claude" then "/status" to confirm provider.\033[0m\n'
fi
