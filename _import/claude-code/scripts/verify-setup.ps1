<#
.SYNOPSIS
    Verify the Claude Code -> Microsoft Foundry setup on Windows.

.DESCRIPTION
    Checks env vars, Azure auth, and CLI availability. Exits non-zero on
    the first failed check so it can be used in CI.
#>
[CmdletBinding()]
param()

$ErrorActionPreference = 'Stop'
$fail = $false

function Pass($msg) { Write-Host "  [PASS] $msg" -ForegroundColor Green }
function Fail($msg) { Write-Host "  [FAIL] $msg" -ForegroundColor Red; $script:fail = $true }

Write-Host "Verifying Claude Code -> Microsoft Foundry setup..." -ForegroundColor Cyan
Write-Host ""

Write-Host "Env vars:"
if ($env:CLAUDE_CODE_USE_FOUNDRY -eq "1") {
    Pass "CLAUDE_CODE_USE_FOUNDRY=1"
} else {
    Fail "CLAUDE_CODE_USE_FOUNDRY not set to 1 (got: '$($env:CLAUDE_CODE_USE_FOUNDRY)')"
}

if ($env:ANTHROPIC_FOUNDRY_RESOURCE) {
    Pass "ANTHROPIC_FOUNDRY_RESOURCE=$($env:ANTHROPIC_FOUNDRY_RESOURCE)"
} else {
    Fail "ANTHROPIC_FOUNDRY_RESOURCE is empty"
}

if ($env:ANTHROPIC_BASE_URL) {
    Fail "ANTHROPIC_BASE_URL is set ($($env:ANTHROPIC_BASE_URL)) — conflicts with Foundry routing. Unset it."
} else {
    Pass "ANTHROPIC_BASE_URL is unset (good)"
}

Write-Host ""
Write-Host "Azure CLI:"
if (Get-Command az -ErrorAction SilentlyContinue) {
    Pass "az on PATH"
    try {
        $acct = az account show --only-show-errors -o json | ConvertFrom-Json
        Pass "az account: tenant=$($acct.tenantId), sub=$($acct.name)"
    } catch {
        Fail "az account show failed — run: az login --tenant <foundry-tenant>"
    }
} else {
    Fail "az not on PATH"
}

Write-Host ""
Write-Host "Claude Code CLI:"
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Pass "claude on PATH"
} else {
    Fail "claude not on PATH — install: irm https://claude.ai/install.ps1 | iex"
}

Write-Host ""
if ($fail) {
    Write-Host "One or more checks failed. See docs/troubleshooting.md" -ForegroundColor Red
    exit 1
} else {
    Write-Host "All checks passed. Run 'claude' then '/status' to confirm provider." -ForegroundColor Green
}
