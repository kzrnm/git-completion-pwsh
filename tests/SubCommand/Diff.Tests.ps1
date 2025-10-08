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
                    Left     = '--no-prefix';
                    Right    = ' --';
                    Expected = '--no-prefix' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--no-prefix'
                },
                @{
                    Left     = '--no-prefix';
                    Right    = ' -- --all';
                    Expected = '--no-prefix' | ConvertTo-Completion -ResultType ParameterName -ToolTip '--no-prefix'
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

    It 'ShortOptions' {
        $expected = @{
            ListItemText = '-a';
            ToolTip      = "treat all files as text.";
        },
        @{
            ListItemText = '-B';
            ToolTip      = "detect complete rewrites.";
        },
        @{
            ListItemText = '-C';
            ToolTip      = "detect copies.";
        },
        @{
            ListItemText = '-l';
            ToolTip      = "limit rename attempts up to <n> paths.";
        },
        @{
            ListItemText = '-M';
            ToolTip      = "detect renames.";
        },
        @{
            ListItemText = '-O';
            ToolTip      = "reorder diffs according to the <file>.";
        },
        @{
            ListItemText = '-p';
            ToolTip      = "output patch format.";
        },
        @{
            ListItemText = '-R';
            ToolTip      = "swap input file pairs.";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "find filepair whose only one side contains the string.";
        },
        @{
            ListItemText = '-u';
            ToolTip      = "synonym for -p.";
        },
        @{
            ListItemText = '-z';
            ToolTip      = "output diff-raw with lines terminated with NUL.";
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
                Line     = '--b';
                Expected = '--base', '--binary', '--break-rewrites' | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-p';
                Expected = '--no-prefix', '--no-patch' | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        It '<Line>' -ForEach @(
            @{
                Line     = '--color-moved-ws i';
                Expected = 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--color-moved-ws ';
                Expected = 'no', 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space', 'allow-indentation-change' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--color-moved-ws=i';
                Expected = 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--color-moved-ws=$_" }
            },
            @{
                Line     = '--color-moved-ws=';
                Expected = 'no', 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space', 'allow-indentation-change' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--color-moved-ws=$_" }
            },
            @{
                Line     = '--color-moved=d';
                Expected = 'default', 'dimmed-zebra'  | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--color-moved=$_" }
            },
            @{
                Line     = '--color-moved=';
                Expected = 'no', 'default', 'plain', 'blocks', 'zebra', 'dimmed-zebra' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--color-moved=$_" }
            },
            @{
                Line     = '--ws-error-highlight d';
                Expected = 'default' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--ws-error-highlight ';
                Expected = 'context', 'old', 'new', 'all', 'default' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--ws-error-highlight=d';
                Expected = 'default' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
            },
            @{
                Line     = '--ws-error-highlight=';
                Expected = 'context', 'old', 'new', 'all', 'default' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--ws-error-highlight=$_" }
            },
            @{
                Line     = '--submodule=d';
                Expected = 'diff' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--submodule=$_" }
            },
            @{
                Line     = '--submodule=';
                Expected = 'diff', 'log', 'short' | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--submodule=$_" }
            },
            @{
                Line     = '--diff-algorithm m';
                Expected = @{
                    ListItemText   = 'myers';
                    ToolTip        = '(default) The basic greedy diff algorithm';
                },
                @{
                    ListItemText   = 'minimal';
                    ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--diff-algorithm ';
                Expected = @{
                    ListItemText   = 'myers';
                    ToolTip        = '(default) The basic greedy diff algorithm';
                },
                @{
                    ListItemText   = 'minimal';
                    ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                },
                @{
                    ListItemText   = 'patience';
                    ToolTip        = 'Use "patience diff" algorithm when generating patches';
                },
                @{
                    ListItemText   = 'histogram';
                    ToolTip        = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"';
                } | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--diff-algorithm=m';
                Expected = @{
                    CompletionText = "--diff-algorithm=myers";
                    ListItemText   = 'myers';
                    ToolTip        = '(default) The basic greedy diff algorithm';
                },
                @{
                    CompletionText = "--diff-algorithm=minimal";
                    ListItemText   = 'minimal';
                    ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-algorithm=$_" }
            },
            @{
                Line     = '--diff-algorithm=';
                Expected = @{
                    CompletionText = "--diff-algorithm=myers";
                    ListItemText   = 'myers';
                    ToolTip        = '(default) The basic greedy diff algorithm';
                },
                @{
                    CompletionText = "--diff-algorithm=minimal";
                    ListItemText   = 'minimal';
                    ToolTip        = 'Spend extra time to make sure the smallest possible diff is produced';
                },
                @{
                    CompletionText = "--diff-algorithm=patience";
                    ListItemText   = 'patience';
                    ToolTip        = 'Use "patience diff" algorithm when generating patches';
                },
                @{
                    CompletionText = "--diff-algorithm=histogram";
                    ListItemText   = 'histogram';
                    ToolTip        = 'This algorithm extends the patience algorithm to "support low-occurrence common elements"';
                } | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--diff-algorithm=$_" }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe-Revlist
}