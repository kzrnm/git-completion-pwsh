# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'IgnoreCase' -Tag Settings {
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

        AfterAll {
            $GitCompletionSettings.IgnoreCase = $false
        }
    }
}