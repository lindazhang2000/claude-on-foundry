# Sample project

Drop this folder into any empty directory and open it in VS Code with `code .` after running the setup script. Use it as a sandbox to confirm Claude Code is talking to Foundry before showing a customer.

## Suggested smoke test

1. Open this folder in VS Code (from an authenticated shell).
2. Open the Claude Code panel → `/status` → confirm `API provider: Microsoft Foundry`.
3. Ask Claude:  *"Create a small Python script that prints the current Azure tenant and subscription using the Azure CLI."*
4. Confirm Claude produces a runnable script and that it executes without prompting for credentials.

If any of these steps fails, jump to [../../docs/troubleshooting.md](../../docs/troubleshooting.md).
