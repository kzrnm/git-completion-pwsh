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
                    Left     = '--quiet';
                    Right    = ' --';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--quiet'
                },
                @{
                    Left     = '--quiet';
                    Right    = ' -- --all';
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--quiet'
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

        Describe-Revlist {
            "git $Command -- $Line" | Complete-FromLine | Should -BeCompletion $expected
            "git $Command -- --tool $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-d';
            ToolTip      = "perform a full-directory diff";
        },
        @{
            ListItemText = '-g';
            ToolTip      = 'use `diff.guitool` instead of `diff.tool`';
        },
        @{
            ListItemText = '-t';
            ToolTip      = "use the specified diff tool";
        },
        @{
            ListItemText = '-x';
            ToolTip      = "specify a custom command for viewing diffs";
        },
        @{
            ListItemText = '-y';
            ToolTip      = "do not prompt before launching a diff tool";
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
                Line     = '--t';
                Expected = @{
                    ListItemText = "--theirs";
                },
                @{
                    ListItemText = "--text";
                },
                @{
                    ListItemText = "--textconv";
                },
                @{
                    ListItemText = "--tool=";
                    ToolTip      = "use the specified diff tool"
                },
                @{
                    ListItemText = "--tool-help";
                    ToolTip      = 'print a list of diff tools that may be used with `--tool`'
                },
                @{
                    ListItemText = "--trust-exit-code";
                    ToolTip      = "make 'git-difftool' exit when an invoked diff tool returns a non-zero exit code"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--ind';
                Expected = @{
                    ListItemText = "--indent-heuristic";
                },
                @{
                    ListItemText = "--index";
                    ToolTip      = "opposite of --no-index"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-t';
                Expected = @{
                    ListItemText = "--no-textconv";
                },
                @{
                    ListItemText = "--no-tool";
                    ToolTip      = "[NO] use the specified diff tool"
                },
                @{
                    ListItemText = "--no-tool-help";
                    ToolTip      = '[NO] print a list of diff tools that may be used with `--tool`'
                },
                @{
                    ListItemText = "--no-trust-exit-code";
                    ToolTip      = "[NO] make 'git-difftool' exit when an invoked diff tool returns a non-zero exit code"
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = '--no-index',
                '--no-color',
                '--no-renames',
                '--no-color-moved',
                '--no-color-moved-ws',
                '--no-relative',
                '--no-ext-diff',
                '--no-prefix',
                '--no-indent-heuristic',
                '--no-textconv',
                '--no-patch',
                '--no-stat',
                @{
                    ListItemText = '--no-prompt';
                    ToolTip      = "do not prompt before launching a diff tool";
                },
                @{
                    ListItemText = '--no-index';
                    ToolTip      = 'passed to `diff`';
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

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--tool=k';
                Expected = 'kdiff3', 'kompare' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--tool=$_" }
            },
            @{
                Line     = '--tool=v';
                Expected = 'vimdiff' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--tool=$_" }
            },
            @{
                Line     = '--tool k';
                Expected = 'kdiff3', 'kompare' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--tool v';
                Expected = 'vimdiff' | ConvertTo-Completion -ResultType ParameterValue
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist
}