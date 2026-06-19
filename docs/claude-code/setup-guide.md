# Setup guide — Claude Code on Microsoft Foundry

End-to-end walkthrough for getting Claude Code (CLI + VS Code extension) talking to Claude models deployed in a Microsoft Foundry resource.

---

## 1. Prerequisites

| Item | Why |
|---|---|
| Foundry resource in a supported region (East US 2, Sweden Central) | Claude models are region-gated |
| **Both** RBAC roles on the Foundry resource: `Cognitive Services User` AND `Foundry User` | Single biggest cause of 401/403 |
| Azure CLI installed and on PATH | Needed for `az login` and `az account show` |
| Claude Code CLI installed | `irm https://claude.ai/install.ps1 \| iex` (Windows) / `curl -fsSL https://claude.ai/install.sh \| sh` (macOS/Linux) |
| Git Bash or WSL2 (Windows only) | Claude Code CLI requires a POSIX shell |

---

## 2. Deploy the models

Deploy at least `claude-sonnet-4-6`. Recommended: deploy all three so Claude Code can route by role.

| Role | Deployment name (default) | Purpose |
|---|---|---|
| Primary | `claude-sonnet-4-6` | Balanced coding |
| Fast | `claude-haiku-4-5` | Quick edits, file reads |
| Extended thinking | `claude-opus-4-6` | Complex reasoning |

```bash
az cognitiveservices account deployment create \
  --resource-group <rg> \
  --name <foundry-resource> \
  --deployment-name claude-sonnet-4-6 \
  --model-name claude-sonnet-4-6 \
  --model-version <version> \
  --model-format Anthropic \
  --sku-name GlobalStandard \
  --sku-capacity 1
```

---

## 3. Grant RBAC

Both roles are required. Assign at **resource scope** (not subscription scope, unless the resource lives in the same subscription).

```bash
RES=$(az cognitiveservices account show -g <rg> -n <foundry-resource> --query id -o tsv)

az role assignment create --assignee <user-or-sp-id> \
  --role "Cognitive Services User" --scope "$RES"

az role assignment create --assignee <user-or-sp-id> \
  --role "Foundry User" --scope "$RES"
```

Verify:

```bash
az role assignment list --assignee <user-id> --scope "$RES" -o table
```

---

## 4. CLI setup

```bash
az login --tenant <foundry-tenant>

export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=<foundry-resource>

claude
# inside Claude: type /status
# expect:
#   API provider:                Microsoft Foundry
#   Microsoft Foundry resource:  <foundry-resource>
```

PowerShell equivalent:

```powershell
az login --tenant <foundry-tenant>
$env:CLAUDE_CODE_USE_FOUNDRY    = "1"
$env:ANTHROPIC_FOUNDRY_RESOURCE = "<foundry-resource>"
claude
```

---

## 5. VS Code setup

Copy [../vscode/settings.sample.json](../vscode/settings.sample.json) into your User or Workspace `settings.json`:

```jsonc
{
  "claudeCode.environmentVariables": [
    { "name": "CLAUDE_CODE_USE_FOUNDRY",    "value": "1" },
    { "name": "ANTHROPIC_FOUNDRY_RESOURCE", "value": "<foundry-resource>" }
  ]
}
```

> ⚠️ **Schema trap.** MS Learn shows an object form. The extension only accepts the **array** form shown above.

Then:

1. From a shell where the CLI already works, run `code .`
2. **Fully quit** VS Code and relaunch — `Reload Window` does NOT re-read parent process env vars
3. Open the Claude Code panel → run `/status` → expect the Foundry provider line

---

## 6. Validate

Run [../scripts/verify-setup.ps1](../scripts/verify-setup.ps1) or [../scripts/verify-setup.sh](../scripts/verify-setup.sh). It checks:

- `az account show` succeeds and tenant matches
- `CLAUDE_CODE_USE_FOUNDRY=1` is set
- `ANTHROPIC_FOUNDRY_RESOURCE` is set
- `claude` is on PATH

If any check fails, jump to [troubleshooting.md](troubleshooting.md).
