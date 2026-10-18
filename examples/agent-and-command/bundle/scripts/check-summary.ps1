# Passes when SUMMARY.md exists and holds 1 to 120 words.
$ErrorActionPreference = 'Stop'

if (-not (Test-Path -LiteralPath 'SUMMARY.md' -PathType Leaf)) {
  Write-Output 'SUMMARY.md is missing.'
  exit 1
}

$words = @((Get-Content -LiteralPath 'SUMMARY.md' -Raw) -split '\s+' | Where-Object { $_ }).Count
Write-Output "SUMMARY.md has $words words."
if ($words -ge 1 -and $words -le 120) { exit 0 } else { exit 1 }
