# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'ShowAllOptions' -Tag Settings {
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

    Describe 'Options' {
        Describe '<Line>' -ForEach @(
            @{
                Line     = 'commit --allo';
                Expected = @{
                    $true  = '--allow-empty', '--allow-empty-message' | ConvertTo-Completion -ResultType ParameterName
                    $false = @()
                }
            },
            @{
                Line     = 'add --wa';
                Expected = @{
                    $true  = '--warn-embedded-repo' | ConvertTo-Completion -ResultType ParameterName
                    $false = @()
                }
            }
        ) {
            It '<_>'  -ForEach @($true, $false) {
                $GitCompletionSettings.ShowAllOptions = $_
                "git $Line" | Complete-FromLine | Should -BeCompletion $Expected[$_]
            }
        }

        AfterAll {
            $GitCompletionSettings.ShowAllOptions = $false
        }
    }
}