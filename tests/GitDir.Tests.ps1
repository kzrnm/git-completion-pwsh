BeforeAll {
    . "$($PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))tests/_TestInitialize.ps1"
}

AfterAll {
    Remove-Module git-completion, _TestModule
}

Describe 'GirDir' {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        Push-Location $rootPath
        git init --initial-branch=main
        git commit -m "initial" --allow-empty
        git switch -c new --quiet
        Pop-Location
    }

    AfterAll {
        Restore-Home
    }

    It '--git-dir' {
        Push-Location $env:HOME
        "git --git-dir ../gitRoot/.git -c branch.n" | Complete-FromLine | Should -BeCompletion @(
            @{
                CompletionText = "branch.new.";
                ListItemText   = "branch.new.";
                ResultType     = 'ParameterName';
                ToolTip        = "branch.new.";
            }
        )
        Pop-Location
    }
    It '--git-dir=' {
        Push-Location $env:HOME
        "git --git-dir=../gitRoot/.git -c branch.n" | Complete-FromLine | Should -BeCompletion @(
            @{
                CompletionText = "branch.new.";
                ListItemText   = "branch.new.";
                ResultType     = 'ParameterName';
                ToolTip        = "branch.new.";
            }
        )
        Pop-Location
    }
    It '--bare' {
        Push-Location "$rootPath/.git"
        "git --bare -c branch.n" | Complete-FromLine | Should -BeCompletion @(
            @{
                CompletionText = "branch.new.";
                ListItemText   = "branch.new.";
                ResultType     = 'ParameterName';
                ToolTip        = "branch.new.";
            }
        )
        Pop-Location
    }
}
