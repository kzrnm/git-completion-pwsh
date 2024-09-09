using namespace System.Collections.Generic;
using namespace System.IO;

. "$($script:RepoRoot = $PSScriptRoot.Substring(0, $PSScriptRoot.LastIndexOf('tests')).Replace('\', '/'))testtools/TestInitialize.ps1"

Describe (Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') -Tag Remote {
    BeforeAll {
        Set-Variable Command ((Get-Item $PSCommandPath).BaseName.Replace('.Tests', '') | ConvertTo-KebabCase)
        Initialize-Home

        $ErrorActionPreference = 'SilentlyContinue'
        mkdir ($rootPath = "$TestDrive/gitRoot")
        mkdir ($remotePath = "$TestDrive/gitRemote")
        Initialize-Remote $rootPath $remotePath
        Push-Location $rootPath
        (1..100) > Number.txt
        git add Number.txt
        git commit -m asc
        (99..20) > Number.txt
        git add Number.txt
        git commit -m desc
    }

    AfterAll {
        Restore-Home
        Pop-Location
    }

    Describe 'DoubleDash' {
        Describe 'InRight' {
            It '<Left>(cursor)<Right>' -ForEach @(
                @{
                    Left     = '--gpg-sign';
                    Right    = ' --';
                    Expected = '--gpg-sign' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'GPG sign commit'
                },
                @{
                    Left     = '--gpg-sign';
                    Right    = ' -- --all';
                    Expected = '--gpg-sign' | ConvertTo-Completion -ResultType ParameterName -ToolTip 'GPG sign commit'
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
            ListItemText = '-e';
            ToolTip      = "edit the commit message";
        },
        @{
            ListItemText = '-m';
            ToolTip      = "select mainline parent";
        },
        @{
            ListItemText = '-n';
            ToolTip      = "don't automatically commit";
        },
        @{
            ListItemText = '-s';
            ToolTip      = "add a Signed-off-by trailer";
        },
        @{
            ListItemText = '-S';
            ToolTip      = "GPG sign commit";
        },
        @{
            ListItemText = '-X';
            ToolTip      = "option for merge strategy";
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
                Line     = '--c';
                Expected = @{
                    ListItemText = '--cleanup=';
                    ToolTip      = "how to strip spaces and #comments from message";
                },
                @{
                    ListItemText = '--commit';
                    ToolTip      = "opposite of --no-commit";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--e';
                Expected = @{
                    ListItemText = '--edit';
                    ToolTip      = "edit the commit message";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-c';
                Expected = @{
                    ListItemText = '--no-commit';
                    ToolTip      = "don't automatically commit";
                },
                @{
                    ListItemText = '--no-cleanup';
                    ToolTip      = "[NO] how to strip spaces and #comments from message";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no-e';
                Expected = @{
                    ListItemText = '--no-edit';
                    ToolTip      = "[NO] edit the commit message";
                } | ConvertTo-Completion -ResultType ParameterName
            },
            @{
                Line     = '--no';
                Expected = @{
                    ListItemText = '--no-commit';
                    ToolTip      = "don't automatically commit";
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
                    ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--strategy=$_" }
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
                    ) | ConvertTo-Completion -ResultType ParameterValue -CompletionText { "--strategy-option=$_" }
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }

    Describe-Revlist -Ref

    Describe 'InProgress' {
        BeforeAll {
            git revert HEAD~ 2>$null
        }
        AfterAll {
            git revert --abort 2>$null
        }

        Describe 'Options' {
            It '<Line>' -ForEach @(
                @{
                    Line     = '';
                    Expected = @{
                        ListItemText = '--continue'
                        ToolTip      = 'resume revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--quit'
                        ToolTip      = 'end revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--abort'
                        ToolTip      = 'cancel revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--skip'
                        ToolTip      = 'skip current commit and continue';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--';
                    Expected = @{
                        ListItemText = '--continue'
                        ToolTip      = 'resume revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--quit'
                        ToolTip      = 'end revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--abort'
                        ToolTip      = 'cancel revert or cherry-pick sequence';
                    },
                    @{
                        ListItemText = '--skip'
                        ToolTip      = 'skip current commit and continue';
                    } | ConvertTo-Completion -ResultType ParameterName
                },
                @{
                    Line     = '--c';
                    Expected = @{
                        ListItemText = '--continue'
                        ToolTip      = 'resume revert or cherry-pick sequence';
                    } | ConvertTo-Completion -ResultType ParameterName
                }
            ) {
                "git $Command $Line" | Complete-FromLine | Should -BeCompletion $expected
            }
        }
    }
}