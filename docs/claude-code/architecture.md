# Architecture

The mental model. Every failure maps to one arrow on this diagram.

```mermaid
flowchart LR
    subgraph DEV["Developer machine"]
        VSCODE["VS Code + Claude Code extension"]:::dev
        CLI["claude CLI"]:::dev
        ENV["Env vars<br/>CLAUDE_CODE_USE_FOUNDRY=1<br/>ANTHROPIC_FOUNDRY_RESOURCE"]:::gotcha
        AZL["az login session<br/>(Entra ID bearer)"]:::gotcha
    end

    subgraph FOUNDRY["Microsoft Foundry resource"]
        RBAC["RBAC<br/>Cognitive Services User<br/>+ Foundry User"]:::gotcha
        ENDPOINT["Custom subdomain endpoint<br/>(region matters)"]:::foundry
    end

    subgraph MODELS["Model deployments"]
        SONNET["claude-sonnet-4-6<br/>primary"]:::model
        HAIKU["claude-haiku-4-5<br/>fast"]:::model
        OPUS["claude-opus-4-6<br/>extended thinking"]:::model
    end

    VSCODE --> ENV
    CLI --> ENV
    ENV --> AZL
    AZL --> RBAC
    RBAC --> ENDPOINT
    ENDPOINT --> SONNET
    ENDPOINT --> HAIKU
    ENDPOINT --> OPUS

    classDef gotcha fill:#FFD43B,stroke:#B8860B,stroke-width:2.5px,color:#1a1a1a,font-weight:bold
    classDef dev fill:#E3F2FD,stroke:#1976D2,color:#0D47A1
    classDef foundry fill:#EDE7F6,stroke:#5E35B1,color:#311B92
    classDef model fill:#E8F5E9,stroke:#2E7D32,color:#1B5E20
    style DEV fill:#F8FAFC,stroke:#94A3B8,color:#0F172A
    style FOUNDRY fill:#F5F3FF,stroke:#7C3AED,color:#3B0764
    style MODELS fill:#F0FDF4,stroke:#16A34A,color:#052E16
```

**Yellow boxes = where 90% of customer failures occur.**

- **Env vars**: not inherited by the launching process (the #1 silent failure)
- **az login session**: wrong tenant, or token expired
- **RBAC**: only one of the two required roles assigned

---

## Request flow

1. Developer runs `claude` (or types in the VS Code panel)
2. Claude Code reads `CLAUDE_CODE_USE_FOUNDRY` → decides to route to Foundry
3. Claude Code reads `ANTHROPIC_FOUNDRY_RESOURCE` → builds the endpoint URL
4. Claude Code attaches the Entra ID bearer token from the current `az login` session
5. Foundry validates RBAC (both roles required)
6. Foundry routes the request to the deployment whose role matches (primary / fast / extended thinking)
7. Response streams back through the same path

---

## Why the env-var inheritance trap exists

Environment variables are copied from a parent process to its children **at fork time**. Setting them in a terminal AFTER launching VS Code from the Start menu has no effect on the already-running VS Code process tree. The fix is always the same: set env vars first, then launch the consumer.
