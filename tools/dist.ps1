# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $TagName
)

if (!$env:Module) {
    throw 'dist.ps1 requires $env:Module'
}

$Module = $env:Module

mkdir $Module -Force

Get-ChildItem * -File -Exclude .gitignore | Copy-Item -Destination $Module
(Get-Content "./src/git-completion.psd1" -Raw).Replace('blob/naub', "blob/$TagName") | Out-File -Encoding utf8NoBOM -FilePath "./$module/$module.psd1"

$psm1 = "./$module/$module.psm1"

'# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.' > "$psm1"

$files = Get-ChildItem -Recurse "./src/" | Where-Object Extension -EQ '.ps1' | ForEach-Object {
    [System.Management.Automation.Language.Parser]::ParseFile($_.FullName, [ref]$null, [ref]$null) 
}

if ($files.UsingStatements.UsingStatementKind -ne ([System.Management.Automation.Language.UsingStatementKind]::Namespace)) {
    throw 'Disallow using statements without `using namespace`'
}
if ($files.UsingStatements.Name.StringConstantType -ne ([System.Management.Automation.Language.StringConstantType]::BareWord)) {
    throw '`using namespace {Name}` must be BareWord'
}

$files.UsingStatements.Name.Value | Sort-Object -Unique | ForEach-Object { "using namespace $_;" } >> "$psm1"

'$ErrorActionPreference = ''Continue''' >> "$psm1"

foreach ($f in $files) {
    $f.EndBlock.ToString() >> "$psm1"
}

$skip = $true
foreach ($line in (Get-Content "./src/git-completion.psm1")) {
    if ($skip) {
        if ($line -like '*Lines above this point are for development only*') {
            $skip = $false
        }
        continue 
    }
    $line >> "$psm1"
}