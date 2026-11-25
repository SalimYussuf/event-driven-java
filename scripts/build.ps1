<#
.SYNOPSIS
    Build pipeline runner for PowerShell.
.DESCRIPTION
    Compiles all Java modules across Weeks 1-10 via AgentCLI (run from source — JDK 11+ required).
.EXAMPLE
    .\scripts\build.ps1
    .\scripts\build.ps1 --clean
    .\scripts\build.ps1 --week 4
#>
param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$BuildArgs
)

& java (Join-Path $PSScriptRoot "AgentCLI.java") build @BuildArgs
