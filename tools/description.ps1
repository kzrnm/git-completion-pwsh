# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

param(
    [Parameter(Position = 0, Mandatory)][string]$Command,
    [Parameter(ValueFromRemainingArguments)][string[]]$Subcommands,
    [string] $ColoredFile,
    [switch] $PathThru
)

$ErrorActionPreference = 'Stop'
. "$PSScriptRoot/../src/Common/GitDescription.ps1"

if ($ColoredFile) {
    function local:Write-HostDummy {
        param($line, [switch]$NoNewLine)
    
        $line | Out-File $ColoredFile -NoNewline:$NoNewLine -Append
        Write-Host $line -NoNewline:$NoNewLine
    }
}

$gh = Get-GitHelp -Command $Command -ShowParser:(!$ColoredFile)
if ($PathThru) {
    $gh
}
