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
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--all';
                    Right    = ' --';
                    Expected = '--all' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'show remote-tracking and local branches'
                },
                @{
                    Left     = '--all';
                    Right    = ' -- --all';
                    Expected = '--all' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'show remote-tracking and local branches'
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
                Line     = 'src -- --';
                Expected = @()
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }

        Describe-Revlist -Ref {
            "git $Command -- $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-a';
            ToolTip      = "show remote-tracking and local branches";
        },
        @{
            ListItemText = '-g';
            ToolTip      = "show <n> most recent ref-log entries starting at base";
        },
        @{
            ListItemText = '-r';
            ToolTip      = "show remote-tracking branches";
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
                Line     = '--a';
                Expected = @{
                    ListItemText = '--all';
                    ToolTip      = "show remote-tracking and local branches";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--t';
                Expected = @{
                    ListItemText = '--topo-order';
                    ToolTip      = "show commits in topological order";
                },
                @{
                    ListItemText = '--topics';
                    ToolTip      = "show only commits not on the first branch";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-a';
                Expected = @{
                    ListItemText = '--no-all';
                    ToolTip      = "[NO] show remote-tracking and local branches";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-t';
                Expected = @{
                    ListItemText = '--no-topics';
                    ToolTip      = "[NO] show only commits not on the first branch";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-n';
                Expected = @{
                    ListItemText = '--no-name';
                    ToolTip      = "suppress naming strings";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--n';
                Expected = @{
                    ListItemText = '--no-name';
                    ToolTip      = "suppress naming strings";
                },
                @{
                    ListItemText = '--name';
                    ToolTip      = "opposite of --no-name";
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text';
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist
}