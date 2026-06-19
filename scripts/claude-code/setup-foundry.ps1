<#
.SYNOPSIS
    Bootstrap Claude Code -> Microsoft Foundry on Windows / PowerShell.

.DESCRIPTION
    Logs into Azure in the target tenant, sets the two required env vars
    for the current session, and (optionally) persists them via setx so
    new shells inherit them.

.EXAMPLE
    ./setup-foundry.ps1 -ResourceName my-foundry -TenantId <guid>

.EXAMPLE
    ./setup-foundry.ps1 -ResourceName my-foundry -TenantId <guid> -Persist
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ResourceName,

    [Parameter(Mandatory = $true)]
    [string]$TenantId,

    [switch]$Persist
)

$ErrorActionPreference = 'Stop'

Write-Host "==> Checking Azure CLI..." -ForegroundColor Cyan
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI ('az') not found on PATH. Install from https://aka.ms/azcli."
}

Write-Host "==> az login --tenant $TenantId" -ForegroundColor Cyan
az login --tenant $TenantId | Out-Null

Write-Host "==> Setting env vars for this session..." -ForegroundColor Cyan
$env:CLAUDE_CODE_USE_FOUNDRY    = "1"
$env:ANTHROPIC_FOUNDRY_RESOURCE = $ResourceName

if ($Persist) {
    Write-Host "==> Persisting env vars via setx (new shells only)..." -ForegroundColor Cyan
    setx CLAUDE_CODE_USE_FOUNDRY    "1"            | Out-Null
    setx ANTHROPIC_FOUNDRY_RESOURCE $ResourceName  | Out-Null
    Write-Host "    (existing shells & VS Code must be relaunched to pick these up)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Done. Next steps:" -ForegroundColor Green
Write-Host "  1. From THIS shell, launch VS Code:  code ."
Write-Host "  2. Or run the CLI now:               claude   (then type /status)"
Write-Host "  3. Expect:                           API provider: Microsoft Foundry"
