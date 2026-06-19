# Field scenarios

Anonymized customer scenarios you can use as live discussion in workshops. Read the scenario, ask the room *"what would you check first?"*, then reveal the diagnostic steps one at a time.

---

## Scenario 1 — Model not visible in VS Code

> Customer: *"I installed the Claude Code extension and set the env vars, but it keeps asking me to sign in to Anthropic."*

**Diagnostic walk:**

1. Ask the customer to run `claude` in a terminal → `/status`. What does *API provider* say?
2. If it says `Anthropic`, run `echo $env:CLAUDE_CODE_USE_FOUNDRY` (PowerShell) / `echo $CLAUDE_CODE_USE_FOUNDRY` (bash). If empty → not inherited; use `setx` / `~/.bashrc` and sign out / open new shell.
3. Confirm `ANTHROPIC_FOUNDRY_RESOURCE` is the resource **name**, not a URL.
4. In VS Code `settings.json`, confirm `claudeCode.environmentVariables` is **array** form (gotcha #5).
5. **Fully quit** VS Code (not Reload Window) and relaunch with `code .` from a shell where the CLI already works.

**Root cause 75% of the time:** env var was set in one shell, but VS Code was launched from a different (older) process tree that never saw it.

---

## Scenario 2 — 401 / 403 (admin works, dev fails)

> Customer: *"Our admin tested the setup and it works for them. The dev gets 401."*

**Diagnostic walk:**

1. Get the Foundry resource name + resource group from the customer.
2. Run:
   ```bash
   RES=$(az cognitiveservices account show -g <rg> -n <foundry-resource> --query id -o tsv)
   az role assignment list --assignee <dev-id> --scope "$RES" -o table
   ```
3. Confirm `Foundry User` (role ID `53ca6127-db72-4b80-b1b0-d745d6d5456d`, formerly *Azure AI User*) is assigned to the dev at **resource** scope.
4. Scope trap: admin assigned the role at **subscription** scope but the Foundry resource lives in a different subscription → RBAC inheritance doesn't apply. Re-assign at **resource** scope.
5. Tenant check: `az account show` → same tenant as the Foundry resource?

**Root cause most of the time:** the role was assigned at the wrong scope, or the wrong role was assigned. Per the [Foundry RBAC doc](https://learn.microsoft.com/en-us/azure/foundry/concepts/rbac-foundry?tabs=owner) any role starting with `Cognitive Services *` does **not** apply to Foundry — older field guidance that recommended *also* assigning `Cognitive Services User` is obsolete.

---

## Scenario 3 — Works locally, fails in CI

> Customer: *"My laptop works fine, but our Actions runner can't reach Foundry."*

**Diagnostic walk:**

1. How does the runner authenticate? (OIDC federation? Service principal secret? Managed identity?)
2. Does the runner's identity have the **`Foundry User`** role on the Foundry resource at **resource** scope?
3. Is the runner inside a VNet with private endpoints? If yes, is the Foundry endpoint reachable?
4. Are env vars actually set in the workflow step? (`env:` block, not just `with:`)
5. Does the workflow run `az login` with the correct `tenant-id`?

**Root cause 50% of the time:** the runner's identity is missing the `Foundry User` role, OR the runner is in a private network and Foundry's public endpoint is blocked.

---

## How to use these in a workshop

1. Read scenario aloud. Pause.
2. Ask the room: *"What would you check first?"* Take 2–3 answers.
3. Reveal step 1. Ask: *"What output are you expecting?"*
4. Walk the remaining steps one at a time.
5. End each scenario with: *"Could you walk a customer through this on a Teams call right now?"* If you see hesitation → repeat the env-var inheritance / two-roles point.
