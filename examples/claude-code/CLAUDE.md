# CLAUDE.md

> Project-level instructions for Claude Code. Claude reads this file automatically when running inside this repo and uses it to ground every response.

---

## Project context

This repository demonstrates how to configure **Claude Code** to run against **Microsoft Foundry**-hosted Claude models.

Claude should assume:

- Enterprise Azure environment
- Entra ID authentication (not API keys)
- Foundry resource-based routing (not direct anthropic.com)
- Customer may have private networking, conditional access, and strict RBAC

---

## Coding conventions

- Prefer **clear, minimal scripts** over complex abstractions
- Optimize for **reproducibility** and **debuggability**
- Always surface errors clearly, especially **auth** and **env-var** issues
- Use PowerShell for Windows examples, bash for macOS/Linux/WSL
- Quote all Azure resource names — they may contain hyphens or be confused with flags
- Never hardcode tenant IDs, subscription IDs, or resource names — use parameters

---

## Common tasks

### Validate environment

- Check env vars:
  - `CLAUDE_CODE_USE_FOUNDRY`
  - `ANTHROPIC_FOUNDRY_RESOURCE`
- Verify Azure auth:
  - `az account show`
- Verify Foundry connectivity:
  - `claude` → `/status` → expect `API provider: Microsoft Foundry`

### Troubleshoot setup

- If `/status` shows **"Anthropic"** → env vars are not set in the process that launched Claude Code. Re-set them and relaunch from the same shell.
- If **401 / 403** → RBAC issue. Verify **both** roles are assigned: `Cognitive Services User` AND `Foundry User`.
- If **"baseURL and resource are mutually exclusive"** → unset `ANTHROPIC_BASE_URL`, keep `ANTHROPIC_FOUNDRY_RESOURCE`.
- If **"Unable to get authority for /<guid>"** → wrong tenant. Re-run `az login --tenant <foundry-tenant>`.

---

## Known constraints

- Claude models are only available in **select regions** (e.g. East US 2, Sweden Central). West US 2 typically does not have them.
- VS Code extension requires environment variables via **array** format in `settings.json` (not object form — the MS Learn doc shows the wrong shape).
- VS Code must be launched **from an authenticated shell** (`code .`), NOT from the Start menu, or env vars won't be inherited.
- Use **Reload Window only when settings.json changes**. For env-var changes, **fully quit** VS Code and relaunch.
- On Windows, Claude Code CLI requires **Git Bash** or **WSL2** — `cmd.exe` and PowerShell-only environments will not work for the CLI itself.

---

## Preferred prompt style

- Be **explicit about environment** (Azure, Foundry, RBAC, tenant)
- Prefer **step-by-step diagnostic guidance** over one-shot answers
- Include **exact CLI commands** when possible, with placeholders in `<angle-brackets>`
- When ambiguous, ask the user to run `claude` → `/status` first and paste the output

---

## Example prompts

> "Diagnose why Claude Code is prompting for Anthropic login even after setting Foundry environment variables."

> "Write a one-liner to verify both required RBAC roles are assigned on a Foundry resource."

> "My VS Code Claude Code panel still shows Anthropic as the provider but the CLI shows Foundry. Why?"

---

## What NOT to do

- Do **not** suggest API-key-based auth — this repo is Entra ID only.
- Do **not** suggest setting `ANTHROPIC_BASE_URL` — Foundry routing is via `ANTHROPIC_FOUNDRY_RESOURCE`.
- Do **not** suggest "Reload Window" as a fix for env-var changes — it does not re-read parent process env.
- Do **not** invent role names — the only two required are `Cognitive Services User` and `Foundry User`.
