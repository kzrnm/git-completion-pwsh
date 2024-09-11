# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
    BeforeAll {
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath
        git config set pretty.changelog "format:* %H %s"
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = @('gitk', '--left-o');
                    Right    = ' --';
                    Expected = '--left-only' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--left-only'
                },
                @{
                    Left     = @('gitk', '--left-o');
                    Right    = ' -- --all';
                    Expected = '--left-only' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--left-only'
                }
            ) {
                Complete-Gitk -Words ($Left + $Right) -CurrentIndex ($Left.Length - 1) | 
                Should -BeCompletion $expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = 'src -- -';
                Expected = @()
            },
            @{
                Line     = 'src -- --';
                Expected = @()
            },
            @{
                Line     = 'src -- ';
                Expected = @()
            },
            @{
                Line     = '-- ';
                Expected = @()
            }
        ) {
            "gitk $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--bi';
                Expected = '--bisect' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-n';
                Expected = '--no-notes' | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "gitk $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist {
        "gitk $Line" | Complete-FromLine | Should -BeCompletion $expected
    }
}