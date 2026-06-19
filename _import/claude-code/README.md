# Claude Code on Microsoft Foundry (VS Code + CLI Setup Guide)

Run Anthropic Claude Code against Azure-hosted models via **Microsoft Foundry** — with enterprise-grade security, compliance, and RBAC.

> Companion to the TechCommunity post and the field-enablement deck. This repo is the **doing** layer: scripts, configs, and gotchas you can hand a customer.

---

## What this repo includes

- ✅ End-to-end setup (CLI + VS Code)
- ✅ Working environment variable configuration
- ✅ Troubleshooting matrix from real-world field scenarios
- ✅ Sample `CLAUDE.md` for improving agent quality
- ✅ PowerShell + Bash setup and verification scripts
- ✅ Enablement assets (cheat sheet, scenarios, deck slot)

---

## TL;DR

**Setup**

- Deploy `claude-sonnet-4-6` (optionally `claude-haiku-4-5` + `claude-opus-4-6`)
- Assign **one of the two** roles on the Foundry resource:
  - `Cognitive Services User`
  - `Foundry User`
- Install the Claude Code CLI:
  - Windows (PowerShell): `irm https://claude.ai/install.ps1 | iex`
  - macOS / Linux / WSL: `curl -fsSL https://claude.ai/install.sh | sh`
  - Verify: `claude --version` *(Windows: run `claude` from Git Bash or WSL2 — not `cmd.exe` / PowerShell)*
- `az login --tenant <tenant>`
- Launch VS Code via `code .` from the authenticated shell

**Config**

- `CLAUDE_CODE_USE_FOUNDRY=1`
- `ANTHROPIC_FOUNDRY_RESOURCE=<resource>`

**Validate**

- Run `claude` → `/status`
- Expect: `API provider: Microsoft Foundry`

---

## Quick start

```bash
# Login to Azure
az login --tenant <tenant>

# Set environment variables (bash/zsh)
export CLAUDE_CODE_USE_FOUNDRY=1
export ANTHROPIC_FOUNDRY_RESOURCE=<resource>

# Launch Claude
claude
```

```powershell
# Windows (PowerShell): set env vars, then launch Git Bash / WSL2 to run `claude`
az login --tenant <tenant>
$env:CLAUDE_CODE_USE_FOUNDRY    = "1"
$env:ANTHROPIC_FOUNDRY_RESOURCE = "<resource>"
# Spawn a POSIX shell from this session so it inherits the env vars
& "C:\Program Files\Git\bin\bash.exe" -i   # or: wsl
# inside Git Bash / WSL:
claude
```

> **Windows note:** The Claude Code CLI requires a POSIX shell. You can set env vars in PowerShell, but `claude` itself must be launched from **Git Bash** or **WSL2** — not `cmd.exe` or PowerShell.

Or use the bundled scripts:

```powershell
# Windows
./scripts/setup-foundry.ps1 -ResourceName <resource> -TenantId <tenant>
./scripts/verify-setup.ps1
```

```bash
# macOS / Linux / WSL
./scripts/setup-foundry.sh <resource> <tenant>
./scripts/verify-setup.sh
```

---

## Resources

- **Deep-dive blog walkthrough** → [docs/blog.md](docs/blog.md)
- Setup guide → [docs/setup-guide.md](docs/setup-guide.md)
- Troubleshooting → [docs/troubleshooting.md](docs/troubleshooting.md)
- Architecture → [docs/architecture.md](docs/architecture.md)
- VS Code config → [vscode/settings.sample.json](vscode/settings.sample.json)
- Starter prompts → [examples/prompts/starter-prompts.md](examples/prompts/starter-prompts.md)
- Cheat sheet → [enablement/cheat-sheet.md](enablement/cheat-sheet.md)
- Field scenarios → [enablement/scenarios.md](enablement/scenarios.md)

---

## Common failure modes

| Symptom | Root cause |
|---|---|
| `API provider: Anthropic` | Env vars not inherited by the process |
| 401 / 403 | Missing one of the two required RBAC roles |
| `baseURL and resource are mutually exclusive` | Both `ANTHROPIC_BASE_URL` and `ANTHROPIC_FOUNDRY_RESOURCE` set |
| `Unable to get authority for /<guid>` | Logged into the wrong tenant |
| `Unknown Configuration Setting` in VS Code | `claudeCode.environmentVariables` is not in array form |

Full table: [docs/troubleshooting.md](docs/troubleshooting.md).

---

## Contributing

Found a new failure mode in the field? Add a row to [docs/troubleshooting.md](docs/troubleshooting.md) and open a PR. This is a living asset — the value compounds with every customer scenario captured.

---

## License

MIT — see [LICENSE](LICENSE).
