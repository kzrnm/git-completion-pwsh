function Test-GitVersion {
    $minGitVersion = [version]::new(2, 45)
    if (!((git --version) -match 'version\s*(\d+\.\d+\.\d+)')) {
        throw "Failed to parse version"
    }
    if ([version]::Parse($Matches[1]) -lt $minGitVersion) {
        throw "Use Git version $minGitVersion"
    }
}


$ErrorActionPreference = 'Continue'
Test-GitVersion
. "$PSScriptRoot/ConvertCompletion.ps1"

BeforeAll {
    Import-Module "$PSScriptRoot/../src/git-completion.psd1" -Force
    Import-Module "$PSScriptRoot/TestModule.psm1" -DisableNameChecking -Force
}
