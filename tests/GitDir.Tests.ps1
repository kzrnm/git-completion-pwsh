. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

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

    AfterEach {
        Pop-Location
    }

    It '<Location>:<Line>' -ForEach @(
        @{
            Location = '$TestDrive/home';
            Line     = 'git --git-dir ../gitRoot/.git -c branch.n';
            Expected = "branch.new." | ConvertTo-Completion -ResultType ParameterName
        },
        @{
            Location = '$TestDrive/home';
            Line     = 'git --git-dir ../gitRoot/.git -c ur';
            Expected = "url." | ConvertTo-Completion -ResultType ParameterName
        },
        @{
            Location = '$TestDrive/home';
            Line     = 'git --git-dir=../gitRoot/.git -c branch.n';
            Expected = "branch.new." | ConvertTo-Completion -ResultType ParameterName
        },
        @{
            Location = '$TestDrive/home';
            Line     = 'git --git-dir=../gitRoot/.git -c ur';
            Expected = "url." | ConvertTo-Completion -ResultType ParameterName
        },
        @{
            Location = '$TestDrive/gitRoot/.git';
            Line     = 'git --bare -c branch.n';
            Expected = "branch.new." | ConvertTo-Completion -ResultType ParameterName
        },
        @{
            Location = '$TestDrive/gitRoot/.git';
            Line     = 'git --bare -c ur';
            Expected = "url." | ConvertTo-Completion -ResultType ParameterName
        }
    ) {
        Push-Location (Invoke-Expression "echo $Location")
        $Line | Complete-FromLine | Should -BeCompletion $Expected
    }
}
