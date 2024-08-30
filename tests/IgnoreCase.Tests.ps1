using namespace System.Collections.Generic;

BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

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
                    $true  = @(
                        @{
                            CompletionText = 'branch.main.';
                            ListItemText   = 'branch.main.';
                            ResultType     = 'ParameterName';
                            ToolTip        = 'branch.main.';
                        }
                    )
                    $false = @(
                    )
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