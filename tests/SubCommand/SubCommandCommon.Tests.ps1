# Copyright (C) 2024 kzrnm
# Based on git-completion.bash (https://github.com/git/git/blob/HEAD/contrib/completion/git-completion.bash).
# Distributed under the GNU General Public License, version 2.0.
using namespace System.Collections.Generic;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe 'SubCommandCommon-check-ignore' {
    BeforeAll {
        Set-Variable 'Command' check-ignore
        Initialize-Home

        mkdir ($rootPath = "$TestDrive/gitRoot")

        Push-Location $rootPath
        git init --initial-branch=main
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--quiet';
                    Right    = ' --';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'suppress progress reporting'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'suppress progress reporting'
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

    Describe 'ShortOptions' {
        It '<_>' -ForEach @('', 'foo') {
            $expected = @{
                ListItemText = "-n";
                ToolTip      = "show non-matching input paths";
            }, 
            @{
                ListItemText = "-q";
                ToolTip      = "suppress progress reporting";
            }, 
            @{
                ListItemText = "-v";
                ToolTip      = "be verbose";
            },
            @{
                ListItemText = "-z";
                ToolTip      = "terminate input and output records by a NUL character";
            },
            @{
                ListItemText = "-h";
                ToolTip      = "show help";
            } | ConvertTo-Completion -ResultType ParameterName
            "git $Command $_ -" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'CommonOption' {
        Describe '<Line>' -ForEach @(
            @{
                Line     = "--q"
                Expected = "--quiet" | ConvertTo-Completion -ResultType ParameterName -ToolTip "suppress progress reporting";
            },
            @{
                Line     = "--v"
                Expected = "--verbose" | ConvertTo-Completion -ResultType ParameterName -ToolTip "be verbose";
            },
            @{
                Line     = "--no"
                Expected = @{
                    ListItemText = "--non-matching";
                    ToolTip      = "show non-matching input paths";
                },
                @{
                    ListItemText = "--no-index";
                    ToolTip      = "ignore index when checking";
                }, @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text'
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = "--no-"
                Expected = @{
                    ListItemText = "--no-index";
                    ToolTip      = "ignore index when checking";
                },
                @{
                    ListItemText = "--no-quiet";
                    ToolTip      = "[NO] suppress progress reporting";
                },
                @{
                    ListItemText = "--no-verbose";
                    ToolTip      = "[NO] be verbose";
                },
                @{
                    ListItemText = "--no-stdin";
                    ToolTip      = "[NO] read file names from stdin";
                },
                @{
                    ListItemText = "--no-non-matching";
                    ToolTip      = "[NO] show non-matching input paths";
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            
            It '<SubcommandLike>' -ForEach @(
                '', 'foo' | ForEach-Object {
                    @{
                        SubcommandLike = $_;
                        Line           = $Line;
                        Expected       = $Expected;
                    }
                }
            ) {
                "git $Command $SubcommandLike $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}