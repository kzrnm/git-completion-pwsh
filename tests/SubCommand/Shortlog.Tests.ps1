# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
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
                    Left     = '--tags';
                    Right    = ' --';
                    Expected = '--tags' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--tags'
                },
                @{
                    Left     = '--tags';
                    Right    = ' -- --all';
                    Expected = '--tags' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--tags'
                }
            ) {
                "git $Command $Left" | Complete-FromLine -Right $Right | Should -BeCompletion $Expected
            }
        }

        It '<Line>' -ForEach @(
            @{
                Line     = 'src -- -';
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
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-c';
            ToolTip      = "group by committer rather than author";
        },
        @{
            ListItemText = '-e';
            ToolTip      = "show the email address of each author";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "sort output according to the number of commits per author";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "suppress commit descriptions, only provides commit count";
        },
        @{
            ListItemText = '-w';
            ToolTip      = "]] linewrap output";
        },
        @{
            ListItemText = '-h';
            ToolTip      = "show help";
        } | ConvertTo-Completion -ResultType ParameterName
        "git $Command -" | Complete-FromLine | Should -BeCompletion $expected
    }

    Describe 'Options' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--bi';
                Expected = '--bisect' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--exc';
                Expected = '--exclude', '--exclude-first-parent-only', '--exclude-hidden' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--c';
                Expected = @{
                    ListItemText = '--committer';
                    ToolTip      = "group by committer rather than author";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-committer';
                    ToolTip      = "[NO] group by committer rather than author";
                },
                @{
                    ListItemText = '--no-email';
                    ToolTip      = "[NO] show the email address of each author";
                },
                '--no-max-parents', '--no-merges', '--no-min-parents',
                @{
                    ListItemText = '--no-numbered';
                    ToolTip      = "[NO] sort output according to the number of commits per author";
                },
                @{
                    ListItemText = '--no-summary';
                    ToolTip      = "[NO] suppress commit descriptions, only provides commit count";
                },
                '--not' | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist
}