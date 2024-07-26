[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]
    $TagName
)

$module = "git-completion"

mkdir $module

Copy-Item * -Recurse -Destination $module -Exclude $module, src, tools, .github, .gitignore, .vscode
Copy-Item src/* -Recurse -Destination $module

(Get-Content "./$module.psd1" -Raw).Replace('blob/master', "blob/$TagName") | Out-File -Encoding utf8NoBOM -FilePath "./$module/$module.psd1"
