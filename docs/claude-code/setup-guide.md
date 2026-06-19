# Setup guide — Claude Code on Microsoft Foundry

End-to-end walkthrough for getting Claude Code (CLI + VS Code extension) talking to Claude models deployed in a Microsoft Foundry resource.

---

## 1. Prerequisites

| Item | Why |
|---|---|
| Foundry resource in a supported region (East US 2, Sweden Central) | Claude models are region-gated |
| `Foundry User` role on the Foundry resource (role ID `53ca6127-db72-4b80-b1b0-d745d6d5456d`, formerly *Azure AI User*) | Single biggest cause of 401/403. Don't add `Cognitive Services *` roles — they don't apply to Foundry. |
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

Assign `Foundry User` at the Foundry **resource scope** (not subscription scope, unless the resource lives in the same subscription).

```bash
RES=$(az cognitiveservices account show -g <rg> -n <foundry-resource> --query id -o tsv)

# Foundry User — role ID is rename-proof (works whether the display name in
# your tenant is "Foundry User" or the legacy "Azure AI User").
az role assignment create --assignee <user-or-sp-id> \
  --role 53ca6127-db72-4b80-b1b0-d745d6d5456d --scope "$RES"
```

> Per the [Foundry RBAC doc](https://learn.microsoft.com/en-us/azure/foundry/concepts/rbac-foundry?tabs=owner), any role starting with `Cognitive Services *` does **not** apply to Foundry. Older field guidance that also assigned `Cognitive Services User` is obsolete — don't carry it forward.

Verify:

```bash
az role assignment list --assignee <user-id> --scope "$RES" -o table
```

---

## 4. CLI setup

Run these in a **bash/zsh** terminal — on macOS/Linux that's any terminal; on Windows use **Git Bash** or **WSL2** (the Claude Code CLI itself requires a POSIX shell on Windows).

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

PowerShell equivalent (Windows). Use this to `az login` and set the env vars, then launch **VS Code** (`code .`) or a **Git Bash / WSL** shell from the same window — the env vars are inherited by the child process. `claude` itself won't run directly in PowerShell because the CLI requires a POSIX shell on Windows.

```powershell
az login --tenant <foundry-tenant>
$env:CLAUDE_CODE_USE_FOUNDRY    = "1"
$env:ANTHROPIC_FOUNDRY_RESOURCE = "<foundry-resource>"

code .          # launch VS Code with env vars inherited
# - or -
bash            # drop into Git Bash, then run: claude
```

> **The env vars only live in the shell that set them.** Launch `claude` (and `code .` for VS Code) from that same shell so the child process inherits them. To make them stick across new terminals, add the `export` lines to `~/.bashrc` / `~/.zshrc`, or on Windows persist them with `setx` (or use `./scripts/claude-code/setup-foundry.ps1 -Persist`).

---

## 5. VS Code setup

Copy [../../examples/claude-code/vscode-settings.sample.json](../../examples/claude-code/vscode-settings.sample.json) into your User or Workspace `settings.json`:

```jsonc
{
  "claudeCode.environmentVariables": [
    // --- Required ---
    { "name": "CLAUDE_CODE_USE_FOUNDRY",        "value": "1" },
    { "name": "ANTHROPIC_FOUNDRY_RESOURCE",     "value": "<foundry-resource>" },

    // --- Optional: per-role deployment overrides (only if your deployment names differ from the model IDs) ---
    { "name": "ANTHROPIC_DEFAULT_SONNET_MODEL", "value": "claude-sonnet-4-6" },
    { "name": "ANTHROPIC_DEFAULT_HAIKU_MODEL",  "value": "claude-haiku-4-5" },
    { "name": "ANTHROPIC_DEFAULT_OPUS_MODEL",   "value": "claude-opus-4-6" }
  ],

  // Foundry users auth via `az login` — suppress the irrelevant Anthropic sign-in prompt.
  "claudeCode.disableLoginPrompt": true,

  // Dock the Claude Code UI in the bottom panel (preference; remove or set to "sidebar" to change).
  "claudeCode.preferredLocation": "panel"
}
```

> **Where's the model deployment?** Claude Code discovers deployments **by name** inside the Foundry resource specified by `ANTHROPIC_FOUNDRY_RESOURCE`. If you followed [section 2](#2-deploy-the-models) and used `--deployment-name claude-sonnet-4-6` etc., no override is needed — the client finds them automatically. Set the `ANTHROPIC_DEFAULT_*_MODEL` trio only if you used custom deployment names. Use `/model` inside Claude to switch between discovered deployments.

> **Why `disableLoginPrompt`?** Authentication is handled entirely by `az login` — there is no Anthropic account in this flow. The prompt is misleading and clicking it can pollute the session with a public-Anthropic token, silently bypassing Foundry.

> ⚠️ **Schema trap.** MS Learn shows an object form. The extension only accepts the **array** form shown above.

Then:

1. From a shell where the CLI already works, run `code .`
2. **Fully quit** VS Code and relaunch — `Reload Window` does NOT re-read parent process env vars
3. Open the Claude Code panel → run `/status` → expect the Foundry provider line

---

## 6. Validate

Run [../../scripts/claude-code/verify-setup.ps1](../../scripts/claude-code/verify-setup.ps1) or [../../scripts/claude-code/verify-setup.sh](../../scripts/claude-code/verify-setup.sh). It checks:

- `az account show` succeeds and tenant matches
- `CLAUDE_CODE_USE_FOUNDRY=1` is set
- `ANTHROPIC_FOUNDRY_RESOURCE` is set
- `claude` is on PATH

If any check fails, jump to [troubleshooting.md](troubleshooting.md).
