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

Copy-Item * -Recurse -Destination $module -Exclude $module, src, tests, tools, .github, .gitignore, .vscode
Copy-Item src/* -Recurse -Destination $module

(Get-Content "./src/$module.psd1" -Raw).Replace('blob/naub', "blob/$TagName") | Out-File -Encoding utf8NoBOM -FilePath "./$module/$module.psd1"
