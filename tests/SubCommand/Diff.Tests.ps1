using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') {
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

    Describe 'DoubleDash' {
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
                Expected = 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--color-moved-ws=$_"
                }
            },
            @{
                Line     = '--color-moved-ws=';
                Expected = 'no', 'ignore-space-at-eol', 'ignore-space-change', 'ignore-all-space', 'allow-indentation-change' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--color-moved-ws=$_"
                }
            },
            @{
                Line     = '--color-moved=d';
                Expected = 'default', 'dimmed-zebra'  | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--color-moved=$_"
                }
            },
            @{
                Line     = '--color-moved=';
                Expected = 'no', 'default', 'plain', 'blocks', 'zebra', 'dimmed-zebra' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--color-moved=$_"
                }
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
                Expected = 'default' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--ws-error-highlight=$_"
                }
            },
            @{
                Line     = '--ws-error-highlight=';
                Expected = 'context', 'old', 'new', 'all', 'default' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--ws-error-highlight=$_"
                }
            },
            @{
                Line     = '--submodule=d';
                Expected = 'diff' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--submodule=$_"
                }
            },
            @{
                Line     = '--submodule=';
                Expected = 'diff', 'log', 'short' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--submodule=$_"
                }
            },
            @{
                Line     = '--diff-algorithm m';
                Expected = 'myers', 'minimal' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--diff-algorithm ';
                Expected = 'myers', 'minimal', 'patience', 'histogram' | ConvertTo-Completion -ResultType ParameterValue
            },
            @{
                Line     = '--diff-algorithm=m';
                Expected = 'myers', 'minimal' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--diff-algorithm=$_"
                }
            },
            @{
                Line     = '--diff-algorithm=';
                Expected = 'myers', 'minimal', 'patience', 'histogram' | ForEach-Object {
                    "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--diff-algorithm=$_"
                }
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'Revlist' {
        . "${RepoRoot}testtools/Revlist.ps1"
    }
}