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

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor) <Right>' -ForEach @(
                @{
                    Left     = '--quiet';
                    Right    = @('--');
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
                },
                @{
                    Left     = '--quiet';
                    Right    = @('-- --all');
                    Expected = '--quiet' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'be more quiet'
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

        Describe 'Revlist' {
            . "${RepoRoot}testtools/Revlist.ps1" -Ref -Prefix '-- '
        }
    }

    It 'ShortOptions' {
        $Expected = @{
            ListItemText = '-e';
            ToolTip      = "edit message before committing";
        },
        @{
            ListItemText = '-F';
            ToolTip      = "read message from file";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "merge commit message (for a non-fast-forward merge)";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "do not show a diffstat at the end of the merge";
        },
        @{
            ListItemText = '-q';
            ToolTip      = "be more quiet";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "merge strategy to use";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "GPG sign commit";
        },
        @{
            ListItemText = '-v';
            ToolTip      = "be more verbose";
        },
        @{
            ListItemText = '-X';
            ToolTip      = "option for selected merge strategy";
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
                Line     = '--f';
                Expected = @{
                    ListItemText = '--ff';
                    ToolTip      = "allow fast-forward (default)";
                },
                @{
                    ListItemText = '--ff-only';
                    ToolTip      = "abort if fast-forward is not possible";
                },
                @{
                    ListItemText = '--file';
                    ToolTip      = "read message from file";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-f';
                Expected = @{
                    ListItemText = '--no-ff';
                    ToolTip      = "[NO] allow fast-forward (default)";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-verify';
                    ToolTip      = "bypass pre-merge-commit and commit-msg hooks";
                },
                @{
                    CompletionText = '--no-';
                    ListItemText   = '--no-...';
                    ResultType     = 'Text'
                } | ConvertTo-Completion -ResultType ParameterName
            }
        ) {
            "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
        }
    }

    Describe 'OptionValue' {
        Describe 'CompleteStrategy' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '-s ';
                    Expected = @(
                        'octopus',
                        'ours',
                        'recursive',
                        'resolve',
                        'subtree'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '-s o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy ';
                    Expected = @(
                        'octopus',
                        'ours',
                        'recursive',
                        'resolve',
                        'subtree'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy=o';
                    Expected = @(
                        'octopus',
                        'ours'
                    ) | ForEach-Object {
                        "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--strategy=$_"
                    }
                },
                @{
                    Line     = '--strategy-option ';
                    Expected = @(
                        'ours',
                        'theirs',
                        'subtree',
                        'subtree=',
                        'patience',
                        'histogram',
                        'diff-algorithm=',
                        'ignore-space-change',
                        'ignore-all-space',
                        'ignore-space-at-eol',
                        'renormalize',
                        'no-renormalize',
                        'no-renames',
                        'find-renames',
                        'find-renames=',
                        'rename-threshold='
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy-option r';
                    Expected = @(
                        'renormalize',
                        'rename-threshold='
                    ) | ConvertTo-Completion -ResultType ParameterValue
                },
                @{
                    Line     = '--strategy-option=r';
                    Expected = @(
                        'renormalize',
                        'rename-threshold='
                    ) | ForEach-Object {
                        "$_" | ConvertTo-Completion -ResultType ParameterValue -CompletionText "--strategy-option=$_"
                    }
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe 'Revlist' {
        . "${RepoRoot}testtools/Revlist.ps1" -Ref
    }
}