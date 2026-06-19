# Troubleshooting — Claude Code on Microsoft Foundry

Field-tested matrix. Add a row whenever you hit a new gotcha in a customer call.

---

## Top 12 gotchas

| # | Symptom | Where it shows up | Root cause | Fix |
| --- | --- | --- | --- | --- |
| 1 | `baseURL and resource are mutually exclusive` | CLI startup | Both `ANTHROPIC_BASE_URL` and `ANTHROPIC_FOUNDRY_RESOURCE` set | Unset `ANTHROPIC_BASE_URL`; keep the Foundry one |
| 2 | `Unable to get authority for /<guid>` | First API call | Logged into the wrong tenant | `az login --tenant <foundry-tenant>` |
| 3 | 401 / 403 on first request | First API call | `Foundry User` role not assigned (or wrong scope) | Assign **`Foundry User`** at **resource** scope. Don't add `Cognitive Services *` roles — they don't apply to Foundry. |
| 4 | Prompts for Anthropic login | CLI or VS Code panel | `CLAUDE_CODE_USE_FOUNDRY` not inherited by the process | Re-set in the SAME shell, relaunch from that shell |
| 5 | `Unknown Configuration Setting` in `settings.json` | VS Code settings | Wrong JSON shape (object instead of array) | Use the array form — see `examples/claude-code/vscode-settings.sample.json` |
| 6 | VS Code panel shows Anthropic, CLI shows Foundry | `/status` | VS Code launched from Start menu — didn't inherit env | Quit VS Code; relaunch with `code .` from an authenticated shell |
| 7 | Works after `Reload Window`, breaks on restart | VS Code | Env vars only set per-session | Persist via `setx` (Windows) or `~/.bashrc` (Linux/macOS) |
| 8 | `Model not found` on a working deployment | First API call | Deployment name doesn't match Claude's expected role name | Rename deployment to default (`claude-sonnet-4-6`) or override via config |
| 9 | Hangs forever on first request | CLI | Private endpoint / NSG blocks egress to Foundry | Allow-list Foundry endpoint or run from inside the VNet |
| 10 | CLI works, VS Code prompts for login | VS Code panel | Extension uses different process tree than CLI | Quit VS Code, relaunch via `code .` after `az login` |
| 11 | `Region not supported` | Deployment | Claude not available in chosen region | Redeploy in a supported region (currently East US 2 / Sweden Central — more coming; see [Microsoft Learn](https://learn.microsoft.com/azure/ai-foundry/foundry-models/concepts/models#anthropic)) |
| 12 | Role assigned but still 403 | First API call | Assigned at subscription scope, resource lives in a different sub | Re-assign **at the Foundry resource** scope |

---

## Common-failure quick table

| Symptom | Root cause |
| --- | --- |
| `API provider: Anthropic` | Env vars not inherited |
| 401/403 | Missing RBAC |
| `baseURL and resource are mutually exclusive` | Both vars set |
| `Unable to get authority` | Wrong tenant |
| `Unknown Configuration Setting` | Wrong settings.json shape |

---

## Diagnostic commands (ask any customer to run these)

```bash
# 1. Confirm provider
claude        # then type:  /status

# 2. Confirm tenant + subscription
az account show

# 3. Confirm RBAC
RES=$(az cognitiveservices account show -g <rg> -n <foundry-resource> --query id -o tsv)
az role assignment list --assignee <user-id> --scope "$RES" -o table
```

```powershell
# Confirm env vars in CURRENT shell
$env:CLAUDE_CODE_USE_FOUNDRY
$env:ANTHROPIC_FOUNDRY_RESOURCE
```

---

## Add a new gotcha

PRs welcome. Format:

```markdown
| <next #> | <one-line symptom> | <where shown> | <root cause> | <one-line fix> |
```
