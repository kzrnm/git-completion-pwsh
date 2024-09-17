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

mkdir $module

Copy-Item * -Recurse -Destination $module -Exclude $module, src, tests, tools, testtools, .github, .gitignore, .vscode
Copy-Item src/* -Recurse -Destination $module

(Get-Content "./src/$module.psd1" -Raw).Replace('blob/naub', "blob/$TagName") | Out-File -Encoding utf8NoBOM -FilePath "./$module/$module.psd1"
