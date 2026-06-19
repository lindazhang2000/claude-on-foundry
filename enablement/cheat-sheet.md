# Field cheat sheet — Claude Code on Microsoft Foundry

One page. Print it. Pin it to your monitor.

---

## Setup (5 steps)

1. Deploy `claude-sonnet-4-6` in Foundry (currently East US 2 / Sweden Central — more regions coming; check [Microsoft Learn](https://learn.microsoft.com/azure/ai-foundry/foundry-models/concepts/models#anthropic)).
2. Assign **`Foundry User`** at the Foundry **resource** scope (role ID `53ca6127-db72-4b80-b1b0-d745d6d5456d`, formerly *Azure AI User*). Don't add `Cognitive Services *` roles — they don't apply to Foundry.
3. `az login --tenant <foundry-tenant>`
4. `setx CLAUDE_CODE_USE_FOUNDRY 1` and `setx ANTHROPIC_FOUNDRY_RESOURCE <resource>`
5. From the SAME shell: `code .` (or run `claude`)

---

## Proof point

```
claude
> /status

API provider:                Microsoft Foundry
Microsoft Foundry resource:  <resource>
```

If you don't see those two lines, **stop and debug** — don't keep going.

---

## Three diagnostic commands

```bash
# What provider am I on?
claude   # then: /status

# Am I on the right tenant?
az account show

# Do I have BOTH required roles?
az role assignment list --assignee <user-id> --scope <foundry-resource-id> -o table
```

---

## Top 5 gotchas (memorize)

| # | Symptom | One-line fix |
|---|---|---|
| 1 | `baseURL and resource are mutually exclusive` | Unset `ANTHROPIC_BASE_URL` |
| 2 | `Unable to get authority for /<guid>` | `az login --tenant <foundry-tenant>` |
| 3 | 401 / 403 | Assign **both** required roles at resource scope |
| 4 | Prompts for Anthropic login | Env var not inherited — re-set and relaunch from SAME shell |
| 5 | `Unknown Configuration Setting` | `claudeCode.environmentVariables` must be ARRAY form |

---

## VS Code one-liner

```json
"claudeCode.environmentVariables": [
  { "name": "CLAUDE_CODE_USE_FOUNDRY",    "value": "1" },
  { "name": "ANTHROPIC_FOUNDRY_RESOURCE", "value": "<resource>" }
]
```

Then **fully quit** VS Code (not Reload Window) and relaunch with `code .`.
