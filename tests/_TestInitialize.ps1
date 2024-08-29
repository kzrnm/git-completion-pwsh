function Test-GitVersion {
    $minGitVersion = [version]::new(2, 45)
    if (!((git --version) -match 'version\s*(\d+\.\d+\.\d+)')) {
        throw "Failed to parse version"
    }
    if ([version]::Parse($Matches[1]) -lt $minGitVersion) {
        throw "Use Git version $minGitVersion"
    }
}

Test-GitVersion
Import-Module "$PSScriptRoot/../src/git-completion.psd1"
Import-Module "$PSScriptRoot/_TestModule.psm1" -DisableNameChecking
