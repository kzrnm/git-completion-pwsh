Get-ChildItem -Recurse "$PSScriptRoot/../src" | Where-Object { $_.Extension -eq '.ps1' } | ForEach-Object { . $_.FullName }
. "$PSScriptRoot/../testtools/ConvertCompletion.ps1"
