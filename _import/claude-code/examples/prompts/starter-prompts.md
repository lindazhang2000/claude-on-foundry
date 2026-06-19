# Starter prompts

Copy/paste these into Claude Code (CLI or VS Code) to validate the setup and showcase value to customers.

---

## Smoke tests

> *"Show me the contents of `CLAUDE.md` and summarize the conventions you'll follow in this repo."*

> *"List the env vars Claude Code expects when routing to Microsoft Foundry and explain what each one does."*

---

## Diagnostic prompts (use these on customer calls)

> *"My `/status` shows `API provider: Anthropic`. Walk me through the diagnostic steps to figure out why."*

> *"I'm getting a 403 from Foundry. Generate the exact `az role assignment list` command I should ask the customer to run, with placeholders."*

> *"Compare the JSON shapes I might use for `claudeCode.environmentVariables` in `settings.json` and tell me which one the extension actually accepts."*

---

## Coding showcases

> *"Write a PowerShell function that wraps `az role assignment create` and assigns both required Foundry roles in one call."*

> *"Generate a GitHub Actions workflow that runs `verify-setup.sh` on a self-hosted Linux runner and fails the job if any check fails."*

> *"Refactor `scripts/setup-foundry.sh` to be safe when sourced (don't `exit` on errors)."*

---

## Tips

- Always open the repo folder first (`code .`) so Claude reads `CLAUDE.md`.
- For long debugging sessions, pin `/status` output at the top of the conversation.
- If a prompt produces low-quality output, re-read `CLAUDE.md` — that's where you tune the model's grounding.
