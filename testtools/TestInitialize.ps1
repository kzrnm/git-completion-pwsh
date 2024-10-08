# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
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
. "$PSScriptRoot/Revlist.ps1"
Import-Module "$PSScriptRoot/TestModule.psm1" -DisableNameChecking -Force

BeforeAll {
    Get-Module git-completion,TestModule | Remove-Module
    Import-Module "$PSScriptRoot/../src/git-completion.psd1" -Force
    Import-Module "$PSScriptRoot/TestModule.psm1" -DisableNameChecking -Force
}
