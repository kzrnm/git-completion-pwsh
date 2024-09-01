using namespace System.Collections.Generic;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'IgnoreCase' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")

        Push-Location $rootPath
        git init --initial-branch=main
        git commit -m 'Initial' --allow-empty
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'gitHeads' {
        Describe '<Line>' -ForEach @(
            @{
                Line     = 'git config set branch.M';
                Expected = @{
                    $true  = 'branch.main.' | ConvertTo-Completion -ResultType ParameterName
                    $false = @()
                }
            }
        ) {
            It '<_>'  -ForEach @($true, $false) {
                $GitCompletionSettings.IgnoreCase = $_
                "$Line" | Complete-FromLine | Should -BeCompletion $Expected[$_]
            }
        }
    }
}